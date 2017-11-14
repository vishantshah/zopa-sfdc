global class LoanLitigationDetailsMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    private Integer ErrorCode;

    public LoanLitigationDetailsMock(Boolean is_success, Integer error_code) {
        IsSuccess = is_success;
        ErrorCode = error_code;
    }

    public LoanLitigationDetailsMock(){
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
                    '{'+
                        '"assignment": "2017-09-13T00:00:00",'+
                        '"lbaSent": "2017-09-13T00:00:00",'+
                        '"claimSentToCourt": "2017-09-13T00:00:00",'+
                        '"claimIssued": "2017-09-13T00:00:00",'+
                        '"defendantDeadline": "2017-09-13T00:00:00",'+
                        '"judgmentRequested": "2017-09-13T00:00:00",'+
                        '"judgmentObtained": "2017-09-13T00:00:00",'+
                        '"enforcementCommenced": "2017-09-13T00:00:00",'+
                        '"warrantIssued": "2017-09-13T00:00:00",'+
                        '"finalReturn": "2017-09-13T00:00:00",'+
                        '"countyCourtClaimNumber": "1234 123 1234",'+
                        '"defaultNotice": "2017-09-13T00:00:00",'+
                        '"dateOfDefault": "2017-09-13T00:00:00",'+
                        '"originalCourtFees": 1234.56,'+
                        '"outstandingCourtFees": 123.45'+
                    +'}';
        return response;
    }

}