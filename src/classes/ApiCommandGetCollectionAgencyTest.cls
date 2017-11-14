@IsTest
public class ApiCommandGetCollectionAgencyTest {
    private static final String UUID = 'sdgfqewtddfafs';

    @IsTest
    static void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.GET_COLLECTIONS_AGENCY, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }

    @IsTest
    static void testGetResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                List<ApiCommandGetCollectionAgency.CollectionAgencyCases> collection_agency_cases = setup_data.ClassUnderTest.getResponse(ApiCommandGetCollectionAgencyMock.getMockResponceBody());
            Test.stopTest();
            System.assertEquals(3, collection_agency_cases.size(), 'Size should be equals.');
        }
    }

    private class SetupDataClass {
        public ApiCommandGetCollectionAgency ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandGetCollectionAgencyTest' AND LastName = 'ApiCommandGetCollectionAgencyTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandGetCollectionAgency(UUID);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandGetCollectionAgencyTest')
                                     .setLastName('ApiCommandGetCollectionAgencyTest')
                                     .save();
    }
}