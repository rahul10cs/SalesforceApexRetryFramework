/**
 * RetryDemo
 * 
 * This class implements the RetryHandlerInterface to handle retry operations for demo purposes.
 * It provides methods to invoke a retry action and perform an operation (in this case, calling a REST API)
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
     * Demonstrates a retryable action by calling a REST API endpoint 
     * with a name derived from the payload data and retry count. Logs 
     * the success or failure of each attempt to the retry log.
     * 
     * @param accName - The account name extracted from the JSON payload
     */
    public static void doSomething(String accName) {
        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('accName', accName);

        // Prepare HTTP request with dynamic accName parameter in the URL
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://retryframework.free.beeceptor.com/getData?name=' + EncodingUtil.urlEncode(accName, 'UTF-8'));
        request.setMethod('GET');  
        request.setHeader('Content-Type', 'application/json');
        RetryLogDataObject.Builder logBuilder = RetryLogDataObject.builder();
        try {
            // Make HTTP callout
            HttpResponse response = http.send(request);

            // Initialize the log builder
           if(response.getStatusCode() == 200){
            logBuilder.setStatus('Success');
           } else{
            logBuilder.setStatus('Failure').setErrorMessage('Error: ' + response.getStatus());
           }
            logBuilder.setResponsePayload(response.getBody());
            // Set max retry override only if response code is 500
            if (response.getStatusCode() == 500) {
                logBuilder.setMaxRetryLimitOverride(2);
            }

        } catch (Exception ex) { 
            // Log failure with error message if callout fails
            logBuilder.setStatus('Failure').setErrorMessage('Exception: ' + ex.getMessage());
        } finally {
             // Create the log with the built object
             logBuilder.setProcessName('RetryDemo')
                .setMethodName('doSomething')
                .setRequestPayload(JSON.serialize(paramMap))
                .setRecordId(retryLogObj?.Id);
             RetryLogUtility.createLog(logBuilder.build());
        }
    }

    // Custom exception for handling specific error cases within RetryDemo
    public class CustomException extends Exception {}
}