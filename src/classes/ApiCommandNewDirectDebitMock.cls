global class ApiCommandNewDirectDebitMock implements HttpCalloutMock {
    public static Boolean SetIsSuccess = true;
    public static Boolean SetIsValidData = true;

    private Boolean IsSuccess;
    private Boolean IsValidData;

    global ApiCommandNewDirectDebitMock(Boolean is_success) {
        this(is_success, true);
    }

    global ApiCommandNewDirectDebitMock() {
        this(true, false);
    }


    global ApiCommandNewDirectDebitMock(Boolean is_success, Boolean is_valid_data) {
        IsSuccess = is_success;
        IsValidData = is_valid_data;
    }


    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('POST', request.getMethod(),'Request must be POST method');
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse(IsValidData);
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

    public static HttpResponse getSuccessResponse(Boolean is_valid_data) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        http_response.setBody(ApiCommandValidateBankAccountMock.getMockResponceBody(is_valid_data));
        return http_response;
    }

    public static HttpResponse getSuccessResponseWithBody(Boolean is_valid_data) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(201);
        http_response.setStatus('OK');
        http_response.setBody(getMockResponceBody());
        return http_response;
    }

    private static String getMockResponceBody(){
        String response =
                    '{'
                      +'"bankName": "Barclays",'
                      +'"accountHolderName": "John Smith",'
                      +'"accountNumber": "60555123",'
                      +'"sortCode": "403518",'
                      +'"directDebitStatus": "Authorised",'
                      +'"reference": 88298070,'
                      + '"bankAccountDetails": null'
                    +'}';
        return response;
    }
}