global class LoanDetailsViewMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    private Integer ErrorCode;

    public LoanDetailsViewMock() {
        IsSuccess = true;
        ErrorCode = 200;
    }

    public LoanDetailsViewMock(Boolean is_success, Integer error_code) {
        IsSuccess = is_success;
        ErrorCode = error_code;
    }

    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('GET', request.getMethod(), 'Request must be GET method');
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
        http_response.setBody(getMockResponseBody());
        return http_response;
    }

    public static String getMockResponseBody() {
        String response = '{' +
                +'"arrearsBalance": "0.0",' +
                +'"arrearsRatio": "0.0",' +
                +'"earlyRepaymentAmount": "12345.0",' +
                +'"holdingAccountBalance": "0.0",' +
                +'"monthlyRepaymentAmount": "166.64750352",' +
                +'"nextRepaymentAdjustment": "0.0",' +
                +'"remainingBalance": "7665.78516896",' +
                +'"replacementAmount": "0.0",' +
                +'"state": "Withdrawn",' +
                +'"totalActualRepayableAmount": "7999.08016896",' +
                +'"lastRepaymentDate": "2021-02-22T00:00:00",' +
                +'"repaymentDayofMonth": "22",' +
                +'"firstMonthRepaymentAmount": "166.64750352",' +
                +'"firstMonthExtraDays": "0"' +
                +'}';
        return response;
    }
}