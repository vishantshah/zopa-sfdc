public class OAuthZopa {

    private final static List<String> ACCESS_TOKEN_FIELDS = new List<String> {'Access_Token1__c', 'Access_Token2__c', 'Access_Token3__c', 'Access_Token4__c'};

    public static String getOAuthToken(Zopa_Api_Command__mdt command_info){
        if(command_info.IsCollectionsCommand__c){
            return getTokenFromSettingsCollections();
        }
        return getTokenFromSettingsUnderwriting();
    }

    @TestVisible private static String getTokenFromSettingsUnderwriting(){
        Zopa_API_Security__c api_setting = TestCustomSettings.getZopaAPISecurityCS();
        return getTokenPart(api_setting.Access_Token1__c) +  getTokenPart(api_setting.Access_Token2__c) +  getTokenPart(api_setting.Access_Token3__c) +  getTokenPart(api_setting.Access_Token4__c);
    }

    @TestVisible private static String getTokenFromSettingsCollections(){
        Zopa_API_Security__c api_setting = TestCustomSettings.getZopaAPISecurityCS();
        return getTokenPart(api_setting.Access_Token_Collections1__c) +  getTokenPart(api_setting.Access_Token_Collections2__c) +  getTokenPart(api_setting.Access_Token_Collections3__c) +  getTokenPart(api_setting.Access_Token_Collections4__c);
    }

    private static String getTokenPart(String token_part){
        if(token_part == null){
            return '';
        }
        return token_part;
    }
}