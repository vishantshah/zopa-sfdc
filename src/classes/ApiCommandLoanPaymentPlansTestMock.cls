global class ApiCommandLoanPaymentPlansTestMock  implements HttpCalloutMock{
    private Boolean IsSuccess;
    private Boolean NoActivePlan;

    global ApiCommandLoanPaymentPlansTestMock(Boolean is_success, Boolean no_active_plan) {
        IsSuccess = is_success;
        NoActivePlan = no_active_plan;
    }

    global ApiCommandLoanPaymentPlansTestMock(Boolean is_success) {
        IsSuccess = is_success;
        NoActivePlan = false;
    }

    global ApiCommandLoanPaymentPlansTestMock() {
        IsSuccess = true;
        NoActivePlan = false;
    }

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse(request.getMethod() == 'GET', NoActivePlan);
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

    public static HttpResponse getSuccessResponse(Boolean need_body, Boolean no_active_plan) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        if(need_body){
            http_response.setBody(no_active_plan ? getTestJsonBodyNoActivePlan() : getTestJsonBodyWithActivePlan());
        }
        return http_response;
    }

    public static String getTestJsonBodyWithActivePlan() {
        String json =  '[{'+
                  +'"paymentPlanId": "2a961acf-fe97-479d-8ed9-ab8d04966736",'+
                  +'"duration": "ThreeMonths",'+
                  +'"arrangement": "Zopa",'+
                  +'"createdDate": "2017-01-01T12:00:00",'+
                  +'"amount": "120.12",'+
                  +'"frequency": "Monthly",'+
                  +'"paymentDay": "10",'+
                  +'"method": "BACS",'+
                  +'"arrearsReason": "Mismanagement",'+
                  +'"state": "Active",'+
                  +'"endDate": null'+
                  +'},' +
                  + '{'+
                  +'"paymentPlanId": "30478660-51ca-49fd-91b7-85f84898eb79",'+
                  +'"duration": "LongTerm",'+
                  +'"arrangement": "DMA",'+
                  +'"createdDate": "2017-02-01T00:00:00",'+
                  +'"amount": "210.21",'+
                  +'"frequency": "Monthly",'+
                  +'"paymentDay": "12",'+
                  +'"method": "Cheque",'+
                  +'"arrearsReason": "Overcommitted",'+
                  +'"state": "Failed",'+
                  +'"endDate": "2018-03-02T00:00:00"'+
                  +'},'+
                  +'{'+
                  +'"paymentPlanId": "4e5540f0-7c00-4139-a154-c1c5bdffcb80",'+
                  +'"duration": "SixMonths",'+
                  +'"arrangement": "Zopa",'+
                  +'"createdDate": "2016-02-01T00:00:00",'+
                  +'"amount": "320.32",'+
                  +'"frequency": "Monthly",'+
                  +'"paymentDay": "21",'+
                  +'"method": "DebitCard",'+
                  +'"arrearsReason": "Sickness",'+
                  +'"state": "Completed",'+
                  +'"endDate": "2017-03-02T00:00:00"'+
                  +'}]';

        return json;
    }

    public static String getTestJsonBodyNoActivePlan() {
        String json =  '[{'+
                  +'"paymentPlanId": "2a961acf-fe97-479d-8ed9-ab8d04966736",'+
                  +'"duration": "ThreeMonths",'+
                  +'"arrangement": "Other",'+
                  +'"createdDate": "2017-01-01T00:00:00",'+
                  +'"amount": "120.12",'+
                  +'"frequency": "Monthly",'+
                  +'"paymentDay": "10",'+
                  +'"method": "BACS",'+
                  +'"arrearsReason": "Mismanagement",'+
                  +'"state": "Completed",'+
                  +'"endDate": "2018-03-02T00:00:00"'+
                  +'},' +
                  + '{'+
                  +'"paymentPlanId": "30478660-51ca-49fd-91b7-85f84898eb79",'+
                  +'"duration": "LongTerm",'+
                  +'"arrangement": "DMA",'+
                  +'"createdDate": "2017-02-01T00:00:00",'+
                  +'"amount": "210.21",'+
                  +'"frequency": "Monthly",'+
                  +'"paymentDay": "12",'+
                  +'"method": "Cheque",'+
                  +'"arrearsReason": "Overcommitted",'+
                  +'"state": "Failed",'+
                  +'"endDate": "2018-03-02T00:00:00"'+
                  +'},'+
                  +'{'+
                  +'"paymentPlanId": "4e5540f0-7c00-4139-a154-c1c5bdffcb80",'+
                  +'"duration": "SixMonths",'+
                  +'"arrangement": "Zopa",'+
                  +'"createdDate": "2016-02-01T00:00:00",'+
                  +'"amount": "320.32",'+
                  +'"frequency": "Monthly",'+
                  +'"paymentDay": "21",'+
                  +'"method": "DebitCard",'+
                  +'"arrearsReason": "Sickness",'+
                  +'"state": "Completed",'+
                  +'"endDate": "2017-03-02T00:00:00"'+
                  +'}]';

        return json;
    }

    public static String getTestEmptyJsonBody() {
        String json = '[]';

        return json;
    }
}