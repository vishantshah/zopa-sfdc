global class ApiCommandLettersBulkPostMock implements HttpCalloutMock {
    Boolean IsSuccess;
    Integer StatusCode;

    public ApiCommandLettersBulkPostMock() {
        this(true, 200);
    }

    public ApiCommandLettersBulkPostMock(Boolean is_success, Integer status_code) {
        IsSuccess = is_success;
        StatusCode = status_code;
    }

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse(StatusCode);
        } else {
            response = getInternalErrorResponse(StatusCode);
        }
        return response;
    }

    public static HttpResponse getInternalErrorResponse(Integer status_code) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(status_code);
        http_response.setStatus('Salesforce Internal Error');
        http_response.setBody('{"message":"Internal Error"}');
        return http_response;
    }

    public static HttpResponse getSuccessResponse(Integer status_code) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(status_code);
        if (status_code == 200) {
            http_response.setStatus('OK');
        } else if (status_code == 202) {
            http_response.setStatus('Accepted');
        }
        return http_response;
    }
}