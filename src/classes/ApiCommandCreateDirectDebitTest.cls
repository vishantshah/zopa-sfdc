@isTest
private class ApiCommandCreateDirectDebitTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.POST_CREATE_DIRECT_DEBIT, setup_data.ClassUnderTest.CommandName, 'CommandName should be initialized');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            String expected_body = '{"SortCode":"sort_code","AccountNumber":"account_number","AccountHolderName":"account_holder_name"}';
            System.assertEquals(expected_body, body, 'Request body is not created correctly');
        }
    }

    private class SetupDataClass {
        public ApiCommandCreateDirectDebit ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandCreateDirectDebitTest' AND LastName = 'ApiCommandCreateDirectDebitTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandCreateDirectDebit(UUID, 'account_number', 'sort_code', 'account_holder_name');
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('ApiCommandCreateDirectDebitTest')
                                     .setLastName('ApiCommandCreateDirectDebitTest')
                                     .save();
    }
}