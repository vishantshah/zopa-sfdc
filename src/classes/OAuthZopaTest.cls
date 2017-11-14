@isTest
private class OAuthZopaTest {

    static testMethod void getOAuthTokenWithCustomSettingsCollections(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.updateOAuthCustomSettings(false);
            Test.startTest();
                String token = OAuthZopa.getTokenFromSettingsCollections();
            Test.stopTest();
            String expected_token = 'OiJKV1QiLCJhbGc2BsaWNhdG200YWV2iJKV1QiLCJh2';
            System.assertEquals(expected_token, token, 'Didn\'t get the OAuth expected token');
        }
    }

    static testMethod void getOAuthTokenWithCustomSettingsUnderwriting(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.updateOAuthCustomSettings(false);
            Test.startTest();
                String token = OAuthZopa.getTokenFromSettingsUnderwriting();
            Test.stopTest();
            String expected_token = 'OiJKV1QiLCJhbGcBsaWNhdG00YWViJKV1QiLCJh';
            System.assertEquals(expected_token, token, 'Didn\'t get the OAuth expected token');
        }
    }


    public class SetupDataClass{
        public User TestUser {get; private set;}

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'OAuthZopaTest' AND LastName = 'OAuthZopaTest' LIMIT 1];
        }

        public void updateOAuthCustomSettings(Boolean token_expired){
            Zopa_API_Security__c api_setting = TestCustomSettings.getZopaAPISecurityCS();
            api_setting.Access_Token1__c = 'OiJKV1QiLCJhbGc';
            api_setting.Access_Token2__c = 'BsaWNhdG';
            api_setting.Access_Token3__c = '00YWV';
            api_setting.Access_Token4__c = 'iJKV1QiLCJh';
            api_setting.Access_Token_Collections1__c = 'OiJKV1QiLCJhbGc2';
            api_setting.Access_Token_Collections2__c = 'BsaWNhdG2';
            api_setting.Access_Token_Collections3__c = '00YWV2';
            api_setting.Access_Token_Collections4__c = 'iJKV1QiLCJh2';
            if(token_expired){
                api_setting.Access_Token_Expiry_Date__c = DateTime.now().addSeconds(-10);
            } else {
                api_setting.Access_Token_Expiry_Date__c = DateTime.now().addSeconds(10);
            }
            TestCustomSettings.saveCustomSettings(api_setting);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('OAuthZopaTest')
                                     .setLastName('OAuthZopaTest')
                                     .save();
    }
}