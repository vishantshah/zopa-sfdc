@isTest
public class ApiCommandPutReviewDateTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();

            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.PUT_REVIEW_DATE, setup_data.ClassUnderTest.CommandName, 'Class under test must have another command name in it');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            System.assertEquals(JSON.serialize(setup_data.ReviewDate), body, 'There should be correct body');
        }
    }

    private class SetupDataClass {
        public ApiCommandPutReviewDate ClassUnderTest;
        public User TestUser;
        public ApiCommandPutReviewDate.ReviewDateResource ReviewDate;
        public DateTime ReviewDateTime;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandPutReviewDateTest' AND LastName = 'ApiCommandPutReviewDateTest' LIMIT 1];
            ReviewDateTime = Datetime.now();
        }

        public void createReviewDateResource(){
            ReviewDate = new ApiCommandPutReviewDate.ReviewDateResource(ReviewDateTime);
        }

        public void initClassUnderTest() {
            createReviewDateResource();
            ClassUnderTest = new ApiCommandPutReviewDate(UUID, ReviewDateTime);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandPutReviewDateMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandPutReviewDateTest')
                                     .setLastName('ApiCommandPutReviewDateTest')
                                     .save();
    }
}