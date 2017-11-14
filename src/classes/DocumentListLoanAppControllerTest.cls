@isTest public class DocumentListLoanAppControllerTest {
    private static final String CASE_PREP_USER = 'DocumentListLoanAppControllerTest';
    private static final List<String> DOCUMENT_TYPES = new List<String>{'test', 'test2'};

    static testMethod void testGetDocumentsNotSuccessAccessDenied() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(false, 403, false);
            setup_data.createDataForTest();
            setup_data.initController();

            Test.startTest();
                PageReference result = setup_data.ClassUnderTest.getDocumentsListFromBackEnd();
            Test.stopTest();

            System.assertEquals(null, result, 'Result should be null if error occures');
            setup_data.assertPageMessage('Access Denied.');
        }
    }

    static testMethod void testGetDocumentsSuccessNoDocumentsFound() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(false, 404, false);
            setup_data.createDataForTest();
            setup_data.initController();

            Test.startTest();
                PageReference result = setup_data.ClassUnderTest.getDocumentsListFromBackEnd();
            Test.stopTest();

            System.assertEquals(null, result, 'Result should be null if there are no results');
        }
    }

    static testMethod void testGetDocumentsNotSuccess() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(false, 666, false);
            setup_data.createDataForTest();
            setup_data.initController();

            Test.startTest();
                PageReference result = setup_data.ClassUnderTest.getDocumentsListFromBackEnd();
            Test.stopTest();

            System.assertEquals(null, result, 'Result should be null if error occures');
        }
    }

    static testMethod void testGetDocumentsSuccess() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true, 200, false);
            setup_data.createDataForTest();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.getDocumentsListFromBackEnd();
            Test.stopTest();

            System.assertEquals(3, setup_data.ClassUnderTest.DocumentsList.size(), 'There should be 3 documents in result');
            System.assertEquals('jesper1', setup_data.ClassUnderTest.DocumentsList[0].Filename, 'Document was setted incorrect');
            System.assertEquals('jesper2', setup_data.ClassUnderTest.DocumentsList[1].Filename, 'Document was setted incorrect');
            System.assertEquals('jesper3', setup_data.ClassUnderTest.DocumentsList[2].Filename, 'Document was setted incorrect');
        }
    }

    static testMethod void testGetDocumentsSuccessWithoutDocuments() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true, 200, true);
            setup_data.createDataForTest();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.getDocumentsListFromBackEnd();
            Test.stopTest();

            System.assertEquals(0, setup_data.ClassUnderTest.DocumentsList.size(), 'There should be 3 documents in result');
        }
    }

    static testMethod void testGetDocumentsSuccessIfNotExistExternalId() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.initController();
            setup_data.ClassUnderTest.LoanAppId = null;

            Test.startTest();
                PageReference result = setup_data.ClassUnderTest.getDocumentsListFromBackEnd();
            Test.stopTest();

            System.assertEquals(null, result, 'Result should be null if error occures');
            setup_data.assertPageMessage('This loan doesn\'t have an Id. Can\'t retrieve information.');
        }
    }

    static testMethod void testHidePopup() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.initController();
            setup_data.ClassUnderTest.DocumentIdToChangeType = 'Show popup, please';
            Test.startTest();
                setup_data.ClassUnderTest.hidePopup();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.DocumentIdToChangeType, 'Should clear value. It will hide popup');
        }
    }

    static testMethod void testGetIsZopa58IsEnabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-58');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.initController();
            Test.startTest();
                Boolean enabled = setup_data.ClassUnderTest.getIsZopa58IsEnabled();
            Test.stopTest();
            System.assertEquals(true, enabled, 'Should return true');
        }
    }

    static testMethod void testGetIsZopa58IsEnabledDisabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-58');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.initController();
            Test.startTest();
                Boolean enabled = setup_data.ClassUnderTest.getIsZopa58IsEnabled();
            Test.stopTest();
            System.assertEquals(false, enabled, 'Should return false');
        }
    }

    static testMethod void testGetHasDocumentsPermissions() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-54');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa54IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZOPA-54 should be disabled');
        }
    }

    static testMethod void testGetAvailableDocumentTypes() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.initController();
            setup_data.createDocTypesCS();
            Test.startTest();
                List<SelectOption> options = setup_data.ClassUnderTest.getAvailableDocumentTypes();
            Test.stopTest();
            System.assertEquals(setup_data.getExpectedDocTypes(), options, 'Should return expected options');
        }
    }

    static testMethod void testClassifyDocumentActionSuccess() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.initController();
            setup_data.setMockForResponseClassify(true);
            setup_data.ClassUnderTest.DocumentIdToChangeType = 'Show popup, please';
            Test.startTest();
                setup_data.ClassUnderTest.classifyDocumentAction();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.DocumentIdToChangeType, 'Should clear value. It will hide popup');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Loan_Application__c TestLoanApplication;
        public Account TestAccount;
        public User TestUser;
        public User AssignedToUser;
        public DocumentListLoanAppController ClassUnderTest;
        public String LoanAppId;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        private void createDataForTest() {
            TestAccount = AccountBuilder.getBuilder('DocumentListLoanAppControllerTest').save().getRecord();
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setExpiryDate(System.now()).setExternalId(Utility.getRandomString(8)).save().getRecord();
        }

        public void initController() {
            ClassUnderTest = new DocumentListLoanAppController();
            ClassUnderTest.LoanAppId = TestLoanApplication.Loan_ID__c;
            ClassUnderTest.LoanInternalId = TestLoanApplication.Id;
        }

        public void createManualUnderwritingCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void setMockForResponseClassify(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }

        public void setMockForResponse(Boolean is_success, Integer error_code, Boolean is_empty_body) {
            Test.setMock(HttpCalloutMock.class, new ApiDocumentsTestMock(is_success, error_code, is_empty_body));
        }

        public void createDocTypesCS() {
            List<Available_Document_Types__c> doc_settings = new List<Available_Document_Types__c>();
            for (String doc_type : DOCUMENT_TYPES) {
                doc_settings.add(new Available_Document_Types__c(Name = doc_type, Zopa_Value__c = doc_type));
            }
            insert doc_settings;
        }

        public List<SelectOption> getExpectedDocTypes() {
            List<SelectOption> options = new List<SelectOption>();
            for (String doc_type : DOCUMENT_TYPES) {
                options.add(new SelectOption(doc_type, doc_type));
            }
            return options;
        }

        public void assertPageMessage(String message) {
            System.assert(ClassUnderTest.ErrorOnLoad.contains(message), 'No such error on page');
        }
    }

    @testSetup
    static void setupTestUser() {

        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setLastName(CASE_PREP_USER)
                                     .save();
    }
}