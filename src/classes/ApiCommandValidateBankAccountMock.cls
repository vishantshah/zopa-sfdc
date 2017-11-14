global class ApiCommandValidateBankAccountMock implements HttpCalloutMock {
    public static Boolean SetIsSuccess = true;
    public static Boolean SetFailResponse = true;

    private Boolean IsSuccess;
    private Boolean FailResponse;

    global ApiCommandValidateBankAccountMock(Boolean is_success) {
        this(is_success, true);
    }

    global ApiCommandValidateBankAccountMock() {
        this(true, true);
    }


    global ApiCommandValidateBankAccountMock(Boolean is_success, Boolean fail_response) {
        IsSuccess = is_success;
        FailResponse = fail_response;
    }


    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('POST', request.getMethod(),'Request must be POST method');
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse(FailResponse);
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

    public static HttpResponse getSuccessResponse(Boolean fail_response) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        http_response.setBody(getMockResponceBody(fail_response));
        return http_response;
    }

    public static String getMockResponceBody(Boolean fail_response){
        String response =
                    '{'
                      +'"isAccountValid": ' + fail_response + ','
                      +'"canAcceptDDI": true,'
                      +'"fasterPayments": true,'
                      +'"bankName": "HSBC Bank PLC",'
                      +'"bankBranchName": "London,Whitechapel",'
                      +'"street1": "75 Whitechapel Road",'
                      + '"street2": "Whitechapel",'
                      + '"postCode": "E11DU",'
                      + '"postTown": "London",'
                      + '"street2": ""'
                    +'}';
        return response;
    }
}