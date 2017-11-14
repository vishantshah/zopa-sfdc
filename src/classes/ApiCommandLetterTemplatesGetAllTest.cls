@IsTest
public class ApiCommandLetterTemplatesGetAllTest {

    @IsTest
    static void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(ApiCommandsFactory.GET_ALL_LETTER_TEMPLATES, setup_data.ClassUnderTest.CommandName, 'Command name was set incorrect');
        }
    }

    @IsTest
    static void testTestApiCommand() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            List<ApiCommandLetterTemplatesGet.LetterTemplate> templates;
            Test.startTest();
                ApiCommandLetterTemplatesGetAll get_loan_details_command = new ApiCommandLetterTemplatesGetAll();
                ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_details_command);
                templates = get_loan_details_command.getResponse();
            Test.stopTest();
            System.assertEquals(12, templates.size() , 'Number of templates was incorrect');
            System.assertEquals(8, templates[7].Id , 'Id was setted incorrect.');
            System.assertEquals('NOSA1', templates[7].Name , 'Name was setted incorrect.');
            System.assertEquals('NOSA 1', templates[7].FriendlyName , 'FriendlyName was setted incorrect.');
            System.assertEquals(1, templates[7].Version , 'Version was setted incorrect.');
            System.assertEquals(null, templates[7].Html , 'Html was setted incorrect.');
        }
    }

    private class SetupDataClass {
        public ApiCommandLetterTemplatesGetAll ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandLetterTemplatesGetAllTest' AND LastName = 'ApiCommandLetterTemplatesGetAllTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandLetterTemplatesGetAll();
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLetterTemplatesTestMock(is_success, ApiCommandLetterTemplatesTestMock.CommandsName.GET_ALL_LETTER_TEMPLATES));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandLetterTemplatesGetAllTest')
                                     .setLastName('ApiCommandLetterTemplatesGetAllTest')
                                     .save();
    }
}