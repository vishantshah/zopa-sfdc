@IsTest
private class ApiCommandLettersPostTest {
    static final String LOAN_ID = '0000-0000-0000-0001';
    static final String TEMPLATE_NAME = 'TestTemplateName';

    @IsTest
    static void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.initClassUnderTest(LOAN_ID, TEMPLATE_NAME, 'auto');
            Test.stopTest();

            System.assertEquals(LOAN_ID, setup_data.ClassUnderTest.RecordUuid, 'Should be set with proper value.');
            System.assertEquals(TEMPLATE_NAME, setup_data.ClassUnderTest.TemplateName, 'Should be set with proper value.');
            System.assertEquals('auto', setup_data.ClassUnderTest.SendMethod, 'Should be set with proper value.');
            System.assertEquals(ApiCommandsFactory.POST_LETTER, setup_data.ClassUnderTest.CommandName, 'Should be set as POST_LETTER.');
        }
    }

    @IsTest
    static void testInitClassUnderTestPostLettersAuto() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.ClassUnderTest = ApiCommandLettersPost.getApiCommandLoanPostLettersAuto(LOAN_ID, TEMPLATE_NAME);
            Test.stopTest();

            System.assertEquals(LOAN_ID, setup_data.ClassUnderTest.RecordUuid, 'Should be set with proper value.');
            System.assertEquals(TEMPLATE_NAME, setup_data.ClassUnderTest.TemplateName, 'Should be set with proper value.');
            System.assertEquals('auto', setup_data.ClassUnderTest.SendMethod, 'Should be set with proper value.');
            System.assertEquals(ApiCommandsFactory.POST_LETTER, setup_data.ClassUnderTest.CommandName, 'Should be set as POST_LETTER.');
        }
    }

    @IsTest
    static void testInitClassUnderTestPostLettersManual() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.ClassUnderTest = ApiCommandLettersPost.getApiCommandLoanPostLettersManual(LOAN_ID, TEMPLATE_NAME);
            Test.stopTest();

            System.assertEquals(LOAN_ID, setup_data.ClassUnderTest.RecordUuid, 'Should be set with proper value.');
            System.assertEquals(TEMPLATE_NAME, setup_data.ClassUnderTest.TemplateName, 'Should be set with proper value.');
            System.assertEquals('manual', setup_data.ClassUnderTest.SendMethod, 'Should be set with proper value.');
            System.assertEquals(ApiCommandsFactory.POST_LETTER, setup_data.ClassUnderTest.CommandName, 'Should be set as POST_LETTER.');
        }
    }

    @IsTest
    static void testApiCommandSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(LOAN_ID, TEMPLATE_NAME, 'auto');
            setup_data.setMockForResponse(true);

            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.CommandSuccessful, 'Command should be successful.');
            ApiCommandLettersGetAll.Letter letter = (ApiCommandLettersGetAll.Letter) setup_data.ClassUnderTest.getResponse();
            System.assertEquals(1, letter.Id, 'Response should contains Letter Id value.');
            System.assertEquals(LOAN_ID, letter.LoanId, 'Response should contains Loan Uuid value.');
            System.assertEquals('TestLetterName1', letter.Name, 'Response should contains Letter Name value.');
            System.assertEquals('TestAuthorName1', letter.CreatedBy, 'Response should contains Created By value.');
        }
    }

    @IsTest
    static void testApiCommandFailedResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(LOAN_ID, TEMPLATE_NAME, 'auto');
            setup_data.setMockForResponse(false);

            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.CommandSuccessful, 'Command should failed.');
            System.assertEquals('Internal Server Error: Internal Error', setup_data.ClassUnderTest.CommandError, 'Proper error should be set.');
        }
    }

    private class SetupDataClass {
        public ApiCommandLettersPost ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'TestFirstName' AND LastName = 'TestLastName' LIMIT 1];
        }

        public void initClassUnderTest(String loan_id, String template_name, String send_method) {
            ClassUnderTest = new ApiCommandLettersPost(loan_id, template_name, send_method);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLettersPostMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setFirstName('TestFirstName')
                .setLastName('TestLastName')
                .save();
    }
}