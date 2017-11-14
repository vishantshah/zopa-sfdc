@isTest
public class DcaAccountLinkingHandlerTest {
    private static final String STANDARD_USER = 'CaseViewStandard';

    static testMethod void testCheckingIsChangedDCAInUpdateLoanPositive() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            Loan__c old_loan = setup_data.TestLoan.clone(true);
            old_loan = LoanBuilder.getBuilder(old_loan).setArrearsRatio(0).setExternalId('test2').setAccountDCAID(setup_data.Dca2.Id).save().getRecord();
            DcaAccountLinkingHandler.getInstance().IsAlreadyUpdatedRecordsInTransaction = false;

            Test.startTest();
                DcaAccountLinkingHandler.getInstance().checkIsChangedDCA(old_loan, setup_data.TestLoan);
            Test.stopTest();

            System.assertEquals(1, DcaAccountLinkingHandler.getInstance().RecordsWithUpdatedDCA.values().size(), 'Loan was not added to list of records with changed DCA');
            System.assertEquals(true, DcaAccountLinkingHandler.getInstance().RecordsWithUpdatedDCA.containsKey(setup_data.TestLoan.Id), 'Loan was not added to list of records with changed DCA');
        }
    }

    static testMethod void testCheckingIsChangedDCAInUpdateLoanNegative() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            Loan__c old_loan = setup_data.TestLoan.clone(true);
            old_loan = LoanBuilder.getBuilder(old_loan).setArrearsRatio(0).setExternalId('test2').setAccountDCAID(setup_data.Dca1.Id).save().getRecord();
            DcaAccountLinkingHandler.getInstance().IsAlreadyUpdatedRecordsInTransaction = false;

            Test.startTest();
                DcaAccountLinkingHandler.getInstance().checkIsChangedDCA(old_loan, setup_data.TestLoan);
            Test.stopTest();

            System.assertEquals(false, DcaAccountLinkingHandler.getInstance().RecordsWithUpdatedDCA.containsKey(setup_data.TestLoan.Id), 'Loan was not added to list of records with changed DCA');
        }
    }

    static testMethod void testCheckingIsChangedDCAInUpdateCasePositive() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            Case old_case = CaseBuilder.getBuilder(setup_data.TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).setAccountDCAID(setup_data.Dca2.Id).setLoan(setup_data.TestLoan).save().getRecord();
            DcaAccountLinkingHandler.getInstance().IsAlreadyUpdatedRecordsInTransaction = false;

            Test.startTest();
                DcaAccountLinkingHandler.getInstance().checkIsChangedDCA(old_case, setup_data.TestCase);
            Test.stopTest();

            System.assertEquals(true, DcaAccountLinkingHandler.getInstance().RecordsWithUpdatedDCA.containsKey(setup_data.TestCase.Id), 'Case was not added to list of records with changed DCA');
        }
    }

    static testMethod void testCheckingIsChangedDCAInUpdateCaseNegative() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            Case old_case = CaseBuilder.getBuilder(setup_data.TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).setAccountDCAID(setup_data.Dca1.Id).setLoan(setup_data.TestLoan).save().getRecord();
            DcaAccountLinkingHandler.getInstance().IsAlreadyUpdatedRecordsInTransaction = false;

            Test.startTest();
                DcaAccountLinkingHandler.getInstance().checkIsChangedDCA(old_case, setup_data.TestCase);
            Test.stopTest();

            System.assertEquals(false, DcaAccountLinkingHandler.getInstance().RecordsWithUpdatedDCA.containsKey(setup_data.TestCase.Id), 'Case was not added to list of records with changed DCA');
        }
    }

    static testMethod void testUpdateRelatedRecordDCALookupLoan() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.TestLoan.AccountDCA__c = setup_data.Dca2.Id;
            DcaAccountLinkingHandler.getInstance().RecordsWithUpdatedDCA.put(setup_data.TestLoan.Id, setup_data.TestLoan);
            DcaAccountLinkingHandler.getInstance().IsAlreadyUpdatedRecordsInTransaction = false;
            DcaAccountLinkingHandler.getInstance().IsLoanUpdateTransaction = true;

            Test.startTest();
                DcaAccountLinkingHandler.getInstance().updateRelatedRecordDCALookup();
            Test.stopTest();

            setup_data.reQueryTestCase();
            System.assertEquals(setup_data.Dca2.Id, setup_data.TestCase.AccountDCA__c, 'Case related to Loan was not updated');
        }
    }

    static testMethod void testUpdateRelatedRecordDCALookupCase() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.TestCase.AccountDCA__c = setup_data.Dca2.Id;
            DcaAccountLinkingHandler.getInstance().RecordsWithUpdatedDCA.put(setup_data.TestCase.Id, setup_data.TestCase);
            DcaAccountLinkingHandler.getInstance().IsAlreadyUpdatedRecordsInTransaction = false;
            DcaAccountLinkingHandler.getInstance().IsLoanUpdateTransaction = false;

            Test.startTest();
                DcaAccountLinkingHandler.getInstance().updateRelatedRecordDCALookup();
            Test.stopTest();

            setup_data.reQueryTestLoan();
            System.assertEquals(setup_data.Dca2.Id, setup_data.TestLoan.AccountDCA__c, 'Loan related to Case was not updated');
        }
    }


    private class SetupDataClass {
        public Case TestCase;
        public Account TestAccount;
        public Account Dca1;
        public Account Dca2;
        public User TestUser;
        public Loan__c TestLoan;

        public SetupDataClass(String last_name) {
            FeatureSwitch.disable('ZCP-128');
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        private void createDataForTest() {
            FeatureSwitch.disable('ZCP-135');
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('DcaAccountLinkingHandlerTest').save().getRecord();
            Dca1 = AccountBuilder.getBuilder('DcaAccount1').save().getRecord();
            Dca2 = AccountBuilder.getBuilder('DcaAccount2').save().getRecord();
            TestLoan = LoanBuilder.getBuilder(TestAccount).setArrearsRatio(0).setExternalId('test2').setAccountDCAID(Dca1.Id).save().getRecord();
            TestCase = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).setAccountDCAID(Dca1.Id).setLoan(TestLoan).save().getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public void reQueryTestCase() {
            TestCase = [SELECT Id, AccountDCA__c FROM Case WHERE Id = : TestCase.Id];
        }

        public void reQueryTestLoan() {
            TestLoan = [SELECT id, AccountDCA__c FROM Loan__c WHERE Id = : TestLoan.Id];
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.STANDARD_USER)
                                     .setLastName(STANDARD_USER)
                                     .save();
    }
}