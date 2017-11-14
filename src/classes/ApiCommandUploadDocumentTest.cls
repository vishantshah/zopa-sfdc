@isTest
private class ApiCommandUploadDocumentTest {
    private static final String UUID = 'sdgfqfyewtddfafs';
    private static final String DOC_TYPE = 'type';
    private static final String DOC_NAME = 'name';
    private static final Blob DOC_BODY = Blob.valueOf('blob');
    private static final String DOC_MIME_TYPE = 'image/jpeg';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(DOC_NAME, setup_data.ClassUnderTest.DocumentName, 'Doc name should be initialized');
            System.assertEquals(DOC_TYPE, setup_data.ClassUnderTest.DocumentType, 'Doc type should be initialized');
            System.assertEquals(DOC_BODY, setup_data.ClassUnderTest.DocumentBody, 'Doc body should be initialized');
            System.assertEquals(DOC_MIME_TYPE, setup_data.ClassUnderTest.DocumentMimeType, 'Doc mime type should be initialized');
            System.assertEquals(ApiCommandsFactory.UPLOAD_DOCUMENT_COMMAND, setup_data.ClassUnderTest.CommandName, 'Command should correct');
        }
    }

    static testMethod void testGetDecodedBlobBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Blob body = setup_data.ClassUnderTest.getDecodedBlobBody();
            Test.stopTest();
            System.assert(body.toString().contains(DOC_BODY.toString()), 'Should contain document body');
            System.assert(body.toString().contains(DOC_TYPE), 'Should contain document name');
            System.assert(body.toString().contains(DOC_NAME), 'Should contain document type');
            System.assert(body.toString().contains(DOC_MIME_TYPE), 'Should contain document mime type');
        }
    }

    private class SetupDataClass {
        public ApiCommandUploadDocument ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandUploadDocumentTest' AND LastName = 'ApiCommandUploadDocumentTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandUploadDocument(UUID, DOC_BODY, DOC_TYPE, DOC_NAME, DOC_MIME_TYPE);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandUploadDocumentTest')
                                     .setLastName('ApiCommandUploadDocumentTest')
                                     .save();
    }
}