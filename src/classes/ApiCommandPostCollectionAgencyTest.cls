@isTest
public class ApiCommandPostCollectionAgencyTest {
    private static final String UUID = 'sdgfqfyewtddfafs';
    private static final String DCA_UUID = 'afsdfdsfdsfsdf';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(DCA_UUID, setup_data.ClassUnderTest.CurrentCollectionAgencyCase.CollectionsAgencyId, 'Uuid should be initialized');
            System.assertEquals('Open', setup_data.ClassUnderTest.CurrentCollectionAgencyCase.State, 'State should be initialized');
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
            ApiCommandPostCollectionAgency.CollectionAgencyCaseResource actual_object = (ApiCommandPostCollectionAgency.CollectionAgencyCaseResource)JSON.deserialize(body,ApiCommandPostCollectionAgency.CollectionAgencyCaseResource.class);
            System.assertEquals(setup_data.CurrentCollectionAgencyCase.CollectionsAgencyId, actual_object.CollectionsAgencyId, 'CollectionsAgencyId do not match in json body or differs from expected value. This is required field for command');
            System.assertEquals(setup_data.CurrentCollectionAgencyCase.State, actual_object.State, 'State do not match in json body or differs from expected value. This is required field for command');
            System.assertEquals(setup_data.CurrentCollectionAgencyCase.Comments, actual_object.Comments, 'Comments do not match in json body or differs from expected value. This is required field for command');
            System.assertEquals(setup_data.CurrentCollectionAgencyCase.Referred, actual_object.Referred, 'Referred do not match in json body or differs from expected value. This is required field for command');
        }
    }

    private class SetupDataClass {
        public ApiCommandPostCollectionAgency ClassUnderTest;
        public User TestUser;
        public ApiCommandPostCollectionAgency.CollectionAgencyCaseResource CurrentCollectionAgencyCase;
        public Datetime TestDateTime;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandPostCollectionAgencyTest' AND LastName = 'ApiCommandPostCollectionAgencyTest' LIMIT 1];
            TestDateTime = System.now();
        }

        public void createCurrentCollectionAgencyCase(){
            CurrentCollectionAgencyCase = new ApiCommandPostCollectionAgency.CollectionAgencyCaseResource(DCA_UUID, TestDateTime);
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandPostCollectionAgency(UUID, DCA_UUID, TestDateTime);
        }


    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandPostCollectionAgencyTest')
                                     .setLastName('ApiCommandPostCollectionAgencyTest')
                                     .save();
    }
}