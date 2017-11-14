global class ApiCommandLetterTemplatesTestMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    public enum CommandsName {
        GET_ALL_LETTER_TEMPLATES,
        GET_LETTER_TEMPLATE
    }
    public CommandsName SelectedCommand;

    public ApiCommandLetterTemplatesTestMock() {
        IsSuccess = true;
        SelectedCommand = CommandsName.GET_ALL_LETTER_TEMPLATES;
    }

    public ApiCommandLetterTemplatesTestMock(Boolean is_success, CommandsName command_name) {
        IsSuccess = is_success;
        SelectedCommand = command_name;
    }

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response;
        if (IsSuccess) {
            response = getSuccessResponse(SelectedCommand);
        } else {
            response = getInternalErrorResponse(500);
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

    public static HttpResponse getSuccessResponse(CommandsName command_name) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        if(command_name == CommandsName.GET_ALL_LETTER_TEMPLATES){
            http_response.setBody(getMockResponseBodyGetAllTemplates());
        } else if(command_name == CommandsName.GET_LETTER_TEMPLATE){
            http_response.setBody(getMockResponseBodyGetTemplate());
        }
        return http_response;
    }

    public static String getMockResponseBodyGetAllTemplates(){
        String response = '[{"id":1,"name":"Collections1","friendlyName":"Collections 1","version":1,"html":"<h1>This is a heading</h1>","createdDate":"2017-04-08T14:57:06.971812+01:00"},'+
                +'{"id":2,"name":"Collections2","friendlyName":"Collections 2","version":1,"html":null,"createdDate":"2017-04-08T14:57:06.971812+01:00"},'+
                +'{"id":3,"name":"Collections3","friendlyName":"Collections 3","version":1,"html":null,"createdDate":"2017-04-08T14:57:06.971812+01:00"},'+
                +'{"id":4,"name":"DDCollectionOfArrears","friendlyName":"DD Collection of Arrears","version":1,"html":null,"createdDate":"2017-04-08T14:57:06.971812+01:00"},'+
                +'{"id":5,"name":"ConfirmationOfArrangement","friendlyName":"Confirmation of Arrangement","version":1,"html":null,"createdDate":"2017-04-08T14:57:06.971812+01:00"},'+
                +'{"id":6,"name":"CancellationOfArrangement","friendlyName":"Cancellation of Arrangement","version":1,"html":null,"createdDate":"2017-04-08T14:57:06.971812+01:00"},'+
                +'{"id":7,"name":"ReviewOfArrangement","friendlyName":"Review of Arrangement","version":1,"html":null,"createdDate":"2017-04-08T14:57:06.971812+01:00"},'+
                +'{"id":8,"name":"NOSA1","friendlyName":"NOSA 1","version":1,"html":null,"createdDate":"2017-04-08T14:57:06.971812+01:00"},'+
                +'{"id":13,"name":"NOSA2","friendlyName":"NOSA 2","version":2,"html":null,"createdDate":"2017-05-08T14:57:06.971812+01:00"},'+
                +'{"id":10,"name":"NoticeOfDefault","friendlyName":"Notice of Default","version":1,"html":null,"createdDate":"2017-04-08T14:57:06.971812+01:00"},'+
                +'{"id":11,"name":"Formal Demand","friendlyName":"Formal Demand","version":1,"html":null,"createdDate":"2017-04-08T14:57:06.971812+01:00"},'+
                +'{"id":12,"name":"FinancialDifficulties","friendlyName":"Financial Difficulties","version":1,"html":null,"createdDate":"2017-04-08T14:57:06.971812+01:00"}]';
        return response;
    }


    public static String getMockResponseBodyGetTemplate(){
        String response = '{'+
                  +'"id": 0,'+
                  +'"name": "test",'+
                  +'"friendlyName": "test",'+
                  +'"version": 1,'+
                  +'"html": "htmlhtml",'+
                  +'"createdDate": "2017-05-16T08:02:37.087Z"'+
                +'}';
        return response;
    }
}