/**
 * RetryLogDataObject
 * 
 * A fully flexible data object for retry log events. All fields are optional,
 * and can be set using a builder pattern.
 */
global class RetryLogDataObject {    

    // Fields for the retry log event
    public String processName;
    public String methodName;
    public String requestPayload;
    public String status;
    public String errorMessage;
    public Boolean processed;
    public String responsePayload;
    public String recordId;

    // Retry configuration overrides
    public Integer maxRetryLimitOverride;
    public Integer retryIntervalOverride;
    public Integer startFirstRetryAfterOverride;

    /**
     * Private constructor to enforce use of the builder pattern.
     */
    private RetryLogDataObject() {}

    /**
     * Static method to create a new Builder instance.
     * 
     * @return Builder instance for chaining additional optional attributes
     */
    public static Builder builder() {
        return new Builder();
    }

    /**
     * Builder class for RetryLogDataObject to set optional fields.
     */
    global class Builder {
        private RetryLogDataObject dataObject;

        private Builder() {
            dataObject = new RetryLogDataObject();
        }

        // Optional attribute setters with chaining
        public Builder setProcessName(String processName) {
            dataObject.processName = processName;
            return this;
        }

        public Builder setMethodName(String methodName) {
            dataObject.methodName = methodName;
            return this;
        }

        public Builder setRequestPayload(String requestPayload) {
            dataObject.requestPayload = requestPayload;
            return this;
        }

        public Builder setStatus(String status) {
            dataObject.status = status;
            return this;
        }

        public Builder setErrorMessage(String errorMessage) {
            dataObject.errorMessage = errorMessage;
            return this;
        }

        public Builder setProcessed(Boolean processed) {
            dataObject.processed = processed;
            return this;
        }

        public Builder setResponsePayload(String responsePayload) {
            dataObject.responsePayload = responsePayload;
            return this;
        }

        public Builder setRecordId(String recordId) {
            dataObject.recordId = recordId;
            return this;
        }


        public Builder setMaxRetryLimitOverride(Integer maxRetryLimitOverride) {
            dataObject.maxRetryLimitOverride = maxRetryLimitOverride;
            return this;
        }

        public Builder setRetryIntervalOverride(Integer retryIntervalOverride) {
            dataObject.retryIntervalOverride = retryIntervalOverride;
            return this;
        }

        public Builder setStartFirstRetryAfterOverride(Integer startFirstRetryAfterOverride) {
            dataObject.startFirstRetryAfterOverride = startFirstRetryAfterOverride;
            return this;
        }

        /**
         * Builds and returns the configured RetryLogDataObject.
         */
        public RetryLogDataObject build() {
            return dataObject;
        }
    }
}
