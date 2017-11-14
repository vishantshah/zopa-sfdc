public class ApiCommandsFactory {
    public static final String MAKE_QUICK_PAY_COMMAND = 'Make_Quick_Pay';
    public static final String APPROVE_AND_WAVE_QUICK_PAY_COMMAND = 'Approve_and_Wave_Quick_Pay';
    public static final String APPROVE_AND_MAKE_FREE_QUICK_PAY_COMMAND = 'Approve_and_Make_Free_Quick_Pay';
    public static final String CANCEL_LOAN_COMMAND = 'Cancel_Loan';
    public static final String DECLINE_LOAN_COMMAND = 'Decline_Loan';
    public static final String BULK_APPROVE_LOAN_COMMAND = 'Bulk_Approve_Loan';
    public static final String DOCUMENT_LOAN_COMMAND = 'Loan_Documents';
    public static final String DOCUMENT_CLASSIFY_TYPE_COMMAND = 'Document_Classify_Type';
    public static final String LOAN_GET_COMMON_DATA_COMMAND = 'Loan_Get_Common_Data';
    public static final String CALCULATE_AFFORDABILITY_COMMAND = 'Calculate_Affordability';
    public static final String UPDATE_AFFORDABILITY_COMMAND = 'Update_Affordability';
    public static final String TAKE_CASE_OWNERSHIP = 'Take_Case_Ownership';
    public static final String LOAN_CONSOLIDATION_CANDIDATES = 'Loan_Consolidation_Candidates';
    public static final String LOAN_EQUIFAX = 'Loan_Equifax';
    public static final String LOAN_CALLCREDIT = 'Loan_CallCredit';
    public static final String UPLOAD_DOCUMENT_COMMAND = 'Upload_Document';
    public static final String VALIDATE_BANK_DETAILS_COMMAND = 'Validate_Bank_Details';
    public static final String LOAN_GET_REPAYMENTS = 'Loan_Repayments';
    public static final String LOAN_GET_LITIGATION_DETAILS = 'Loan_Litigation_Details';
    public static final String GET_LOAN_DETAILS = 'Loan_Details';
    public static final String CASE_SETTLEMENT_COLLECTIONS = 'Case_Settlement_Collections';
    public static final String LOAN_PUT_LITIGATION_DETAILS = 'Loan_Litigation_Details_Edit';
    public static final String GET_BANK_LOAN_DETAILS = 'Loan_Bank_Details';
    public static final String PUT_CONFIRM_DECEASED = 'Confirm_Deceased';
    public static final String PUT_CONFIRM_COLLECTIONS = 'Confirm_Collections';
    public static final String LOAN_SET_TO_WITHDRAWN = 'Loan_Set_To_Withdrawn';
    public static final String PUT_CONFIRM_DEFAULT = 'Confirm_Default';
    public static final String LOAN_GET_PAYMENT_PLANS = 'Loan_Get_Payment_Plans';
    public static final String LOAN_POST_PAYMENT_PLANS = 'Loan_Post_Payment_Plans';
    public static final String LOAN_PUT_PAYMENT_PLANS = 'Loan_Put_Payment_Plans';
    public static final String LOAN_SET_TO_ARRANGEMENT = 'Loan_Set_To_Arrangement';
    public static final String POST_CREATE_DIRECT_DEBIT = 'Create_Direct_Debit';
    public static final String GET_LOAN_NOTES = 'Loan_Notes';
    public static final String POST_VALIDATE_BANK_ACCOUNT = 'Validate_Bank_Account';
    public static final String PUT_COLLECTIONS_AGENCY = 'Collection_Agency_Cases';
    public static final String GET_COLLECTIONS_AGENCY = 'Get_Collection_Agency_Cases';
    public static final String GET_ALL_LETTER_TEMPLATES = 'Get_All_Letter_Templates';
    public static final String GET_LETTER_TEMPLATE = 'Get_Letter_Template';
    public static final String POST_LETTER_TEMPLATE = 'Post_Letter_Template';
    public static final String POST_COLLECTIONS_AGENCY = 'Post_Collection_Agency_Cases';
    public static final String PUT_STOP_COMMUNICATION_DATE = 'Update_Stop_Communication_Date';
    public static final String PUT_REVIEW_DATE = 'Update_Review_Date';
    public static final String BULK_POST_LETTER = 'Bulk_Post_Letter';
    public static final String GET_LETTER = 'Get_Letter';
    public static final String GET_ALL_LETTERS = 'Get_All_Letters';
    public static final String GET_LETTER_PREVIEW = 'Get_Letter_Preview';
    public static final String POST_LETTER = 'Post_Letter';

    private static ApiCommandsFactory self;
    @TestVisible private Map<String, Zopa_Api_Command__mdt> CommandInfo;

    public static ApiCommandsFactory getInstance() {
        if (self == null) {
            self = new ApiCommandsFactory();
        }
        return self;
    }

    private ApiCommandsFactory() {
        CommandInfo = new Map<String, Zopa_Api_Command__mdt>();
        for (Zopa_Api_Command__mdt command_info : [SELECT DeveloperName, Http_Method__c, Url_Mapping__c, Url_Mapping_Contains_Uuid__c, Name_of_the_mock_class__c, IsCollectionsCommand__c, Url_Mapping_Contains_Template_Name__c, Url_Mapping_Contains_Letter_Id__c, Url_Mapping_Contains_Letter_Send_Method__c FROM Zopa_Api_Command__mdt]) {
            CommandInfo.put(command_info.DeveloperName, command_info);
        }
    }

    public HttpResponse performApiCommandCallout(ApiCommandAbstractBuilder command_implementation) {
        try {
            Zopa_Api_Command__mdt command_info = CommandInfo.get(command_implementation.CommandName);
            Mock_Manager_for_Callout__c mock_manager_setting;
            if (!String.isBlank(command_info.Name_of_the_mock_class__c)){
                mock_manager_setting  = Mock_Manager_for_Callout__c.getValues(command_info.Name_of_the_mock_class__c);
            }
            if (!Test.isRunningTest()){
                if (mock_manager_setting != null && mock_manager_setting.Is_Enable_Mock__c == true) {
                    HttpCalloutMock mock_instance = (HttpCalloutMock)Type.forName(command_info.Name_of_the_mock_class__c).newInstance();
                    HTTPRequest http_request = new HTTPRequest();
                    http_request.setMethod(command_info.Http_Method__c);
                    command_implementation.HttpApiResponse = mock_instance.respond(http_request);
                    command_implementation.handleCommandResponse();
                    return command_implementation.HttpApiResponse;
                }
            }
            if(command_info.Http_Method__c != 'GET'){
                command_implementation.setBody();
            }
            return command_implementation
                             .setMethod(command_info.Http_Method__c)
                             .setHeader('X-Correlation-Id', generateXCorrelationId())
                             .setHeader('X-Zopa-User-Id', getFederationIdentifier())
                             .setHeader('Content-Type', 'application/json')
                             .setOAuthHeader(command_info)
                             .setHeaders()
                             .setTimeout()
                             .setEndpoint(buildEndpoint(command_info, command_implementation))
                             .sendRequest();
        } catch (CalloutException e){
            command_implementation.CommandSuccessful = false;
            command_implementation.CommandError = e.getMessage();
        }
        return null;
    }

    private String getFederationIdentifier(){
        String federation_id = [SELECT FederationIdentifier FROM User WHERE Id =: UserInfo.getUserId()].FederationIdentifier;
        if(federation_id == null){
            federation_id = '';
        }
        return federation_id;
    }

    private String buildEndpoint(Zopa_Api_Command__mdt command_info, ApiCommandAbstractBuilder command_implementation) {
        String endpoint = getEndpointByCommandType(command_info);
        if (command_info.Url_Mapping_Contains_Uuid__c) {
            endpoint = endpoint.replace('{id}', command_implementation.RecordUuid);
        }
        if (command_info.Url_Mapping_Contains_Template_Name__c) {
            endpoint = endpoint.replace('{templateName}', command_implementation.TemplateName);
        }
        if (command_info.Url_Mapping_Contains_Letter_Id__c) {
            endpoint = endpoint.replace('{letterId}', command_implementation.LetterId);
        }
        if (command_info.Url_Mapping_Contains_Letter_Send_Method__c) {
            endpoint = endpoint.replace('{sendMethod}', command_implementation.SendMethod);
        }
        return endpoint;
    }

    private String getEndpointByCommandType(Zopa_Api_Command__mdt command_info){
        if(command_info.IsCollectionsCommand__c){
            return 'callout:Zopa_API_Collections_Endpoint' + command_info.Url_Mapping__c;
        }
        return 'callout:Zopa_API_Endpoint' + command_info.Url_Mapping__c;
    }

    private String getActualXApiKey() {
        return TestCustomSettings.getZopaAPISecurityCS().X_Api_Key_Header__c;
    }

    private static String generateXCorrelationId() {
        String hex = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
        String y = getRandomYDigitForXCorrelationId(hex);
        return hex.SubString(0,8)+ '-' + hex.SubString(8,12) + '-4' + hex.SubString(13,16) + '-' + y + hex.SubString(17,20) + '-' + hex.substring(20);
    }

    private static String getRandomYDigitForXCorrelationId(String hex) {
        Set<String> set_to_choose_of = new Set<String>{'8', '9', 'a', 'b'};
        Integer i = 0;
        String y;
        do {
            y = hex.substring(i, i + 1);
            i = i + 1;
        } while (!set_to_choose_of.contains(y) && i < hex.length());
        if (!set_to_choose_of.contains(y)) {
            y = '8';
        }
        return y;
    }

    public abstract class ApiCommandAbstractBuilder {
        @TestVisible protected HttpRequest HttpApiRequest;
        protected HttpResponse HttpApiResponse;
        public String CommandName;
        public String RecordUuid;
        public String TemplateName;
        public String LetterId;
        public String SendMethod;
        public Boolean CommandSuccessful;
        public String CommandError;

        public ApiCommandAbstractBuilder(String command_name) {
            CommandName = command_name;
            HttpApiRequest = new HttpRequest();
        }

        public ApiCommandAbstractBuilder(String command_name, String record_uuid) {
            CommandName = command_name;
            RecordUuid = record_uuid;
            HttpApiRequest = new HttpRequest();
        }

        @TestVisible protected virtual String buildJsonBody(){
            return '';
        }

        protected virtual Map<String, String> buildMapHeaders() {
            return new Map<String, String>();
        }

        protected ApiCommandAbstractBuilder setMethod(String method) {
            HttpApiRequest.setMethod(method);
            return this;
        }

        protected virtual ApiCommandAbstractBuilder setBody() {
            HttpApiRequest.setBody(buildJsonBody());
            return this;
        }

        protected virtual ApiCommandAbstractBuilder setEndpoint(String endpoint) {
            HttpApiRequest.setEndpoint(endpoint);
            return this;
        }

        protected virtual ApiCommandAbstractBuilder setTimeout() {
            HttpApiRequest.setTimeout(120000);
            return this;
        }

        private void handleCommandResponse(){
            if (HttpApiResponse.getStatusCode() >= 200 &&  HttpApiResponse.getStatusCode() < 300) {
                CommandSuccessful = true;
            } else if (HttpApiResponse.getStatusCode() == 403){
                CommandError = 'Access Denied. Please ask administrator to check credentials.';
                CommandSuccessful = false;
            } else if (HttpApiResponse.getStatusCode() == 404) {
                try {
                    String error_message = (String)((Map<String, Object>)JSON.deserializeUntyped(HttpApiResponse.getBody())).get('message');
                    CommandError = 'Request error: ' + error_message;
                } catch (Exception e){
                    if(String.isNotBlank(HttpApiResponse.getBody())) {
                        CommandError = 'Request error: ' + HttpApiResponse.getBody();
                    } else {
                        CommandError = 'Request error: NOT FOUND';
                    }
                }
                CommandSuccessful = false;
            } else if(HttpApiResponse.getStatusCode() == 500){
                try {
                    String error_message = (String)((Map<String, Object>)JSON.deserializeUntyped(HttpApiResponse.getBody())).get('message');
                    CommandError = 'Internal Server Error: ' + error_message;
                } catch (Exception e){
                    CommandError = 'Internal Server Error: ' + HttpApiResponse.getBody();
                }
                CommandSuccessful = false;
            } else {
                try{
                    CommandError = 'Request error: ' + (String)((Map<String, Object>)JSON.deserializeUntyped(HttpApiResponse.getBody())).get('message');
                } catch (Exception e) {
                    CommandError = 'Request error: ' + HttpApiResponse.getBody();
                }
                CommandSuccessful = false;
            }
        }

        protected ApiCommandAbstractBuilder setHeaders() {
            Map<String, String> headers = buildMapHeaders();
            for(String headerName: headers.keySet()){
                HttpApiRequest.setHeader(headerName, headers.get(headerName));
            }
            return this;
        }

        protected ApiCommandAbstractBuilder setOAuthHeader(Zopa_Api_Command__mdt command_info) {
            if(TestCustomSettings.getZopaAPISecurityCS().Use_OAuth__c){
                String access_token = OAuthZopa.getOAuthToken(command_info);
                HttpApiRequest.setHeader('Authorization', 'Bearer ' + access_token);
            }
            return this;
        }

        protected ApiCommandAbstractBuilder setHeader(String key, String value) {
            HttpApiRequest.setHeader(key, value);
            return this;
        }

        protected HttpResponse sendRequest() {
            System.debug('HttpApiRequest: ' + HttpApiRequest);
            System.debug('Body: ' + HttpApiRequest.getBody());
            System.debug('X-Correlation-Id: ' + HttpApiRequest.getHeader('X-Correlation-Id'));
            System.debug('X-Zopa-User-Id: ' + HttpApiRequest.getHeader('X-Zopa-User-Id'));
            try{
                HttpApiResponse = new Http().send(HttpApiRequest);
                System.debug('HttpApiResponse: ' + HttpApiResponse);
                System.debug('Response Body: ' + HttpApiResponse.getBody());
            }catch(Exception e){
                System.debug('Request Exception: ' + e.getMessage());
                HttpApiResponse = ApiCommandTestMock.getInternalErrorResponse();
            }
            handleCommandResponse();
            return HttpApiResponse;
        }

        public String getResponseBody() {
            return HttpApiResponse.getBody();
        }
    }
}