@isTest
private class ApiCommandsFactoryTest {

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertNotEquals(null, setup_data.ClassUnderTest.CommandInfo, 'CommandInfo should be initialized');
            System.assert(setup_data.ClassUnderTest.CommandInfo.containsKey(ApiCommandsFactory.MAKE_QUICK_PAY_COMMAND), 'Should contain metadata');
            System.assert(setup_data.ClassUnderTest.CommandInfo.containsKey(ApiCommandsFactory.APPROVE_AND_WAVE_QUICK_PAY_COMMAND), 'Should contain metadata');
        }
    }

    static testMethod void testPerformApiCommandCalloutWithoutOAuth() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                ApiCommandApproveLoanAndWaveQuickPay api_command = new ApiCommandApproveLoanAndWaveQuickPay('Test');
                HttpResponse response = setup_data.ClassUnderTest.performApiCommandCallout(api_command);
            Test.stopTest();
            System.assertEquals(200, response.getStatusCode(), 'Success mock should be initialized');
            System.assertEquals(true, api_command.CommandSuccessful, 'Command should be Successful ');
            System.assertEquals(null, api_command.CommandError, 'Command should not have an error');
            System.assertEquals(null, api_command.HttpApiRequest.getHeader('Authorization'), 'Expected to have an Authorization header');
        }
    }

    static testMethod void testPerformApiCommandCalloutWitOAuth() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.updateOAuthCustomSettings();
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                ApiCommandApproveLoanAndWaveQuickPay api_command = new ApiCommandApproveLoanAndWaveQuickPay('Test');
                HttpResponse response = setup_data.ClassUnderTest.performApiCommandCallout(api_command);
            Test.stopTest();
            System.assertEquals(200, response.getStatusCode(), 'Success mock should be initialized');
            System.assertEquals(true, api_command.CommandSuccessful, 'Command should be Successful ');
            System.assertEquals(null, api_command.CommandError, 'Command should not have an error');
        }
    }

    static testMethod void testPerformApiCommandFailedCallout() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                ApiCommandApproveLoanAndWaveQuickPay api_command = new ApiCommandApproveLoanAndWaveQuickPay('Test');
                HttpResponse response = setup_data.ClassUnderTest.performApiCommandCallout(api_command);
            Test.stopTest();
            System.assertEquals(666, response.getStatusCode(), 'Success mock should be initialized');
            System.assertEquals(false, api_command.CommandSuccessful, 'Command should not be Successful ');
            System.assertEquals('Request error: Internal issues.', api_command.CommandError, 'Command should have an error');
        }
    }

    static testMethod void testPerformApiCommandCalloutWithMock() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.updateOAuthCustomSettings();
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            setup_data.createCustomSettingWithMock();
            Test.startTest();
                ApiCommandLoanInformation api_command = new ApiCommandLoanInformation('Test');
                HttpResponse response = setup_data.ClassUnderTest.performApiCommandCallout(api_command);
            Test.stopTest();
            System.assertEquals(200, response.getStatusCode(), 'Success mock should be initialized');
        }
    }

    static testMethod void testPerformApiCommandCalloutWithMockInternalError() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.updateOAuthCustomSettings();
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false, 500);
            setup_data.createCustomSettingWithMock();
            Test.startTest();
                ApiCommandLoanInformation api_command = new ApiCommandLoanInformation('Test');
                HttpResponse response = setup_data.ClassUnderTest.performApiCommandCallout(api_command);
            Test.stopTest();
            System.assertEquals(500, response.getStatusCode(), 'Success mock should be initialized');
            System.assertEquals(true, api_command.CommandError.contains('Internal Server Error'), 'Command should have an error');
        }
    }

    private class SetupDataClass {
        public ApiCommandsFactory ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandsFactoryTest' AND LastName = 'ApiCommandsFactoryTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = ApiCommandsFactory.getInstance();
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }

        public void setMockForResponse(Boolean is_success, Integer status_code) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success, status_code));
        }

        public void updateOAuthCustomSettings(){
            Zopa_API_Security__c api_setting = TestCustomSettings.getZopaAPISecurityCS();
            api_setting.Use_OAuth__c = true;
            TestCustomSettings.saveCustomSettings(api_setting);
        }

        public void createCustomSettingWithMock(){
            Mock_Manager_for_Callout__c new_custom_setting = new Mock_Manager_for_Callout__c(name = 'LoanRepaymentMock', Is_Enable_Mock__c = true);
            insert new_custom_setting;
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandsFactoryTest')
                                     .setLastName('ApiCommandsFactoryTest')
                                     .save();
    }
}