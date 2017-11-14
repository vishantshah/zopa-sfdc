global class ApiDocumentsTestMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    private Integer ErrorCode;
    private Boolean IsEmptyBody;

    global ApiDocumentsTestMock(Boolean is_success, Integer error_code, Boolean is_empty_body) {
        IsSuccess = is_success;
        ErrorCode = error_code;
        IsEmptyBody = is_empty_body;
    }

    global ApiDocumentsTestMock(){
        this(true,200,false);
    }

    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('GET', request.getMethod(),'Request must be GET method');
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse(IsEmptyBody);
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

    public static HttpResponse getSuccessResponse(Boolean is_empty_body) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        if(!is_empty_body){
            http_response.setBody(getMockResponceBody());
        } else {
            http_response.setBody('[]');
        }
        return http_response;
    }

    private static String getMockResponceBody(){
        String response = '[{'+
                  +'"id": "ccb86324-627f-4288-ae4c-bb30e22b80a9",'+
                  +'"filename": "jesper1",'+
                  +'"uploadTime": "2016-10-19T18:49:00.000+01:00",'+
                  +'"tamperTrafficLightScore": "green",'+
                 +'"tamperData": "{    \"Creator\": \"[\'barclays\', \'l linux\']\",    \"tc_blacklisted_creator\": false,    \"tc_document_has_ancestors\": null,    \"tc_is_encrypted\": false,    \"tc_no_metadata\": false  }\"",'+
                  +'"documentType": "BankStatement"'+
                +'},'+
                +'{'+
                  +'"id": "6a6a6299-941a-483a-8b9f-b13cf83338ec",'+
                  +'"filename": "jesper2",'+
                  +'"uploadTime": "2016-10-19T18:49:00.000+01:00",'+
                  +'"tamperTrafficLightScore": "red",'+
                  +'"tamperData": "{    \"Creator\": null,    \"tc_blacklisted_creator\": false,    \"tc_dim_mod2\": true,    \"tc_dim_mod8\": false,    \"tc_document_has_ancestors\": null,    \"tc_has_modification_history\": null,    \"tc_metadata_date_after_creation\": null,    \"tc_modification_after_creation\": null,    \"tc_no_metadata\": true,    \"tc_num_pixels\": 1000500  }\"",'+
                  +'"documentType": "IdCheck"'+
                +'},'+
                +'{'+
                 +' "id": "aa09515d-9f44-4d8b-800b-e03b6ee148ea",'+
                  +'"filename": "jesper3",'+
                  +'"uploadTime": "2016-10-19T18:49:00.000+01:00",'+
                  +'"tamperTrafficLightScore": null,'+
                  +'"tamperData": null,'+
                  +'"documentType": "Payslip"'+
                +'}]';
        return response;
    }
}