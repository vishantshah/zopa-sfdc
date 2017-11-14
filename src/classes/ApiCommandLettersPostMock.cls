global class ApiCommandLettersPostMock implements HttpCalloutMock {
    Boolean IsSuccess;

    public ApiCommandLettersPostMock() {
        this(true);
    }

    public ApiCommandLettersPostMock(Boolean is_success) {
        IsSuccess = is_success;
    }

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse();
        } else {
            response = getInternalErrorResponse(500);
        }
        return response;
    }

    public static HttpResponse getInternalErrorResponse(Integer error_code) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(error_code);
        http_response.setStatus('Salesforce Internal Error');
        http_response.setBody('{"message":"Internal Error"}');
        return http_response;
    }

    public static HttpResponse getSuccessResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        http_response.setBody(getSuccessResponseBody());
        return http_response;
    }

    public static String getSuccessResponseBody() {
        String response = ''
                + '{'
                + '"Id":1,'
                + '"LoanId":"0000-0000-0000-0001",'
                + '"Name":"TestLetterName1",'
                + '"CreatedBy":"TestAuthorName1",'
                + '"CreatedDate":"2017-05-15T09:00:00.000Z"'
                + '}';
        return response;
    }
}