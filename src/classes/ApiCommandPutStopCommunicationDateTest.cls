@IsTest
public class ApiCommandPutStopCommunicationDateTest {
    private static final String COLLECTIONS_USER = 'TestUserLastName';
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass(COLLECTIONS_USER);
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();

            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.PUT_STOP_COMMUNICATION_DATE, setup_data.ClassUnderTest.CommandName, 'Class under test must have another command name in it');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass(COLLECTIONS_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();

            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();

            System.assertEquals(JSON.serialize(setup_data.StopCommunicationRes), body, 'There should be correct body');
        }
    }

    private class SetupDataClass {
        public ApiCommandPutStopCommunicationDate ClassUnderTest;
        public User TestUser;
        public ApiCommandPutStopCommunicationDate.StopCommunicationResource StopCommunicationRes;
        public DateTime StopCommunicationDateTime;

        public SetupDataClass(String last_name){
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
            StopCommunicationDateTime = Datetime.now();
        }

        public void createStopCommunicationResource(){
            StopCommunicationRes = new ApiCommandPutStopCommunicationDate.StopCommunicationResource(StopCommunicationDateTime);
        }

        public void initClassUnderTest() {
            createStopCommunicationResource();
            ClassUnderTest = new ApiCommandPutStopCommunicationDate(UUID, StopCommunicationDateTime);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandPutStopCommunicationDateMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('TestUserFirstName')
                                     .setLastName(COLLECTIONS_USER)
                                     .save();
    }
}