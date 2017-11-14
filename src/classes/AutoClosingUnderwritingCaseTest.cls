@isTest
private class AutoClosingUnderwritingCaseTest {

    static testMethod void testHandleOldLoanApplicationWhenStatusNotChanged() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithOpenCase();
            setup_data.setNewLoanStatus('RequiresManualUnderwriting');

            Test.startTest();
                setup_data.ClassUnderTest.handleOldLoanApplicationsAndPrepareCasesToUpdate(setup_data.getOldLoanAsMap(), setup_data.getNewLoanAsMap());
            Test.stopTest();

            System.assertEquals(0, setup_data.ClassUnderTest.CasesToUpdate.size(), 'Application, not handled. There are no cases to update.');
        }
    }

    static testMethod void testHandleOldLoanApplicationAndPrepareCaseWhenCaseIsClosed() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithClosedCase();
            setup_data.setNewLoanStatus('Approved');

            Test.startTest();
                setup_data.ClassUnderTest.handleOldLoanApplicationsAndPrepareCasesToUpdate(setup_data.getOldLoanAsMap(), setup_data.getNewLoanAsMap());
            Test.stopTest();

            System.assertEquals(0, setup_data.ClassUnderTest.CasesToUpdate.size(), 'There are no open related cases.');
        }
    }

    static testMethod void testHandleOldLoanApplicationAndPrepareCaseWhenApplicationIsApproved() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithOpenCase();
            setup_data.setNewLoanStatus('Approved');

            Test.startTest();
                setup_data.ClassUnderTest.handleOldLoanApplicationsAndPrepareCasesToUpdate(setup_data.getOldLoanAsMap(), setup_data.getNewLoanAsMap());
            Test.stopTest();

            System.assertEquals(1, setup_data.ClassUnderTest.CasesToUpdate.size(), 'Should prepare one case.');
            System.assertEquals('Closed - Approved', setup_data.ClassUnderTest.CasesToUpdate[0].Status, 'Should set "Closed - Approved" Case status.');
        }
    }

    static testMethod void testHandleOldLoanApplicationAndPrepareCaseWhenApplicationIsDeclined() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithOpenCase();
            setup_data.setNewLoanStatus('Declined');

            Test.startTest();
                setup_data.ClassUnderTest.handleOldLoanApplicationsAndPrepareCasesToUpdate(setup_data.getOldLoanAsMap(), setup_data.getNewLoanAsMap());
            Test.stopTest();

            System.assertEquals(1, setup_data.ClassUnderTest.CasesToUpdate.size(), 'Should prepare one case.');
            System.assertEquals('Closed - Declined', setup_data.ClassUnderTest.CasesToUpdate[0].Status, 'Should set "Closed - Declined" Case status.');
        }
    }

    static testMethod void testHandleOldLoanApplicationAndPrepareCaseWhenApplicationIsCancelled() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithOpenCase();
            setup_data.setNewLoanStatus('Cancelled');

            Test.startTest();
                setup_data.ClassUnderTest.handleOldLoanApplicationsAndPrepareCasesToUpdate(setup_data.getOldLoanAsMap(), setup_data.getNewLoanAsMap());
            Test.stopTest();

            System.assertEquals(1, setup_data.ClassUnderTest.CasesToUpdate.size(), 'Should prepare one case.');
            System.assertEquals('Closed - Cancelled', setup_data.ClassUnderTest.CasesToUpdate[0].Status, 'Should set "Closed - Cancelled" Case status.');
        }
    }

    static testMethod void testHandleOldLoanApplicationAndPrepareCaseWhenApplicationIsAutoApproved() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithOpenCase();
            setup_data.setNewLoanStatus('AutoApproved');

            Test.startTest();
                setup_data.ClassUnderTest.handleOldLoanApplicationsAndPrepareCasesToUpdate(setup_data.getOldLoanAsMap(), setup_data.getNewLoanAsMap());
            Test.stopTest();

            System.assertEquals(1, setup_data.ClassUnderTest.CasesToUpdate.size(), 'Should prepare one case.');
            System.assertEquals('Closed - Auto Approved', setup_data.ClassUnderTest.CasesToUpdate[0].Status, 'Should set "Closed - Auto Approved" Case status.');
        }
    }

    static testMethod void testHandleOldLoanApplicationAndPrepareCaseWhenApplicationIsAutoDeclined() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithOpenCase();
            setup_data.setNewLoanStatus('AutoDeclined');

            Test.startTest();
                setup_data.ClassUnderTest.handleOldLoanApplicationsAndPrepareCasesToUpdate(setup_data.getOldLoanAsMap(), setup_data.getNewLoanAsMap());
            Test.stopTest();

            System.assertEquals(1, setup_data.ClassUnderTest.CasesToUpdate.size(), 'Should prepare one case.');
            System.assertEquals('Closed - Auto Declined', setup_data.ClassUnderTest.CasesToUpdate[0].Status, 'Should set "Closed - Auto Declined" Case status.');
        }
    }

    static testMethod void testUpdateCasesForHandledLoanApplications() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithOpenCase();
            setup_data.setNewLoanStatus('Approved');
            setup_data.ClassUnderTest.handleOldLoanApplicationsAndPrepareCasesToUpdate(setup_data.getOldLoanAsMap(), setup_data.getNewLoanAsMap());
            System.assertEquals(1, setup_data.ClassUnderTest.CasesToUpdate.size(), 'Should prepare one case.');
            System.assertEquals('Closed - Approved', setup_data.ClassUnderTest.CasesToUpdate[0].Status, 'Should set "Closed - Approved" Case status.');

            Test.startTest();
                setup_data.ClassUnderTest.updateCases();
                setup_data.queryCase();
            Test.stopTest();

            System.assertEquals('Closed - Approved', setup_data.TestCase.Status, 'Case status changed.');
        }
    }

    private class SetupDataClass {
        public AutoClosingUnderwritingCase ClassUnderTest;
        public Account TestAccount;
        public Loan_Application__c TestOldLoanApplication;
        public Loan_Application__c TestNewLoanApplication;
        public Case TestCase;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'AutoClosingUnderwritingCaseTest' AND FirstName = 'AutoClosingUnderwritingCaseTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            FeatureSwitch.enable('ZOPA-4');
            ClassUnderTest = AutoClosingUnderwritingCase.getInstance();
        }

        public void createLoanWithClosedCase() {
            createLoanWithOpenCase();
            TestCase.Status = 'Closed - Auto Approved';
            update TestCase;
        }

        public void createLoanWithOpenCase() {
            TestOldLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus('RequiresManualUnderwriting').setTriggeredReferralCodes('test').save().getRecord();
            queryCase();
        }

        public void queryCase() {
            TestCase = [SELECT Status, OwnerId FROM Case WHERE Loan_Application__c = :TestOldLoanApplication.Id AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING) LIMIT 1];
        }

        public void setNewLoanStatus(String new_status) {
            TestNewLoanApplication = TestOldLoanApplication.clone(true, true);
            TestNewLoanApplication.Loan_Application_Status__c = new_status;
        }

        public Map<Id,Loan_Application__c> getOldLoanAsMap() {
            return new Map<Id,Loan_Application__c>{TestOldLoanApplication.Id => TestOldLoanApplication};
        }

        public Map<Id,Loan_Application__c> getNewLoanAsMap() {
            return new Map<Id,Loan_Application__c>{TestNewLoanApplication.Id => TestNewLoanApplication};
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('AutoClosingUnderwritingCaseTest')
                                     .setLastName('AutoClosingUnderwritingCaseTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('AutoClosingUnderwritingCaseTest').save().getRecord();
        }
    }
}