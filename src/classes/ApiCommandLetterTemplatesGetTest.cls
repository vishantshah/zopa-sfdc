@IsTest
public class ApiCommandLetterTemplatesGetTest {
    private static final String TEMPLATE_NAME = 'sdgfqewtddfafs';

    @IsTest
    static void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(TEMPLATE_NAME, setup_data.ClassUnderTest.TemplateName, 'TemplateName should be initialized');
            System.assertEquals(ApiCommandsFactory.GET_LETTER_TEMPLATE, setup_data.ClassUnderTest.CommandName, 'Command name was set incorrect');
        }
    }

    @IsTest
    static void testTestApiCommand() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            ApiCommandLetterTemplatesGet.LetterTemplate template;
            Test.startTest();
                ApiCommandLetterTemplatesGet get_loan_details_command = new ApiCommandLetterTemplatesGet(TEMPLATE_NAME);
                ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_details_command);
                template = get_loan_details_command.getResponse();
            Test.stopTest();
            System.assertEquals(0, template.Id , 'Id was setted incorrect.');
            System.assertEquals('test', template.Name , 'Name was setted incorrect.');
            System.assertEquals('test', template.FriendlyName , 'FriendlyName was setted incorrect.');
            System.assertEquals(1, template.Version , 'Version was setted incorrect.');
            System.assertEquals('htmlhtml', template.Html , 'Html was setted incorrect.');
        }
    }

    private class SetupDataClass {
        public ApiCommandLetterTemplatesGet ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandLetterTemplatesGetTest' AND LastName = 'ApiCommandLetterTemplatesGetTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandLetterTemplatesGet(TEMPLATE_NAME);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLetterTemplatesTestMock(is_success, ApiCommandLetterTemplatesTestMock.CommandsName.GET_LETTER_TEMPLATE));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandLetterTemplatesGetTest')
                                     .setLastName('ApiCommandLetterTemplatesGetTest')
                                     .save();
    }
}