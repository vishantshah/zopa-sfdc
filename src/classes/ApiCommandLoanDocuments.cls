public class ApiCommandLoanDocuments extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    public ApiCommandLoanDocuments(String uuid) {
        super(ApiCommandsFactory.DOCUMENT_LOAN_COMMAND, uuid);
    }

    public class LoanDocumentsResponse {
        public String Id {public get; public set;}
        public String FileName {public get; public set;}
        public String UploadTime {public get; public set{
                UploadTime = ApiCommandParserDateTime.parseDateTime(value);
            }
        }
        public String TamperData {public get; public set;}
        public String TamperTrafficLightScore {public get; public set{
            TamperTrafficLightScore = '';
            if(value == 'green'){
                TamperTrafficLightScore = '/img/msg_icons/confirm16.png';
            }
            if(value == 'yellow'){
                TamperTrafficLightScore = '/img/msg_icons/warning16.png';
            }
            if(value == 'red'){
                TamperTrafficLightScore = '/img/msg_icons/error16.png';
            }
            }
        }
        public String DocumentType {public get; public set;}
        public String TamperDetailsUrl {public get; public set;}
        public String DocumentUrl {public get; public set;}
    }
}