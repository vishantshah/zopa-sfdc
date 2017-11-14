global class ApiValidateBankDetailsTestMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    private Boolean EmptyResponse;

    global ApiValidateBankDetailsTestMock(Boolean is_success) {
        this(is_success, false);
    }

    global ApiValidateBankDetailsTestMock() {
        this(true, false);
    }

    global ApiValidateBankDetailsTestMock(Boolean is_success, Boolean empty_response) {
        IsSuccess = is_success;
        EmptyResponse = empty_response;
    }

    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('POST', request.getMethod(),'Request must be POST method');
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse(EmptyResponse);
        } else {
            response = getInternalErrorResponse();
        }
        return response;
    }

    public static HttpResponse getInternalErrorResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(500);
        http_response.setStatus('Salesforce Internal Error');
        return http_response;
    }

    public static HttpResponse getSuccessResponse(Boolean is_empty_body) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        if(is_empty_body){
            http_response.setBody(getTestEmptyJsonBody());
        } else{
            http_response.setBody(getTestJsonBody());
        }
        return http_response;
    }

    public static String getTestJsonBody() {
        String json = '"PASS"';
        return json;
    }

    public static String getTestEmptyJsonBody() {
        String json = '';
        return json;
    }
}