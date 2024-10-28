/**
 * RetryLogEventTriggerHandler
 * 
 * This trigger handler class is responsible for handling retry log events after they are inserted.
 * It delegates the processing of these events to the RetryLogEventTriggerHelper, which creates or updates 
 * retry logs based on defined retry configurations.
 * 
 * Created by: Rahul Goyal
 * Created on: October 25, 2024
 */
public with sharing class RetryLogEventTriggerHandler extends TriggerHandler {
    
    // List to hold new Retry Log Event records
    private List<Retry_Log_Event__e> newEventList;

    /**
     * Constructor for RetryLogEventTriggerHandler.
     * Initializes the newEventList with records from Trigger.new.
     */
    public RetryLogEventTriggerHandler() {
        newEventList = (List<Retry_Log_Event__e>) Trigger.new;
    }

    /**
     * afterInsert
     * 
     * This method is called after new Retry Log Event records are inserted. 
     * It invokes the helper method to create or update retry logs as necessary.
     */
    public override void afterInsert() { 
        RetryLogEventTriggerHelper.createRetryLog(newEventList);
    }
}