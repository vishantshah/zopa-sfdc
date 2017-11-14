global class LoanBankDetailsViewMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    private Integer ErrorCode;

    public LoanBankDetailsViewMock(Boolean is_success, Integer error_code) {
        IsSuccess = is_success;
        ErrorCode = error_code;
    }

    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('GET', request.getMethod(),'Request must be GET method');
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse();
        } else {
            response = getInternalErrorResponse(ErrorCode);
        }
        return response;
    }

     public static HttpResponse getInternalErrorResponse(Integer error_code) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(error_code);
        http_response.setStatus('Salesforce Internal Error');
        return http_response;
    }

    public static HttpResponse getSuccessResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        http_response.setBody(getMockResponceBody());
        return http_response;
    }

    public static String getMockResponceBody(){
        String response = '{'+
                  +'"AccountNumber": "test",'+
                  +'"SortCode": "test",'+
                  +'"AccountHolderName": "test",'+
                  +'"Reference": "test",'+
                  +'"BankName": "test",'+
                  +'"DirectDebitStatus": "test"'+
                +'}';
        return response;
    }
}