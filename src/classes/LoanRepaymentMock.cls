global class LoanRepaymentMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    private Integer ErrorCode;

    public LoanRepaymentMock(Boolean is_success, Integer error_code) {
        IsSuccess = is_success;
        ErrorCode = error_code;
    }

    public LoanRepaymentMock(){
        this(true,200);
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
        http_response.setBody('{"message":"Internal Error"}');
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
        String response =
                '['
                    +'{'+
                      +'"repaymentDate": "2017-02-01T18:04:08.3873373+00:00",'+
                      +'"receivedDate": "2017-02-03T18:04:08.3873373+00:00",'+
                      +'"type": "Regular",'+
                      +'"amount": "123.45",'+
                      +'"status": "Paid",'+
                      +'"countsAsNormalRepayment": true,'+
                      +'"thirdPartyFlag": false'+
                    +'}'
                    +','
                    +'{'+
                      +'"repaymentDate": "2017-02-01T18:04:08.3873373+00:00",'+
                      +'"receivedDate": "2017-02-03T18:04:08.3873373+00:00",'+
                      +'"type": "Replacement",'+
                      +'"amount": "136.45",'+
                      +'"status": "FailDoneNoDD",'+
                      +'"countsAsNormalRepayment": false,'+
                      +'"thirdPartyFlag": true'+
                    +'}'
                +']';
        return response;
    }

}