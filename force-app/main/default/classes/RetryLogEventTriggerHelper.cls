/**
 * RetryLogEventTriggerHelper
 * 
 * This helper class is responsible for processing retry log events by creating or updating
 * retry logs based on specified retry configurations. The retry configurations determine
 * the conditions and parameters under which logs should be retried, including retry intervals
 * and maximum retry limits. This class is designed for retry use case.
 * 
 * Created by: Rahul Goyal
 * Created on: October 25, 2024
 */
public with sharing class RetryLogEventTriggerHelper {
    
    // Cache to hold Retry Configuration data for quick access based on Process and Method Names
    public static Map<String, Retry_Config__mdt> retryConfigMap {
        get {
            if (retryConfigMap == null) {
                retryConfigMap = new Map<String, Retry_Config__mdt>();
                List<Retry_Config__mdt> retryMDTList = Retry_Config__mdt.getAll().values();
                
                // Populate the map based on Process Name and optional Method Name as the key
                for (Retry_Config__mdt config : retryMDTList) {
                    String key = String.isBlank(config.Method_Name__c) 
                        ? config.Process_Name__c 
                        : config.Process_Name__c + '--' + config.Method_Name__c;
                    
                    if (!retryConfigMap.containsKey(key)) {
                        retryConfigMap.put(key, config);
                    }
                }
            }
            return retryConfigMap;
        }
        set;
    }

    /**
     * Creates or updates Retry Log records based on the incoming Retry Log Events.
     *
     * @param newEventList List of Retry_Log_Event__e records to process
     */
    public static void createRetryLog(List<Retry_Log_Event__e> newEventList) {
        Map<String, Retry_Config__mdt> configMap = RetryLogEventTriggerHelper.retryConfigMap;
        List<Retry_Log__c> retryLogList = new List<Retry_Log__c>();
        Map<Id, Retry_Log__c> existingLogMap = new Map<Id, Retry_Log__c>();

        // Collect existing Retry_Log__c records by Record_Id__c from events
        for (Retry_Log_Event__e newLog : newEventList) {
            if (String.isNotBlank(newLog.Record_Id__c)) {
                existingLogMap.put(newLog.Record_Id__c, null);
            }
        }

        // Query and populate existing logs for events that already have a record ID
        if (!existingLogMap.isEmpty()) {
            for (Retry_Log__c existingLog : [
                SELECT Id, Retry_Date_Time__c, Retry_Count__c, Retry_Interval_In_Minutes__c 
                FROM Retry_Log__c 
                WHERE Id IN :existingLogMap.keySet()
            ]) {
                existingLogMap.put(existingLog.Id, existingLog);
            }
        }

      // Process each event to create or update Retry Log records
for (Retry_Log_Event__e newLog : newEventList) {
    Retry_Log__c logToUpsert = new Retry_Log__c(
        Error_Message__c = newLog.Error_Message__c,
        Method_Name__c = newLog.Method_Name__c,
        Process_Name__c = newLog.Process_Name__c,
        Processed__c = newLog.Processed__c,
        Request_Payload__c = newLog.Request_Payload__c,
        Response_Payload__c = newLog.Response_Payload__c,
        Status__c = newLog.Status__c
    );

    // Set existing log ID for upsert if it exists
    Retry_Log__c existingLog;
    if (String.isNotBlank(newLog.Record_Id__c)) {
        logToUpsert.Id = newLog.Record_Id__c;
        existingLog = existingLogMap.get(newLog.Record_Id__c);
    }

    // Build a key to check if retry configuration exists for this Process and Method
    String key = logToUpsert.Process_Name__c + 
                 (String.isNotBlank(logToUpsert.Method_Name__c) 
                 ? '--' + logToUpsert.Method_Name__c 
                 : '');

    // Apply retry logic if configured and the log indicates a failure
    if (configMap.containsKey(key) && !logToUpsert.Processed__c && logToUpsert.Status__c == 'Failure') {
        logToUpsert.Retry__c = true;
        Retry_Config__mdt config = configMap.get(key);

        // Only use overrides for new logs (i.e., when existingLog is null)
        if (existingLog == null) {
            Integer retryInterval = newLog.Retry_Interval_Override__c != null 
                                    ? newLog.Retry_Interval_Override__c.intValue()
                                    : config.Retry_Interval_In_Minutes__c.intValue();
            Integer maxRetryLimit = newLog.Max_Retry_Limit_Override__c != null 
                                    ? newLog.Max_Retry_Limit_Override__c.intValue()
                                    : config.Max_Retry_Count__c.intValue();
            Integer retryCount = newLog.Retry_Count_Override__c != null 
                                    ? newLog.Retry_Count_Override__c.intValue()
                                    : 0;
            Integer startFirstRetryAfter = newLog.Start_First_Retry_After_Override__c != null 
                                           ? newLog.Start_First_Retry_After_Override__c.intValue()
                                           : config.Start_First_Retry_After_In_Minutes__c.intValue();

            // Set initial retry properties for a new log
            logToUpsert.Retry_Interval_In_Minutes__c = retryInterval;
            logToUpsert.Max_Retry_Limit__c = maxRetryLimit;
            logToUpsert.Retry_Date_Time__c = System.now().addMinutes(startFirstRetryAfter);
            logToUpsert.Retry_Count__c = retryCount;
        } else {
            // For existing logs, increment retry count and use the existing retry interval
            logToUpsert.Retry_Count__c = existingLog.Retry_Count__c + 1;
            logToUpsert.Retry_Date_Time__c = existingLog.Retry_Date_Time__c.addMinutes((Integer)existingLog.Retry_Interval_In_Minutes__c);
        }
    }

    retryLogList.add(logToUpsert);
}
        

        // Upsert logs and handle any potential exceptions
        if (!retryLogList.isEmpty()) {
            try {
                upsert retryLogList;
            } catch (Exception ex) {
                Logger.error('Error while upserting Retry Log: ' + ex.getMessage());
            } finally {
                Logger.saveLog(); // Ensure logs are saved regardless of outcome
            }
        }
    }
}