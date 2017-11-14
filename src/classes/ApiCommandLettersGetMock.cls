global class ApiCommandLettersGetMock implements HttpCalloutMock {
    Boolean IsSuccess;
    Integer StatusCode;

    public ApiCommandLettersGetMock() {
        this(true, 200);
    }

    public ApiCommandLettersGetMock(Boolean is_success, Integer status_code) {
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

    public static HttpResponse getInternalErrorResponse(Integer status_code) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(status_code);
        if(status_code == 404) {
            http_response.setStatus('Not Found');
            http_response.setBody('{"message":"Letter not found"}');
        } else if (status_code == 500) {
            http_response.setStatus('Salesforce Internal Error');
            http_response.setBody('{"message":"Internal Error"}');
        }
        return http_response;
    }

    public static HttpResponse getSuccessResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        http_response.setBodyAsBlob(EncodingUtil.base64Decode(getLetterResponse()));
        return http_response;
    }

    public static String getLetterResponse(){
        List<StaticResource> static_resources = [
                SELECT Body
                FROM StaticResource
                WHERE Name = 'Test_PDF_File'
                LIMIT 1
        ];
        if (static_resources.isEmpty()) {
            return '';
        } else {
            return EncodingUtil.base64Encode(static_resources[0].Body);
        }
    }
}