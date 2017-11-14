global class ScheduleUpdateZopaOAuth implements Schedulable{
    private final static List<String> ACCESS_TOKEN_FIELDS_UNDERWRITING = new List<String> {'Access_Token1__c', 'Access_Token2__c', 'Access_Token3__c', 'Access_Token4__c'};
    private final static List<String> ACCESS_TOKEN_FIELDS_COLLECTIONS = new List<String> {'Access_Token_Collections1__c', 'Access_Token_Collections2__c', 'Access_Token_Collections3__c', 'Access_Token_Collections4__c'};
    public static String TokenCollections;
    public static String TokenUnderwriting;
    private static Boolean IsSuccessCollections = true;
    private static Boolean IsSuccessUnderwriting = true;

    global void execute(SchedulableContext SC) {
        getNewOAuthToken();
    }

    @TestVisible
    @Future(callout=true)
    private static void getNewOAuthToken(){
        Zopa_API_Security__c api_setting = TestCustomSettings.getZopaAPISecurityCS();
        OAuthResponse token_response_underwriting =getOAuthResponseUnderwriting(api_setting);
        OAuthResponse token_response_collections = getOAuthResponseCollections(api_setting);
        if(IsSuccessCollections){
            storeNewToken(token_response_collections.Access_token, token_response_collections.Expires_in, ACCESS_TOKEN_FIELDS_COLLECTIONS);
        }
        if(IsSuccessUnderwriting){
            storeNewToken(token_response_underwriting.Access_token, token_response_underwriting.Expires_in, ACCESS_TOKEN_FIELDS_UNDERWRITING);
        }
    }

    private static OAuthResponse getOAuthResponseCollections(Zopa_API_Security__c api_setting){
        OAuthResponse token_response_collections;
        try{
            HTTPRequest oauth_request_collections = getRequestForGetOAuth(api_setting.OAuth_Client_Id_Collections__c, api_setting.OAuth_Client_Secret_Collections__c, api_setting.Grant_Type_Collections__c, api_setting.Scope_Collections__c);
            token_response_collections = handleGetNewOAuthTokenResponce(oauth_request_collections);
            TokenCollections = token_response_collections.Access_token;
        }catch(Exception ex){
            IsSuccessCollections = false;
            System.debug('Faild to get token for Collections. ' + ex.getMessage());
        }
        return token_response_collections;
    }

    private static OAuthResponse getOAuthResponseUnderwriting(Zopa_API_Security__c api_setting){
        OAuthResponse token_response_underwriting;
        try{
            HTTPRequest oauth_request_underwring = getRequestForGetOAuth(api_setting.OAuth_Client_Id__c, api_setting.OAuth_Client_Secret__c, api_setting.Grant_Type__c, api_setting.Scope__c);
            token_response_underwriting = handleGetNewOAuthTokenResponce(oauth_request_underwring);
            TokenUnderwriting = token_response_underwriting.Access_token;
        }catch(Exception ex){
            IsSuccessUnderwriting = false;
            System.debug('Faild to get token for Underwriting. ' + ex.getMessage());
        }
        return token_response_underwriting;
    }

    private static OAuthResponse handleGetNewOAuthTokenResponce(HTTPRequest oauth_request){
        HTTP http = new HTTP();
        HTTPResponse oauth_response;
        OAuthResponse token_response;

        if(Test.isRunningTest()){
            oauth_response = OAuthZopaTestMock.respond(oauth_request);
        } else {
            oauth_response = http.send(oauth_request);
        }
        if(oauth_response.getStatusCode() != 200){
            throw new CalloutException('Error authenticating against the Zopa API ' + oauth_response.getBody());
        }
        token_response = (OAuthResponse)System.JSON.deserialize(oauth_response.getBody(), OAuthResponse.class);
        if(token_response.Access_token == null){
            throw new CalloutException('Can\'t get authentication token from Zopa API');
        }
        return token_response;
    }

    private static HTTPRequest getRequestForGetOAuth(String client_id, String client_secret, String grant_type, String scope){
        HTTPRequest oauth_request = new HTTPRequest();
        oauth_request.setEndpoint('callout:Zopa_OAuth/oauth/connect/token');
        oauth_request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        oauth_request.setMethod('POST');
        String request_body = 'client_id=' + EncodingUtil.urlEncode(client_id, 'UTF-8') + '&client_secret=' + EncodingUtil.urlEncode(client_secret, 'UTF-8') + '&grant_type='+ EncodingUtil.urlEncode(grant_type, 'UTF-8') +'&scope='+EncodingUtil.urlEncode(scope, 'UTF-8');
        oauth_request.setBody(request_body);
        return oauth_request;
    }


    private static void storeNewToken(String new_token, Integer expires_in, List<String> fields_to_store_token){
        Zopa_API_Security__c api_setting = TestCustomSettings.getZopaAPISecurityCS();
        Integer reduce_time_to_ensure_token_is_valid = 60;
        DateTime access_token_expiry_date = DateTime.now().addSeconds(expires_in).addSeconds(-reduce_time_to_ensure_token_is_valid);
        api_setting.Access_Token_Expiry_Date__c = access_token_expiry_date;
        for(String access_token_field : fields_to_store_token) {
            api_setting.put(access_token_field, null);
        }
        String access_token_to_write = new_token;
        Integer field_index;
        for(field_index = 0; access_token_to_write.length() > 255; field_index++) {
            String access_token_field = fields_to_store_token.get(field_index);
            String part_of_access_token = access_token_to_write.substring(0, 255);
            api_setting.put(access_token_field, part_of_access_token);
            access_token_to_write = access_token_to_write.substring(255);
        }
        String access_token_field = fields_to_store_token.get(field_index);
        api_setting.put(access_token_field, access_token_to_write);
        TestCustomSettings.saveCustomSettings(api_setting);
    }

    public class OAuthResponse{
        public String Access_token;
        public Integer Expires_in;
    }
}