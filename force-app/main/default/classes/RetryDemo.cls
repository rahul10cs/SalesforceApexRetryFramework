/**
 * RetryDemo
 * 
 * This class implements the RetryHandlerInterface to handle retry operations for demo purposes.
 * It provides methods to invoke a retry action and perform an operation (in this case, creating an Account record)
 * with specified retry logic. The class logs the outcome of each attempt using the RetryLogUtility.
 * 
 * Created by: Rahul Goyal
 * Created on: October 25, 2024
 */
public class RetryDemo implements RetryHandlerInterface {

    // Holds the retry log record associated with the current retry operation
    public static Retry_Log__c retryLogObj;

    /**
     * invokeRetry
     * 
     * Implements the retry logic by invoking a specific action with details 
     * from the retry log event payload. This method extracts an account name 
     * from the JSON payload and passes it to the action method.
     * 
     * @param retryLogObjParam - The Retry_Log__c object containing retry details
     */
    public void invokeRetry(Retry_Log__c retryLogObjParam) {
        retryLogObj = retryLogObjParam;
        
        // Extracts 'accName' from JSON payload and calls the action method
        RetryDemo.doSomething((String) RetryLogUtility.getAttributeFromJson(retryLogObj.Request_Payload__c, 'accName'));
    }

    /**
     * doSomething
     * 
     * Demonstrates a retryable action by creating an Account record using a name 
     * derived from the payload data and retry count. Logs the success or failure 
     * of each attempt to the retry log.
     * 
     * @param accName - The account name extracted from the JSON payload
     */
    public static void doSomething(String accName) {
        // Create an Account with the name including retry details
        Account acc = new Account(name = accName + System.now() + '----' + retryLogObj?.Retry_Count__c);
        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('accName', accName);

        try {
            // Attempt to insert the Account and log success
            insert acc;
            RetryLogDataObject log = RetryLogDataObject.builder()
            .setProcessName('RetryDemo')
            .setMethodName('doSomething')
            .setRequestPayload(JSON.serialize(paramMap))
            .setStatus('Success')
            .build();
            RetryLogUtility.createLog(log);
        } catch (Exception ex) { 
            // Log failure with error message if insertion fails
            RetryLogDataObject log = RetryLogDataObject.builder()
            .setProcessName('RetryDemo')
            .setMethodName('doSomething')
            .setRequestPayload(JSON.serialize(paramMap))
            .setStatus('Failure')
            .setErrorMessage(ex.getMessage())
            .setMaxRetryLimitOverride(5)
            .build();
            RetryLogUtility.createLog(log);
        }
    }

    // Custom exception for handling specific error cases within RetryDemo
    public class CustomException extends Exception {}
}