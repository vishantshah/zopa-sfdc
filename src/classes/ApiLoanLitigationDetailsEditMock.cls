global class ApiLoanLitigationDetailsEditMock implements HttpCalloutMock {
    public static Boolean SetIsSuccess = true;
    public static Boolean SetFailResponse = true;

    private Boolean IsSuccess;
    private Boolean FailResponse;

    global ApiLoanLitigationDetailsEditMock(Boolean is_success) {
        this(is_success, true);
    }

    global ApiLoanLitigationDetailsEditMock() {
        this(true, false);
    }


    global ApiLoanLitigationDetailsEditMock(Boolean is_success, Boolean fail_response) {
        IsSuccess = is_success;
        FailResponse = fail_response;
    }


    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('PUT', request.getMethod(),'Request must be PUT method');
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse(FailResponse);
        } else {
            response = getInternalErrorResponse();
        }
        return response;
    }

    public static HttpResponse getInternalErrorResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(500);
        http_response.setStatus('Salesforce Internal Error');
        http_response.setBody('{"message":"Internal Error"}');
        return http_response;
    }

    public static HttpResponse getSuccessResponse(Boolean fail_response) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        http_response.setBody('{"success":' + String.valueOf(fail_response) + '}');
        return http_response;
    }
}