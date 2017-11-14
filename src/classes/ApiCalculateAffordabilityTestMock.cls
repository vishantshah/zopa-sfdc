global class ApiCalculateAffordabilityTestMock implements HttpCalloutMock {
    private Boolean IsSuccess;

    global ApiCalculateAffordabilityTestMock(Boolean is_success) {
        IsSuccess = is_success;
    }
     global ApiCalculateAffordabilityTestMock() {
        this(true);
    }

    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('POST', request.getMethod(),'Request must be POST method');
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse();
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

    public static HttpResponse getSuccessResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        http_response.setBody(getTestJsonBody());
        return http_response;
    }

    public static String getTestJsonBody() {
        String json = '{'+
        '    "ldti": 100,'+
        '    "dti": 111,'+
        '    "di": "122"'+
        '}';

        return json;
    }

    public static String getTestEmptyJsonBody() {
        String json = '{}';

        return json;
    }
}