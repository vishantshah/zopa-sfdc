global class ApiCommandLettersGetAllMock implements HttpCalloutMock {
    @TestVisible Boolean IsSuccess;
    @TestVisible Integer StatusCode;

    public ApiCommandLettersGetAllMock() {
        this(true, 200);
    }

    public ApiCommandLettersGetAllMock(Boolean is_success, Integer status_code) {
        IsSuccess = is_success;
        StatusCode = status_code;
    }

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse();
        } else {
            response = getInternalErrorResponse(StatusCode);
        }
        return response;
    }

    public static HttpResponse getInternalErrorResponse(Integer error_code) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(error_code);
        if (error_code == 500) {
            http_response.setStatus('Salesforce Internal Error');
            http_response.setBody('{"message":"Internal Error"}');
        } else if (error_code == 404) {
            http_response.setStatus('Not Found');
            http_response.setBody('{"message":"No letters found for this Loan"}');
        }
        return http_response;
    }

    public static HttpResponse getSuccessResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        http_response.setBody(getAllLettersResponse());
        return http_response;
    }

    public static String getAllLettersResponse() {
        String response = ''
                + '['
                + '{'
                + '"Id":1,'
                + '"LoanId":"0000-0000-0000-0001",'
                + '"Name":"TestLetterName1",'
                + '"CreatedBy":"TestAuthorName1",'
                + '"CreatedDate":"2017-05-15T09:00:00.000Z"'
                + '},'
                + '{'
                + '"Id":2,'
                + '"LoanId":"0000-0000-0000-0002",'
                + '"Name":"TestLetterName2",'
                + '"CreatedBy":"TestAuthorName2",'
                + '"CreatedDate":"2017-05-16T09:00:00.000Z"'
                + '}'
                + ']';
        return response;
    }
}