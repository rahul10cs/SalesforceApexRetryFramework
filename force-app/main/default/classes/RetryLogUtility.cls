/**
 * RetryLogUtility
 * 
 * This utility class provides methods for handling retry log functionality, including creating retry log entries,
 * publishing platform events, generating event records, and retrieving attributes from JSON payloads.
 * It supports both single and bulk retry log operations for flexible use in retry-related processes.
 * 
 * Created by: Rahul Goyal
 * Created on: October 25, 2024
 */
public with sharing class RetryLogUtility {

    /**
     * createLog
     * 
     * Creates retry log entries from a list of RetryLogDataObject instances by generating platform events 
     * based on the provided data. This method is useful for handling multiple retry logs in bulk.
     * 
     * @param retryData - List of RetryLogDataObject instances to log as retry events
     */
    public static void createLog(List<RetryLogDataObject> retryData) {
        List<Retry_Log_Event__e> eventsToPublish = new List<Retry_Log_Event__e>();
        for (RetryLogDataObject retryDataObj : retryData) {
            eventsToPublish.add(generateEventRecord(retryDataObj));
        }
        firePlatformEvent(eventsToPublish);
    }

    /**
     * Overloaded method to create a single retry log entry.
     * 
     * @param retryData - A single RetryLogDataObject instance to log as a retry event
     */
    public static void createLog(RetryLogDataObject retryData) {
        createLog(new List<RetryLogDataObject> {retryData});
    }

    /**
     * firePlatformEvent
     * 
     * Publishes a list of retry log events to the platform event bus.
     * This method is private and is used internally to handle event publishing for bulk retry log entries.
     * 
     * @param eventsToPublish - List of Retry_Log_Event__e records to publish
     */
    private static void firePlatformEvent(List<Retry_Log_Event__e> eventsToPublish) {
        EventBus.publish(eventsToPublish);
    }

    /**
     * Overloaded method to publish a single platform event for retry logs.
     * 
     * @param eventToPublish - A single Retry_Log_Event__e record to publish
     */
    private static void firePlatformEvent(Retry_Log_Event__e eventToPublish) {
        firePlatformEvent(new List<Retry_Log_Event__e> {eventToPublish});
    }

    /**
     * generateEventRecord
     * 
     * Generates a platform event record from a RetryLogDataObject instance, setting event fields based on 
     * the retry log data provided.
     * 
     * @param newLog - The RetryLogDataObject containing data for the event record
     * @return Retry_Log_Event__e - The platform event record populated with retry log data
     */
    public static Retry_Log_Event__e generateEventRecord(RetryLogDataObject newLog) {
        return new Retry_Log_Event__e(
            Record_Id__c = newLog.recordId,
            Error_Message__c = newLog.errorMessage,
            Method_Name__c = newLog.methodName,
            Process_Name__c = newLog.processName,
            Processed__c = newLog.processed,
            Request_Payload__c = newLog.requestPayload,
            Response_Payload__c = newLog.responsePayload,
            Status__c = newLog.status
        );
    }

    /**
     * loadRetryLog
     * 
     * Loads a retry log record by its ID, allowing retrieval of key retry attributes for further processing.
     * 
     * @param retryLogID - ID of the Retry_Log__c record to load
     * @return Retry_Log__c - The retrieved retry log record with selected fields
     */
    public static Retry_Log__c loadRetryLog(Id retryLogID) {
        return [SELECT Id, Method_Name__c, Request_Payload__c, Retry_Count__c 
                FROM Retry_Log__c 
                WHERE Id = :retryLogID LIMIT 1];
    }

    /**
     * getAttributeFromJson
     * 
     * Extracts a specified attribute from a JSON string. Deserializes the JSON into a map and retrieves the 
     * attribute if present; otherwise, it throws a custom exception.
     * 
     * @param jsonString - The JSON string to search
     * @param attributeKey - The key of the attribute to retrieve from the JSON
     * @return Object - The value of the specified attribute, if found
     * @throws CustomException - If the attribute key is not found in the JSON
     */
    public static Object getAttributeFromJson(String jsonString, String attributeKey) {
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
        if (jsonMap.containsKey(attributeKey)) {
            return jsonMap.get(attributeKey);
        } else {
            throw new CustomException('Attribute ' + attributeKey + ' not found in the provided JSON.');
        }
    }

    // Custom exception for handling errors when retrieving attributes from JSON
    public class CustomException extends Exception {} 
}