@IsTest
public class ApiCommandLetterTemplatesPostTest {
    private static final String TEMPLATE_NAME = 'test_name';
    private static final String HTML = '<h1>This is a heading</h1>';

    @IsTest
    static void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(ApiCommandsFactory.POST_LETTER_TEMPLATE, setup_data.ClassUnderTest.CommandName, 'Command name was set incorrect');
        }
    }

    @IsTest
    static void testTestApiCommandSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            ApiCommandLetterTemplatesGet.LetterTemplate template;
            Test.startTest();
                ApiCommandLetterTemplatesPost get_loan_details_command = new ApiCommandLetterTemplatesPost(TEMPLATE_NAME, HTML);
                ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_details_command);

            Test.stopTest();
            System.assertEquals(true, get_loan_details_command.CommandSuccessful , 'Command should be success');
        }
    }

    @IsTest
    static void testTestApiCommandNotSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            ApiCommandLetterTemplatesGet.LetterTemplate template;
            Test.startTest();
                ApiCommandLetterTemplatesPost get_loan_details_command = new ApiCommandLetterTemplatesPost(TEMPLATE_NAME, HTML);
                ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_details_command);

            Test.stopTest();
            System.assertEquals(false, get_loan_details_command.CommandSuccessful , 'Command not sshould be success');
        }
    }

    private class SetupDataClass {
        public ApiCommandLetterTemplatesPost ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandLetterTemplatesPost' AND LastName = 'ApiCommandLetterTemplatesPost' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandLetterTemplatesPost(TEMPLATE_NAME, HTML);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLetterTemplatesTestMock(is_success, ApiCommandLetterTemplatesTestMock.CommandsName.GET_LETTER_TEMPLATE));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandLetterTemplatesPost')
                                     .setLastName('ApiCommandLetterTemplatesPost')
                                     .save();
    }
}