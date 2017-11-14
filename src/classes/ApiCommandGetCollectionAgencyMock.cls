global class ApiCommandGetCollectionAgencyMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    private Integer ErrorCode;

    public ApiCommandGetCollectionAgencyMock(Boolean is_success, Integer error_code) {
        IsSuccess = is_success;
        ErrorCode = error_code;
    }

    public ApiCommandGetCollectionAgencyMock(){
        this(true,200);
    }

    global HTTPResponse respond(HTTPRequest request) {
        if(request.getMethod() == 'PUT' || request.getMethod() == 'POST'){
            return ApiCommandTestMock.getSuccessResponse();
        }
        System.assertEquals('GET', request.getMethod(),'Request must be GET method');
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse();
        } else {
            response = getInternalErrorResponse(ErrorCode);
        }
        return response;
    }

     private static HttpResponse getInternalErrorResponse(Integer error_code) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(error_code);
        http_response.setStatus('Salesforce Internal Error');
        http_response.setBody('{"message":"Internal Error"}');
        return http_response;
    }

    private static HttpResponse getSuccessResponse() {
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
                      +'"collectionsAgencyCaseId": "5cdec311-7a2f-47e1-b875-a040c0f35a5a",'+
                      +'"collectionsAgencyId": "d90e9b3b-6bbb-4f29-99b5-5b40ce52aee4",'+
                      +'"state": "Open",'+
                      +'"currentCollectionsAmount": 1200.03,'+
                      +'"previousCollectionsAmount": 1300.03,'+
                      +'"comments": "Arbitrary comment",'+
                      +'"createdDate": "2017-01-10T00:00:00",'+
                      +'"currentCollectionsAmountUpdateTime": "2017-03-01T00:00:00",'+
                      +'"prevCollectionsAmountUpdateTime": "2017-02-01T00:00:00",'+
                      +'"defaultedDate": "2017-01-01T00:00:00",'+
                      +'"referred": false'+
                    +'}'
                    +','
                    +'{'+
                      +'"collectionsAgencyCaseId": "84b78216-4fff-4581-bb49-9be42a99d061",'+
                      +'"collectionsAgencyId": "3de1b7d4-9ea7-42a4-a7e1-bbad4389095d",'+
                      +'"state": "Closed",'+
                      +'"currentCollectionsAmount": 1200.03,'+
                      +'"previousCollectionsAmount": 1300.03,'+
                      +'"comments": "Arbitrary comment",'+
                      +'"createdDate": "2017-01-10T00:00:00",'+
                      +'"currentCollectionsAmountUpdateTime": "2017-03-01T00:00:00",'+
                      +'"prevCollectionsAmountUpdateTime": "2017-02-01T00:00:00",'+
                      +'"defaultedDate": "2017-01-01T00:00:00",'+
                      +'"referred": false'+
                    +'}'
                    +','
                   +'{'+
                      +'"collectionsAgencyCaseId": "d31843cf-eb64-41d8-997e-f3deb86928da",'+
                      +'"collectionsAgencyId": "83e4cc91-49a8-42d8-8cb9-a876826600a2",'+
                      +'"state": "Closed",'+
                      +'"currentCollectionsAmount": 1200.03,'+
                      +'"previousCollectionsAmount": 1300.03,'+
                      +'"comments": "Arbitrary comment",'+
                      +'"createdDate": "2017-01-10T00:00:00",'+
                      +'"currentCollectionsAmountUpdateTime": "2017-03-01T00:00:00",'+
                      +'"prevCollectionsAmountUpdateTime": "2017-02-01T00:00:00",'+
                      +'"defaultedDate": "2017-01-01T00:00:00",'+
                      +'"referred": false'+
                    +'}'
                +']';
        return response;
    }
}