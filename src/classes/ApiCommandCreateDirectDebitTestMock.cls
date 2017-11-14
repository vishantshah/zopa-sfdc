global class ApiCommandCreateDirectDebitTestMock implements HttpCalloutMock {
    private Boolean IsSuccess;

    global ApiCommandCreateDirectDebitTestMock(Boolean is_success) {
        IsSuccess = is_success;
    }

    global HTTPResponse respond(HTTPRequest request) {
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
        String json =  '{'+
                  +'"LoanId": "test",'+
                  +'"AccountNumber": "123",'+
                  +'"SortCode": "123",'+
                  +'"AccountHolderName": "test",'+
                  +'"RequestedDate": "123",'+
                  +'"OriginatorReference": "123",'+
                  +'"Reference": "123",'+
                  +'"BankName": "test",'+
                  +'"BranchName": "test",'+
                  +'"BranchStreet1": "test",'+
                  +'"BranchStreet2": "test",'+
                  +'"BranchPostCode": "123",'+
                  +'"BranchPostTown": "test",'+
                  +'"BranchDistrict": "123",'+
                  +'}';

        return json;
    }

    public static String getTestEmptyJsonBody() {
        String json = '{}';

        return json;
    }
}