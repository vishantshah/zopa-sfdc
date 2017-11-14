@isTest
public class MissedPlanPaymentHandlerTest {
    private static final String STANDARD_USER = 'CaseViewStandard';

    static testMethod  void testGetInstance() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                MissedPlanPaymentHandler class_under_test = MissedPlanPaymentHandler.getInstance();
            Test.stopTest();

            System.assertNotEquals(null, MissedPlanPaymentHandler.Instance, 'Instance should be prepared.');
            System.assertNotEquals(null, class_under_test.CasesWithMissedPayment, 'CasesWithMissedPayment should be prepared.');
            System.assertEquals(0, class_under_test.CasesWithMissedPayment.size(), 'CasesWithMissedPayment should be empty.');
            System.assertNotEquals(null, class_under_test.LoansWithMissedPayment, 'LoansWithMissedPayment should be prepared.');
            System.assertEquals(0, class_under_test.LoansWithMissedPayment.size(), 'LoansWithMissedPayment should be empty.');
            System.assertNotEquals(null, class_under_test.Recorder, 'Recorder should be prepared.');
            System.assertNotEquals(null, class_under_test.CollectionsDmlOption, 'CollectionsDmlOption should be prepared.');
            System.assertNotEquals(null, class_under_test.RecoveriesDmlOption, 'RecoveriesDmlOption should be prepared.');
            System.assertNotEquals(null, class_under_test.SensitiveDmlOption, 'SensitiveDmlOption should be prepared.');
        }
    }

    static testMethod void testCheckIsChangedDateOfLastMissedPlanPayment() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-106', 'ZCP-149', 'ZCP-71'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            Loan__c new_loan = LoanBuilder.getBuilder(setup_data.TestAccount).setArrearsRatio(0).setExternalId('test2').save().getRecord();
            new_loan.Date_Of_Last_Missed_Plan_Payment__c = Datetime.now().addDays(2);

            Test.startTest();
                MissedPlanPaymentHandler.getInstance().checkIsChangedDateOfLastMissedPlanPayment(setup_data.TestLoan, new_loan);
            Test.stopTest();

            System.assertEquals(1, MissedPlanPaymentHandler.getInstance().LoansWithMissedPayment.size(), 'Loan was not added to list of Loans with Missed Plan Payment');
        }
    }

    static testMethod void testUpdatingCasesWithMissedPaymentsWhenThereAreCasesRelatedToLoans() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-106', 'ZCP-149', 'ZCP-71'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            setup_data.createTestCase();
            MissedPlanPaymentHandler.getInstance().LoansWithMissedPayment.add(setup_data.TestLoan.Id);
            setup_data.updateTestCase('Arrangement Default', 'Collections');

            Test.startTest();
                MissedPlanPaymentHandler.getInstance().updateCasesWithMissedPayments();
            Test.stopTest();

            setup_data.reQueryTestCase();
            System.assertEquals('Arrangement Default', setup_data.TestCase.Previous_Sub_Process__c, 'Previous Sub Process was set incorect.');
            System.assertEquals('Broken Repayment Arrangement', setup_data.TestCase.Sub_Process__c, 'Sub Process was set incorect.');
            System.assertEquals(2, [SELECT COUNT() FROM Task WHERE Subject = 'Customer has missed a payment plan'], 'Should create 2 tasks. For Case and Loan.');
        }
    }

    static testMethod void testUpdatingCasesWithMissedPaymentsWhenThereAreNotCasesRelatedToLoans() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-106', 'ZCP-149', 'ZCP-71'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest();
            MissedPlanPaymentHandler.getInstance().LoansWithMissedPayment.add(setup_data.TestLoan.Id);

            Test.startTest();
                MissedPlanPaymentHandler.getInstance().updateCasesWithMissedPayments();
            Test.stopTest();

            System.assertEquals(1, [SELECT COUNT() FROM Task WHERE Subject = 'Customer has missed a payment plan'], 'Should create 1 task for Loan.');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Account TestAccount;
        public User TestUser;
        public Loan__c TestLoan;

        public SetupDataClass(String last_name) {
            FeatureSwitch.disable('ZCP-128');
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        private void createDataForTest() {
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('CaseCollectionsRecoveriesExtension')
                    .save()
                    .getRecord();
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setArrearsRatio(0)
                    .setExternalId('test')
                    .save()
                    .getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public void createTestCase() {
            TriggerHandler.IsTriggerActive = false;
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setLoan(TestLoan)
                    .save()
                    .getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public void reQueryTestCase() {
            TestCase = [SELECT Id, Sub_Process__c, Previous_Sub_Process__c, OwnerId FROM Case WHERE Id = : TestCase.Id];
        }

        public void reQueryTestLoan() {
            TestLoan = [SELECT id, State__c FROM Loan__c WHERE Id = : TestLoan.Id];
        }

        public void createLoan(){
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setExternalId(Utility.getRandomString(8))
                    .save()
                    .getRecord();
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }

        public void updateTestCase(String sub_process, String previous_sub_process){
            TestCase.Sub_Process__c = previous_sub_process;
            update TestCase;
            TestCase.Sub_Process__c = sub_process;
            update TestCase;
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.STANDARD_USER)
                .setLastName(STANDARD_USER)
                .save();
    }
}