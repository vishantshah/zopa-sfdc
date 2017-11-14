global class ApiCommandPutStopCommunicationDateMock  implements HttpCalloutMock {
    private Boolean IsSuccess;

    global ApiCommandPutStopCommunicationDateMock() {
        IsSuccess = true;
    }

    global ApiCommandPutStopCommunicationDateMock(Boolean is_success) {
        IsSuccess = is_success;
    }

    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('PUT', request.getMethod(),'Request must be PUT method');
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
        return http_response;
    }
}