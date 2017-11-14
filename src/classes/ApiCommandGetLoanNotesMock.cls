global class ApiCommandGetLoanNotesMock implements HttpCalloutMock {
    private Boolean IsSuccess;
    private Integer ErrorCode;
    private static Integer CounterRecords;

    public ApiCommandGetLoanNotesMock(Boolean is_success, Integer error_code) {
        this(is_success,error_code,4);
    }

    public ApiCommandGetLoanNotesMock(Boolean is_success, Integer error_code, Integer counter_records) {
        IsSuccess = is_success;
        ErrorCode = error_code;
        CounterRecords = counter_records;
    }

    public ApiCommandGetLoanNotesMock(){
        this(true,200,4);
    }

    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('GET', request.getMethod(),'Request must be GET method');
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
        if (CounterRecords == 4) {
            http_response.setBody(getMockResponceBody());
        } else {
            http_response.setBody(getMockResponceBody(CounterRecords));
        }
        return http_response;
    }

    public static String getMockResponceBody(){
        String response =
                '['
                    +'{'+
                      +'"createdDate": "2015-05-05T00:00:00",'+
                      +'"createdBy": "Daffy Duck",'+
                      +'"text": "You\'d never catch that rabbit doing something this heroic."'+
                    +'}'
                    +','
                    +'{'+
                      +'"createdDate": "2015-05-05T00:00:00",'+
                      +'"createdBy": "Bugs Bunny",'+
                      +'"text": "Eh, what\'s up, duck?"'+
                    +'}'
                    +','
                    +'{'+
                      +'"createdDate": "2015-05-05T00:00:00",'+
                      +'"createdBy": "Daffy Duck",'+
                      +'"text": "You\'re dethpicable."'+
                    +'}'
                    +','
                    +'{'+
                      +'"createdDate": "2015-05-05T00:00:00",'+
                      +'"createdBy": "Bugs Bunny",'+
                      +'"text": "Promenade across the floor, sashay right on out the door, out the door and into the glade,'
                      +' and everybody promenade. Step right up, you\'re doin\' fine; I\'ll pull your beard, you pull mine;'
                      +' yank it again like you did before, break it up with a tug of war. Now into the creek and fish for the trout,'
                      +' dive right in and flap about; trout, trout, pretty little trout; one more splash and come right out.'
                      +' Shake like a hound dog, shake again, wallow around in the old pigpen, wallow some more, you all know how;'
                      +' roll around like an old fat sow. Allemande left with your left hand, follow through with a right and left brand;'
                      +' now lead your partner, the dirty old thing; follow through with an elbow swing.'
                      +' Grab a fencepost hold it tight, whomp your partner with all your might; hit him in the shin, hit him in the head;'
                      +' hit him again, the critter ain\'t dead. Whomp him low and whomp him high, stick your finger in his eye.'
                      +' Pretty little rhythm, pretty little sound; bang your heads against the ground.'
                      +' Promenade all around the room, promenade like a bride and groom.'
                      +' Open up the door and step right in, close the door and into a spin.'
                      +' Whirl, whirl, twist and twirl, jump all around like a flying squirrel.'
                      +' Now, don\'t you cuss and don\'t you swear, just come right out and form a square.'
                      +' Now right hand over and left hand under, both join hands and run like thunder; over the hill and over the dale.'
                      +' Duck your head and lift your tail. Don\'t you stray and don\'t you roam, turn around and promenade home.'
                      +' Corn in the crib and wheat in the sack, turn your partner and promenade back."'
                    +'}'
                +']';
        return response;
    }

    public static String getMockResponceBody(Integer counter_records){
        String response = '[';
        String simple_record = '{'+
                      +'"createdDate": "2015-05-05T00:00:00",'+
                      +'"createdBy": "Daffy Duck",'+
                      +'"text": "You\'re dethpicable."'+
                    +'},';
        for (Integer i = 0; i < counter_records; i++){
            response += simple_record;
        }
        response += ']';
        return response.replace(',]',']');
    }

}