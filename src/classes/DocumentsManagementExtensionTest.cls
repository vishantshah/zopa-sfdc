@isTest
public class DocumentsManagementExtensionTest {
    private static final List<String> DOCUMENT_TYPES = new List<String>{'test', 'test2'};
    private static final String DOCUMENT_TYPE = 'type';
    private static final String DOC_NAME = 'name';
    private static final Blob DOC_BODY = Blob.valueOf('blob');

    static testMethod void testGetIsZopa55IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-55');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa55IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be switched off');
        }
    }

    static testMethod void testGetAvailableDocumentTypes() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.initController();
            setup_data.createDocTypesCS();
            Test.startTest();
                List<SelectOption> doc_types = setup_data.ClassUnderTest.getAvailableDocumentTypes();
            Test.stopTest();
            System.assertEquals(setup_data.getExpectedDocTypes(), doc_types, 'Should get correct options');
        }
    }

    static testMethod void testUploadDocumentSucceed() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.initController();
            setup_data.setInputDocument();
            setup_data.setMockForResponse(true);
            Test.startTest();
                PageReference result_referense = setup_data.ClassUnderTest.uploadDocument();
            Test.stopTest();
            System.assertEquals(ApexPages.currentPage(), result_referense, 'Should get correct options');
            setup_data.assertPageMessage('Document uploaded successfully');
        }
    }

    static testMethod void testUploadDocumentFailed() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.initController();
            setup_data.setInputDocument();
            setup_data.setMockForResponse(false);
            Test.startTest();
                PageReference result_referense = setup_data.ClassUnderTest.uploadDocument();
            Test.stopTest();
            System.assertEquals(ApexPages.currentPage(), result_referense, 'Should get correct options');
            setup_data.assertPageMessage(ApiCommandTestMock.ERROR_MESSAGE);
        }
    }

    static testMethod void testUploadDocumentNoDocumentSelected() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.initController();
            setup_data.setMockForResponse(true);
            Test.startTest();
                PageReference result_referense = setup_data.ClassUnderTest.uploadDocument();
            Test.stopTest();
            System.assertEquals(ApexPages.currentPage(), result_referense, 'Should get correct options');
            setup_data.assertPageMessage('Please select file');
        }
    }

    private class SetupDataClass {
        public Loan_Application__c TestLoanApplication;
        public Account TestAccount;
        public User TestUser;
        public User AssignedToUser;
        public DocumentsManagementExtension ClassUnderTest;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = :CASE_PREP_USER LIMIT 1];
        }

        private void createDataForCase() {
            TestAccount = AccountBuilder.getBuilder('CaseManualUnderwriterExtension').save().getRecord();
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setExpiryDate(System.now()).setExternalId(Utility.getRandomString(8)).save().getRecord();
        }

        public void initController() {
            ClassUnderTest = new DocumentsManagementExtension(new ApexPages.StandardController(TestLoanApplication));
        }

        public String getExpectedUrlForCustomerAccount() {
            return new PageReference('/'+TestAccount.id).getUrl();
        }

        public String getExpectedUrlForLoanApplication() {
            return new PageReference('/apex/LoanView?id=' + TestLoanApplication.id).getUrl();
        }

        public void setInputDocument() {
            ClassUnderTest.DocumentType = DOCUMENT_TYPE;
            ClassUnderTest.DocumentToUpload.Body = DOC_BODY;
            ClassUnderTest.DocumentToUpload.Name = DOC_NAME;
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

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }

        public void assertPageMessage(String message) {
            for(Apexpages.Message page_message : ApexPages.getMessages()){
                if (page_message.getDetail().contains(message)) {
                    return;
                }
            }
            System.assert(false, 'No such message on page');
        }
    }

    private static final String CASE_PREP_USER = 'DocumentsManagementExtensionTest';

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setLastName(CASE_PREP_USER)
                                     .save();
    }
}