@isTest
public class AutoCancelLoanJobTest {

    static testMethod void testCancelLoanActionSuccessRequestOpenCase() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-48');
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createCase();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.updateCaseAsAutoCanceled();
            Test.stopTest();
            setup_data.queryCase();
            System.assertEquals('Closed - Auto Cancelled', setup_data.TestCase.Status, 'Should be auto canceled');
            System.assertEquals(false, setup_data.TestCase.Auto_Canceled_Loan__c, 'Should be false');
        }
    }

    static testMethod void testCancelLoanActionSuccessRequestOpenCaseDisabledZopa48() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-48');
        System.runAs(setup_data.TestUser) {
            setup_data.createCase();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.updateCaseAsAutoCanceled();
            Test.stopTest();
            setup_data.queryCase();
            System.assertNotEquals('Closed - Auto Cancelled', setup_data.TestCase.Status, 'Should not be auto canceled');
        }
    }

    static testMethod void testCancelLoanActionSuccessRequestClosedCase() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-48');
        System.runAs(setup_data.TestUser) {
            setup_data.createCase();
            setup_data.closeCase();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.updateCaseAsAutoCanceled();
            Test.stopTest();
            setup_data.queryCase();
            System.assertNotEquals('Closed - Auto Cancelled', setup_data.TestCase.Status, 'Should not be auto canceled');
        }
    }

    static testMethod void testCancelLoanActionUnsuccessRequestOpenCase() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-48');
        System.runAs(setup_data.TestUser) {
            setup_data.createCase();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.updateCaseAsAutoCanceled();
            Test.stopTest();
            setup_data.queryCase();
            System.assertNotEquals('Closed - Auto Cancelled', setup_data.TestCase.Status, 'Should not be auto canceled');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public User TestUser;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'AutoCancelLoanJobTest' AND FirstName = 'AutoCancelLoanJobTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplication = [SELECT Id, Loan_ID__c FROM Loan_Application__c LIMIT 1];
        }

        public void createCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
            queryCase();
        }

        public void queryCase() {
            TestCase = [SELECT Status, Auto_Canceled_Loan__c, RecordTypeId, IsClosed FROM Case WHERE Loan_Application__c = :TestLoanApplication.Id LIMIT 1];
        }

        public void closeCase() {
            TestCase.Status = 'Closed';
            update TestCase;
            queryCase();
        }

        public void updateCaseAsAutoCanceled() {
            TestCase.Auto_Canceled_Loan__c = true;
            update TestCase;
            queryCase();
        }

        public void setMockForResponse(Boolean is_success) {
            ApiCommandTestMock.SetIsSuccess = is_success;
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.TEAM_LEADER)
                                     .setFirstName('AutoCancelLoanJobTest')
                                     .setLastName('AutoCancelLoanJobTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            FeatureSwitch.disable('ZOPA-4');
            Account test_account = AccountBuilder.getBuilder('AutoCancelLoanJobTest').save().getRecord();
            LoanApplicationBuilder.getBuilder(test_account).setExternalId('test').save();
        }
    }
}