@isTest
public class CaseViewExtensionTest {
    private static final String CASE_PREP_USER = 'CaseViewCasePrep';

    static testMethod void testCaseViewExtensionInitialization() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            Test.startTest();
                setup_data.initController();
            Test.stopTest();
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.TheCase.Id, 'Should be initialized by appropriate case');
        }
    }

    static testMethod void testDoRedirectManualUnderwriting() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                PageReference page_reference = setup_data.ClassUnderTest.doRedirect();
            Test.stopTest();
            PageReference expected_reference = Page.CaseManualUnderwriting;
            expected_reference.getParameters().put('id',setup_data.TestCase.Id);
            System.assertEquals(expected_reference.getUrl(), page_reference.getUrl(), 'Should return reference to the underwriter case page');
        }
    }

    static testMethod void testDoRedirectCollectionsRecoveries() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                PageReference page_reference = setup_data.ClassUnderTest.doRedirect();
            Test.stopTest();
            PageReference expected_reference = Page.CaseCollectionsRecoveries;
            expected_reference.getParameters().put('id',setup_data.TestCase.Id);
            System.assertEquals(expected_reference.getUrl(), page_reference.getUrl(), 'Should return reference to the  Collections&Recoveries case page');
        }
    }

    static testMethod void testDoRedirectDefaultCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createCustomerCase();
            setup_data.initController();
            Test.startTest();
                PageReference page_reference = setup_data.ClassUnderTest.doRedirect();
            Test.stopTest();
            System.assertEquals(null, page_reference, 'Should not redirect to another page');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Loan_Application__c TestLoanApplication;
        public Account TestAccount;
        public CaseViewExtension ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            FeatureSwitch.enable('ZCP-212');
            TestUser = [SELECT Id FROM User WHERE LastName = :CASE_PREP_USER LIMIT 1];
        }

        private void createDataForCase() {
            TestAccount = AccountBuilder.getBuilder('CaseViewExtension').save().getRecord();
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setExpiryDate(System.now()).save().getRecord();
        }

        public void createCollectionsRecoveriesCase() {
            createDataForCase();
            TestCase = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).save().getRecord();
        }

        public void createManualUnderwritingCase() {
            createDataForCase();
            TestCase = CaseBuilder.getBuilder(TestAccount).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createCustomerCase() {
            createDataForCase();
            TestCase = CaseBuilder.getBuilder(TestAccount).setStatus('Open').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_CUSTOMER).save().getRecord();
        }

        public void initController() {
            ClassUnderTest = new CaseViewExtension(new ApexPages.StandardController(TestCase));
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setLastName(CASE_PREP_USER)
                                     .save();
    }
}