/**
 * RetryHandlerInterface
 * 
 * This interface defines the structure for retry handler classes, ensuring they implement
 * a method for executing retry logic based on a given retry log record. Classes implementing 
 * this interface provide specific retry actions by defining the behavior within `invokeRetry`.
 * 
 * This interface allows for flexible and dynamic retry processing by enabling different 
 * implementations to be called based on the retry context.
 * 
 * Created by: Rahul Goyal
 * Created on: October 25, 2024
 */
public interface RetryHandlerInterface {

    /**
     * invokeRetry
     * 
     * Executes retry logic for the given retry log record. Implementing classes will provide 
     * specific retry logic based on the details in the `Retry_Log__c` record.
     * 
     * @param retryLogObj - The Retry_Log__c record containing data for the retry operation
     */
    void invokeRetry(Retry_Log__c retryLogObj);
}