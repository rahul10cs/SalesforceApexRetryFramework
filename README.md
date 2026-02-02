# Salesforce Apex Retry Framework

## Overview

A robust, configuration-driven framework for handling Apex retry logic. This solution uses **Platform Events** for asynchronous logging, **Custom Metadata** for flexible configuration, and **Salesforce Flow** to schedule and execute retries without locking resources.

---

## Key Features

- **Decoupled Logging**  
  Uses Platform Events (`Retry_Log_Event__e`) to offload logging transactions.

- **Configurable Retries**  
  Manage retry limits, intervals, and delays via Custom Metadata (`Retry_Config__mdt`) without code changes.

- **Interface-Driven Design**  
  Extensible architecture using `RetryHandlerInterface`, allowing any Apex class to be retry-enabled.

- **Flow-Based Scheduling**  
  Retry timing is handled natively using Salesforce Flows.

---

## Installation & Setup

### 1. Deploy Metadata Objects

Ensure the following metadata components are deployed to your org:

- **Custom Object**: `Retry_Log__c`  
  Stores the history and status of retries.

- **Platform Event**: `Retry_Log_Event__e`  
  Acts as a buffer for incoming retry requests.

- **Custom Metadata Type**: `Retry_Config__mdt`  
  Defines configuration rules for retries.

---

### 2. Deploy Apex Classes & Triggers

Deploy the core framework components:

- `RetryHandlerInterface.cls`
- `RetryLogUtility.cls`
- `RetryLogDataObject.cls`
- `RetryLogEventTrigger.trigger` (with handler and helper classes)
- `RetryLog.cls` (Invocable method for Flow)

---

### 3. Activate the Flow

Deploy and activate the **RetryLog Flow**.

This autolaunched flow:
- Monitors `Retry_Log__c` records  
- Schedules retry execution based on configuration in `Retry_Config__mdt`

---

## Implementation Guide

Follow the steps below to make your Apex logic retry-enabled.

---

### Step 1: Implement the Interface

Create a new Apex class (or update an existing one) that implements `RetryHandlerInterface`.  
This class contains the logic that will be re-executed during retries.

```apex
public class MyIntegrationHandler implements RetryHandlerInterface {

    public void invokeRetry(Retry_Log__c retryLogObj) {
        // 1. Extract necessary data from the stored payload
        String accName = (String) RetryLogUtility.getAttributeFromJson(
            retryLogObj.Request_Payload__c,
            'accName'
        );

        // 2. Call your logic again
        doSomething(accName);
    }

    public static void doSomething(String accName) {
        // ... Your business logic or API call ...
    }
}
```

_Reference: `RetryDemo.cls`_

---

### Step 2: Configure Retry Rules

Create a record in **Retry Config Custom Metadata** (`Retry_Config__mdt`).

**Sample Configuration:**

- **Process Name**: `MyIntegrationHandler`  
- **Method Name**: `doSomething` (optional)  
- **Max Retry Count**: `3`  
- **Retry Interval (Minutes)**: `30`  
- **Start First Retry After (Minutes)**: `5`


| Field Label                        | API Name                            | Sample Value             | Description |
|----------------------------------|-------------------------------------|--------------------------|-------------|
| Process Name                     | Process_Name__c                     | MyIntegrationHandler     | Name of the integration handler or process |
| Method Name (Optional)           | Method_Name__c                      | doSomething              | Specific method to apply retry logic |
| Max Retry Count                  | Max_Retry_Count__c                  | 3                        | Maximum number of retry attempts |
| Retry Interval (Minutes)         | Retry_Interval_Minutes__c           | 30                       | Interval between retry attempts |
| Start First Retry After (Minutes)| Start_First_Retry_After_Minutes__c  | 5                        | Delay before first retry |
| Is Active                        | Is_Active__c                        | true                     | Enables or disables this configuration |
| Description (Optional)           | Description__c                      | Retry config for handler | Purpose of this retry rule |




_Reference: `Retry_Config__mdt`_

---

### Step 3: Instrument Your Code

Wrap your Apex logic in a `try/catch` block.  
On failure, publish a retry event using `RetryLogUtility`.

```apex
try {
    // Your logic here
    makeHttpCallout();

} catch (Exception ex) {

    // 1. Build the log object
    RetryLogDataObject logData = RetryLogDataObject.builder()
        .setProcessName('MyIntegrationHandler') // Must match Config/Class name
        .setMethodName('doSomething')
        .setRequestPayload(JSON.serialize(payloadMap))
        .setStatus('Failure')
        .setErrorMessage(ex.getMessage())
        .build();

    // 2. Publish the retry event
    RetryLogUtility.createLog(logData);
}
```

_Reference: `RetryLogUtility.cls`, `RetryDemo.cls`_

---

## How It Works

1. **Failure**  
   When your code fails, `RetryLogUtility` publishes a `Retry_Log_Event__e`.

2. **Processing**  
   `RetryLogEventTrigger` consumes the event.  
   The helper checks `Retry_Config__mdt` to determine retry eligibility.

3. **Log Creation**  
   A `Retry_Log__c` record is created.  
   If configured, the `Retry__c` checkbox is set to `true`.

4. **Scheduling**  
   The **RetryLog Flow** detects the record and waits until `Retry_Date_Time__c`.

5. **Execution**  
   At the scheduled time, the Flow calls `RetryLog.executeRetry`, dynamically instantiates the handler class (e.g. `MyIntegrationHandler`), and executes `invokeRetry()`.

---

## Notes & Best Practices

- Ensure **Process Name** exactly matches the Apex handler class name.
- Keep request payloads minimal and JSON-serializable.
- Platform Events help avoid transaction limits and locking issues.
- This framework is ideal for integrations, async processing, and transient failures.

---

Happy retrying 🚀
