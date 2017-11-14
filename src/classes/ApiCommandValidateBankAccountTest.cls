@isTest
private class ApiCommandValidateBankAccountTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.POST_VALIDATE_BANK_ACCOUNT, setup_data.ClassUnderTest.CommandName, 'CommandName should be initialized');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            String expected_body = '{"SortCode":"sort_code","AccountNumber":"account_number"}';
            System.assertEquals(expected_body, body, 'Request body is not created correctly');
        }
    }

    private class SetupDataClass {
        public ApiCommandValidateBankAccount ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandValidateBankAccountTest' AND LastName = 'ApiCommandValidateBankAccountTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandValidateBankAccount(UUID, 'account_number', 'sort_code');
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('ApiCommandValidateBankAccountTest')
                                     .setLastName('ApiCommandValidateBankAccountTest')
                                     .save();
    }
}