global class ApiLoanConsolidationCandidatesTestMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    private Boolean EmptyResponse;

    global ApiLoanConsolidationCandidatesTestMock(Boolean is_success) {
        this(is_success, false);
    }

    global ApiLoanConsolidationCandidatesTestMock(Boolean is_success, Boolean empty_response) {
        IsSuccess = is_success;
        EmptyResponse = empty_response;
    }

    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('GET', request.getMethod(),'Request must be GET method');
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse(EmptyResponse);
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

    public static HttpResponse getSuccessResponse(Boolean is_empty_body) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        if(is_empty_body){
            http_response.setBody(getTestEmptyJsonBody());
        } else{
            http_response.setBody(getTestJsonBody());
        }
        return http_response;
    }

    public static String getTestJsonBody() {
        String json = '{' +
        '       "confirmedConsolidationLoans":[' +
        '          {' +
        '             "borrowingId":"ec97ddab-435b-4c97-8392-4b4747ea22cf",' +
        '             "requestedAmount":7000.0,' +
        '             "capitalRemaining":2000.0,' +
        '             "settlementAmount":3500.0,' +
        '             "isRepaymentPending":false' +
        '          },' +
        '          {' +
        '             "borrowingId":"8f48ca9f-1578-4191-a2e9-eef0cd16e0a0",' +
        '             "requestedAmount":12500.0,' +
        '             "capitalRemaining":3000.0,' +
        '             "settlementAmount":3900.0,' +
        '             "isRepaymentPending":true' +
        '          },' +
        '          {' +
        '             "borrowingId":"b1088418-951b-4be2-9da9-ded7912e04aa",' +
        '             "requestedAmount":5000.0,' +
        '             "capitalRemaining":800.0,' +
        '             "settlementAmount":950.0,' +
        '             "isRepaymentPending":false' +
        '          }' +
        '       ]' +
        '    }';
        return json;
    }

    public static String getTestEmptyJsonBody() {
        String json = '{' +
        '       "confirmedConsolidationLoans":null' +
        '    }';
        return json;
    }
}