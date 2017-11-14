global class ApiCommandTestMock implements HttpCalloutMock {
    public static Boolean SetIsSuccess = true;
    public static final String ERROR_MESSAGE = 'Internal issues.';
    private Boolean IsSuccess;
    private Boolean IsErroredBulApproveResponse;
    private Integer StatusCode;

    global ApiCommandTestMock(Boolean is_success) {
        IsSuccess = is_success;
        StatusCode = ApiCommandTestMock.getCodeBySuccessFlag(is_success);
        IsErroredBulApproveResponse = false;
    }

    global ApiCommandTestMock(Boolean is_success, Boolean is_errored_bulk_approve_responce) {
        IsSuccess = is_success;
        StatusCode = ApiCommandTestMock.getCodeBySuccessFlag(is_success);
        IsErroredBulApproveResponse = is_errored_bulk_approve_responce;
    }

    global ApiCommandTestMock(Boolean is_success, Integer status_code) {
        IsSuccess = is_success;
        IsErroredBulApproveResponse = false;
        StatusCode = status_code;
    }

    global ApiCommandTestMock(){
        this(true);
    }

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response;
        if (IsErroredBulApproveResponse){
            response = getErroredBulApproveResponse(StatusCode);
        } else {
            if (IsSuccess) {
                response = getSuccessResponse(StatusCode);
            } else {
                response = getInternalErrorResponse(StatusCode);
            }
        }
        return response;
    }

    public static Integer getCodeBySuccessFlag(Boolean is_success){
        if(is_success){
            return 200;
        }
        return 666;
    }

    public static HttpResponse getInternalErrorResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(666);
        http_response.setStatus('Salesforce Internal Error');
        http_response.setBody('{"message" : "' + ERROR_MESSAGE + '"}');
        return http_response;
    }

    public static HttpResponse getInternalErrorResponse(Integer status_code) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(status_code);
        http_response.setStatus('Salesforce Internal Error');
        http_response.setBody('{"message" : "' + ERROR_MESSAGE + '"}');
        return http_response;
    }

    public static HttpResponse getSuccessResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        http_response.setBody('Success');
        return http_response;
    }

    public static HttpResponse getSuccessResponse(Integer status_code) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(status_code);
        http_response.setStatus('OK');
        http_response.setBody('Success');
        return http_response;
    }

    public static HttpResponse getErroredBulApproveResponse(Integer status_code) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(status_code);
        http_response.setStatus('OK');
        http_response.setBody('{"errored":["test2","test3","test7"],"isSuccess":false}');
        return http_response;
    }
}