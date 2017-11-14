@isTest
private class ApiCommandClassifyDocumentTypeTest {
    private static final String UUID = 'sdgfqewtddfafs';
    private static final String NEW_DOC_TYPE = 'type';
    private static final String DOC_ID = 'asdasdasdas';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(DOC_ID, setup_data.ClassUnderTest.DocumentId, 'Doc id should be initialized');
            System.assertEquals(NEW_DOC_TYPE, setup_data.ClassUnderTest.DocumentType, 'Doc type should be initialized');
            System.assertEquals(ApiCommandsFactory.DOCUMENT_CLASSIFY_TYPE_COMMAND, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();
            System.debug(body);
            System.assertEquals('{"DocumentType":"' + NEW_DOC_TYPE + '"}', body, 'There should be valid json');
        }
    }

    private class SetupDataClass {
        public ApiCommandClassifyDocumentType ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandClassifyDocumentTypeTest' AND LastName = 'ApiCommandClassifyDocumentTypeTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandClassifyDocumentType(UUID, DOC_ID, NEW_DOC_TYPE);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandClassifyDocumentTypeTest')
                                     .setLastName('ApiCommandClassifyDocumentTypeTest')
                                     .save();
    }
}