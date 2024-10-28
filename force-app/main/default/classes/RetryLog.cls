/**
 * RetryLog
 * 
 * This class provides functionality to execute retry operations through a flow. It dynamically 
 * calls an Apex class specified by the process name, which implements the RetryHandlerInterface,
 * to execute the retry logic. This allows for flexible retry processing by selecting different 
 * handler classes based on input.
 * 
 * Created by: Rahul Goyal
 * Created on: October 25, 2024
 */
public class RetryLog {

    /**
     * FlowInputs
     * 
     * A nested class used to capture inputs from a Flow for retry execution.
     * Contains the retry log ID and process name to identify the retry record 
     * and handler class dynamically.
     */
    public class FlowInputs {         
        @InvocableVariable 
        public String iLID;            // Retry log ID to identify the retry log record

        @InvocableVariable 
        public String iLProcessName;   // Name of the Apex class to be invoked for retry
    }

    /**
     * executeRetry
     * 
     * Executes retry logic based on the provided Flow inputs. Dynamically instantiates 
     * the specified Apex class and calls its `invokeRetry` method to handle the retry.
     * Ensures that error handling and logging are in place for robust processing.
     * 
     * @param lstFlInputs - A list of FlowInputs containing retry log ID and process name
     * @InvocableMethod - Invocable in a Flow for executing retries
     */
    @InvocableMethod(label='Execute Retry' description='Execute Retry' category='RetryLog' callout=true)
    public static void executeRetry(List<FlowInputs> lstFlInputs) {
        try {
            // Dynamically instantiate the specified class implementing RetryHandlerInterface
            Type t = Type.forName(lstFlInputs[0].iLProcessName);
            RetryHandlerInterface handler = (RetryHandlerInterface) t.newInstance();

            // Load retry log and invoke the retry logic via the handler's method
            handler.invokeRetry(RetryLogUtility.loadRetryLog(lstFlInputs[0].iLID));
        } catch (Exception ex) {
            // Log any errors that occur during the retry execution
            Logger.error('Error while invoking retry interface: ' + ex.getMessage());
        } finally {
            // Ensure logs are saved, regardless of outcome
            Logger.saveLog();
        }
    }
}