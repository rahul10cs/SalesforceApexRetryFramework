/**
 * RetryLogDataObject
 * 
 * This data object class is used to encapsulate the details of a retry log event.
 * It holds information such as error messages, process details, payloads, and 
 * processing status to facilitate logging and retry handling.
 * 
 * Created by: Rahul Goyal
 * Created on: October 25, 2024
 */
global class RetryLogDataObject {    

    // Attributes to store retry log information
    public String errorMessage;
    public String methodName;
    public String processName;
    public Boolean processed;
    public String requestPayload;
    public String responsePayload;
    public String status;
    public String recordId;

    /**
     * Constructor to initialize the RetryLogDataObject with specific retry log details.
     * 
     * @param recordId       - Unique identifier for the retry record
     * @param errorMessage   - Description of any error that occurred
     * @param methodName     - Name of the method associated with the retry
     * @param processName    - Name of the process being retried
     * @param processed      - Boolean indicating if the log has been processed
     * @param requestPayload - Request payload details for the retry operation
     * @param responsePayload- Response payload received from the retry operation
     * @param status         - Status indicating success or failure of the retry operation
     */
    public RetryLogDataObject(String recordId, String errorMessage, String methodName, String processName, Boolean processed, String requestPayload, String responsePayload, String status) {
        this.recordId = recordId;
        this.errorMessage = errorMessage;
        this.methodName = methodName;
        this.processName = processName;
        this.processed = processed;
        this.requestPayload = requestPayload;
        this.responsePayload = responsePayload;
        this.status = status;
    }

    /**
     * Default constructor for RetryLogDataObject.
     * Initializes an empty data object to hold retry log details.
     */
    public RetryLogDataObject() {}
}