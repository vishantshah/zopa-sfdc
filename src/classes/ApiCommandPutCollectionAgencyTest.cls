@isTest
public class ApiCommandPutCollectionAgencyTest {
    private static final String UUID = 'sdgfqfyewtddfafs';
    private static final String DCA_UUID = 'afsdfdsfdsfsdf';
    private static final String CASE_AGENCY_ID = 'afsdfdsfdsfsdf';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(DCA_UUID, setup_data.ClassUnderTest.CurrentCollectionAgencyCase.CollectionsAgencyId, 'Uuid should be initialized');
            System.assertEquals('Closed', setup_data.ClassUnderTest.CurrentCollectionAgencyCase.State, 'State should be initialized');
            System.assertEquals(true, String.isBlank(setup_data.ClassUnderTest.CurrentCollectionAgencyCase.Comments), 'Comments should be initialized as empty field');
            System.assertEquals(false, setup_data.ClassUnderTest.CurrentCollectionAgencyCase.Referred, 'Uuid should be initialized with false value');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createCurrentCollectionAgencyCase();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            ApiCommandPutCollectionAgency.CollectionAgencyCaseResource actual_object = (ApiCommandPutCollectionAgency.CollectionAgencyCaseResource)JSON.deserialize(body,ApiCommandPutCollectionAgency.CollectionAgencyCaseResource.class);
            System.assertEquals(setup_data.CurrentCollectionAgencyCase.CollectionsAgencyId, actual_object.CollectionsAgencyId, 'CollectionsAgencyId do not match in json body or differs from expected value. This is required field for command');
            System.assertEquals(setup_data.CurrentCollectionAgencyCase.State, actual_object.State, 'State do not match in json body or differs from expected value. This is required field for command');
            System.assertEquals(setup_data.CurrentCollectionAgencyCase.Comments, actual_object.Comments, 'Comments do not match in json body or differs from expected value. This is required field for command');
            System.assertEquals(setup_data.CurrentCollectionAgencyCase.Referred, actual_object.Referred, 'Referred do not match in json body or differs from expected value. This is required field for command');
        }
    }

    private class SetupDataClass {
        public ApiCommandPutCollectionAgency ClassUnderTest;
        public User TestUser;
        public ApiCommandPutCollectionAgency.CollectionAgencyCaseResource CurrentCollectionAgencyCase;
        public Datetime TestDateTime;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandPutCollectionAgencyTest' AND LastName = 'ApiCommandPutCollectionAgencyTest' LIMIT 1];
            TestDateTime = System.now();
        }

        public void createCurrentCollectionAgencyCase(){
            CurrentCollectionAgencyCase = new ApiCommandPutCollectionAgency.CollectionAgencyCaseResource(DCA_UUID, TestDateTime);
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandPutCollectionAgency(UUID, DCA_UUID, TestDateTime, CASE_AGENCY_ID);
        }


    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandPutCollectionAgencyTest')
                                     .setLastName('ApiCommandPutCollectionAgencyTest')
                                     .save();
    }
}