global class ApiTakeCaseOwnershipTestMock implements HttpCalloutMock {
    public static Boolean SetIsSuccess = true;
    public static Boolean SetFailResponse = true;

    private Boolean IsSuccess;
    private Boolean FailResponse;
    @testVisible private static Integer CommandsSent = 0;

    global ApiTakeCaseOwnershipTestMock(Boolean is_success) {
        this(is_success, true);
    }

    global ApiTakeCaseOwnershipTestMock() {
        this(true, false);
    }


    global ApiTakeCaseOwnershipTestMock(Boolean is_success, Boolean fail_response) {
        IsSuccess = is_success;
        FailResponse = fail_response;
    }


    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('PUT', request.getMethod(),'Request must be PUT method');
        System.assert(request.getEndpoint().endsWith('take-ownership'),'Wrong endpoint');
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse(FailResponse);
        } else {
            response = getInternalErrorResponse();
        }
        CommandsSent++;
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