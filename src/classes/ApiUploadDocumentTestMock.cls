global class  ApiUploadDocumentTestMock implements HttpCalloutMock{
    private Boolean IsSuccess;
    private Integer ErrorCode;

    global ApiUploadDocumentTestMock(Boolean is_success, Integer error_code){
        IsSuccess = is_success;
        ErrorCode = error_code;
    }

    global ApiUploadDocumentTestMock(){
        this(true, 200);
    }

     global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('POST', request.getMethod(),'Request must be POST method');
        System.assert(request.getBody().length() != 0, 'Body should not be null');

        HttpResponse response = new HttpResponse();
        if (IsSuccess) {
            response.setStatusCode(200);
            response.setStatus('OK');
        } else {
            response.setStatusCode(ErrorCode);
            response.setStatus('Salesforce Internal Error');
        }
        return response;
    }
}