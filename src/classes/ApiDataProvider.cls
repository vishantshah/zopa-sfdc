public virtual class ApiDataProvider {
    @TestVisible protected String ErrorOnExecution;

    public class NoLoanIdException extends Exception {}

    public String getError() {
        return ErrorOnExecution;
    }

    @TestVisible protected Boolean handleCommandResponseSuccess(HttpResponse response) {
        try{
            if (response.getStatusCode() == 200 && response.getStatus() == 'OK') {
                if (String.isBlank(response.getBody())){
                    ErrorOnExecution = 'Body is empty';
                    return false;
                }
                return true;
            } else if (response.getStatusCode() == 403){
                ErrorOnExecution = 'Access Denied. Please ask administrator to check credentials.';
                return false;
            } else {
                String error_message = (String)((Map<String, Object>)JSON.deserializeUntyped(response.getBody())).get('message');
                ErrorOnExecution = 'Bad request. ' + error_message;
                return false;
            }
        } catch (Exception e) {
            ErrorOnExecution = 'There is no ability to show data. BE response is invalid: ' + response.getBody();
            return false;
        }
    }
}