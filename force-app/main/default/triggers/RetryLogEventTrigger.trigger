/**
 * RetryLogEventTrigger
 * 
 * This trigger executes after new Retry Log Event records are inserted.
 * It initializes the RetryLogEventTriggerHandler, which manages the processing of the events.
 * The handler processes the retry log events by creating or updating retry logs based on 
 * the defined retry configurations.
 * 
 * Created by: Rahul Goyal
 * Created on: October 25, 2024
 */
trigger RetryLogEventTrigger on Retry_Log_Event__e (after insert) {
    // Initialize and run the handler to process retry log events
    new RetryLogEventTriggerHandler().run();
}