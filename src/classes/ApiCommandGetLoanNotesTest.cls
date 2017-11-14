@IsTest
public class ApiCommandGetLoanNotesTest {
    private static final String UUID = 'sdgfqewtddfafs';

    @IsTest
    static void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.GET_LOAN_NOTES, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }

    @IsTest
    static void testGetResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                List<ApiCommandGetLoanNotes.LoanComments> loan_comments = setup_data.ClassUnderTest.getResponse(ApiCommandGetLoanNotesMock.getMockResponceBody(10));
            Test.stopTest();
            System.assertEquals(10, loan_comments.size(), 'Size should be equals.');
        }
    }

    @IsTest
    static void testGetResponseEmptyList() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                List<ApiCommandGetLoanNotes.LoanComments> loan_comments = setup_data.ClassUnderTest.getResponse(ApiCommandGetLoanNotesMock.getMockResponceBody(0));
            Test.stopTest();
            System.assertEquals(true, loan_comments.isEmpty(), 'List should be exist, but without records');
        }
    }

    private class SetupDataClass {
        public ApiCommandGetLoanNotes ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandGetLoanNotesTest' AND LastName = 'ApiCommandGetLoanNotesTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandGetLoanNotes(UUID);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandGetLoanNotesTest')
                                     .setLastName('ApiCommandGetLoanNotesTest')
                                     .save();
    }
}