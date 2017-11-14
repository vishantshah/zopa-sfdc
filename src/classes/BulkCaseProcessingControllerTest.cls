@isTest
private class BulkCaseProcessingControllerTest {
    private static final Integer BULK_SIZE = 40;

    static testMethod void testInitController() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.SelectAll, 'Should be false');
            System.assertEquals(new List<Case>(), setup_data.ClassUnderTest.SelectedCases, 'Should be initialized');
            System.assertNotEquals(null, setup_data.ClassUnderTest.PopupMessagesMap, 'Should be initialized');
            System.assertNotEquals(null, setup_data.ClassUnderTest.WrappedCases, 'Should be initialized');
            System.assertEquals(BULK_SIZE, setup_data.ClassUnderTest.WrappedCases.size(), 'Should be initialized');
        }
    }

    static testMethod void testApproveLoanAndWaiveQuickPaySuccessful() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectOneCaseToApproveAndWaveQuickPay();
            setup_data.ClassUnderTest.showApproveLoanAndWaiveQuickPayPopup();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            setup_data.reQueryCaseForApproveAndWaiveQuickPayTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals('Closed - Approved', setup_data.CaseForApproveAndWaiveQuickPayTest.Status, 'Status should be Closed - Approved');
        }
    }

    static testMethod void testApproveLoanAndWaiveQuickPayUnsuccessful() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.ClassUnderTest.WrappedCases[0].Selected = true;
            setup_data.ClassUnderTest.showApproveLoanAndWaiveQuickPayPopup();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            setup_data.queryCases();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertNotEquals('Closed - Approved', setup_data.TestCases[0].Status, 'Status should not be Closed - Approved');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Request error: Internal issues.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testShowApproveLoanAndWaiveQuickPayPopupSelectedMoreThanOneCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            Test.startTest();
                setup_data.ClassUnderTest.showApproveLoanAndWaiveQuickPayPopup();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should not set process');
            System.assert(MessageUtility.checkCurrentPageContainsExact('You can perform this action only for single case'), 'Should have message');
        }
    }

    static testMethod void testShowApproveLoanAndWaiveQuickPayPopupSelectedOneCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.ClassUnderTest.WrappedCases[0].Selected = true;
            Test.startTest();
                setup_data.ClassUnderTest.showApproveLoanAndWaiveQuickPayPopup();
            Test.stopTest();
            System.assertEquals(BulkCaseProcessingController.Process.APPROVE_LOAN_AND_WAIVE_QUICK_PAY, setup_data.ClassUnderTest.CurrentProcess, 'Should be correct process');
            System.assertEquals(1, setup_data.ClassUnderTest.SelectedCases.size(), 'Should get one selected case');
        }
    }

    static testMethod void testShowApproveLoanAndWaiveQuickPayPopupNoSelectedCases() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.showApproveLoanAndWaiveQuickPayPopup();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should not set process');
            System.assert(MessageUtility.checkCurrentPageContainsExact('Please, select at least one case'), 'Should have message');
        }
    }

    static testMethod void testGetIsZopa36IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-36');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa36IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZOPA-36 should be disabled');
        }
    }

    static testMethod void testSelectDeselectAllActionSelection() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setSelectAllForController(true);
            Test.startTest();
                setup_data.ClassUnderTest.selectDeselectAllAction();
            Test.stopTest();
            for (BulkCaseProcessingController.CaseWrapper wrapper : setup_data.ClassUnderTest.WrappedCases) {
                System.assertEquals(true, wrapper.Selected, 'Should be selected');
            }
        }
    }

    static testMethod void testSelectDeselectAllActionDeselection() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            setup_data.setSelectAllForController(false);
            Test.startTest();
                setup_data.ClassUnderTest.selectDeselectAllAction();
            Test.stopTest();
            for (BulkCaseProcessingController.CaseWrapper wrapper : setup_data.ClassUnderTest.WrappedCases) {
                System.assertEquals(false, wrapper.Selected, 'Should be selected');
            }
        }
    }

    static testMethod void testGetIsZopa37IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-37');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa37IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZOPA-37 should be disabled');
        }
    }

    static testMethod void testShowBulkMoveToCasePrepPopup() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            Test.startTest();
                setup_data.ClassUnderTest.showBulkMoveToCasePrepPopup();
            Test.stopTest();
            System.assertEquals(BulkCaseProcessingController.Process.BULK_MOVE_TO_CASE_PREP, setup_data.ClassUnderTest.CurrentProcess, 'Should be correct process');
            System.assertEquals(BULK_SIZE, setup_data.ClassUnderTest.SelectedCases.size(), 'Should get all selected cases');
        }
    }

    static testMethod void testShowBulkMoveToUnderwriterPopup() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            Test.startTest();
                setup_data.ClassUnderTest.showBulkMoveToUnderwriterPopup();
            Test.stopTest();
            System.assertEquals(BulkCaseProcessingController.Process.BULK_MOVE_TO_UNDERWRITERS, setup_data.ClassUnderTest.CurrentProcess, 'Should be correct process');
            System.assertEquals(BULK_SIZE, setup_data.ClassUnderTest.SelectedCases.size(), 'Should get all selected cases');
        }
    }

    static testMethod void testShowBulkMoveToFraudPopup() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            Test.startTest();
                setup_data.ClassUnderTest.showBulkMoveToFraudPopup();
            Test.stopTest();
            System.assertEquals(BulkCaseProcessingController.Process.BULK_MOVE_TO_FRAUD, setup_data.ClassUnderTest.CurrentProcess, 'Should be correct process');
            System.assertEquals(BULK_SIZE, setup_data.ClassUnderTest.SelectedCases.size(), 'Should get all selected cases');
        }
    }

    static testMethod void testShowBulkApprovePopup() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            Test.startTest();
                setup_data.ClassUnderTest.showBulkApprovePopup();
            Test.stopTest();
            System.assertEquals(BulkCaseProcessingController.Process.BULK_APPROVE_LOAN, setup_data.ClassUnderTest.CurrentProcess, 'Should be correct process');
            System.assertEquals(BULK_SIZE, setup_data.ClassUnderTest.SelectedCases.size(), 'Should get all selected cases');
        }
    }

    static testMethod void testPerformBulkMoveToActionCasePrep() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-59');
        FeatureSwitch.enable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            setup_data.ClassUnderTest.showBulkMoveToCasePrepPopup();
            Test.startTest();
                Integer dml_before = Limits.getDMLRows();
                setup_data.ClassUnderTest.confirmAction();
                Integer dml_after = Limits.getDMLRows();
            Test.stopTest();
            System.assert(MessageUtility.checkCurrentPageContainsExact('Updated succesfully!'), 'Should have success message');
        }
    }

    static testMethod void testPerformBulkMoveToActionFraud() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            setup_data.ClassUnderTest.showBulkMoveToFraudPopup();
            Test.startTest();
                Integer dml_before = Limits.getDMLRows();
                setup_data.ClassUnderTest.confirmAction();
                Integer dml_after = Limits.getDMLRows();
            Test.stopTest();
            System.assert(MessageUtility.checkCurrentPageContainsExact('Updated succesfully!'), 'Should have success message');
        }
    }

    static testMethod void testPerformBulkMoveToActionUnderwriterForCasesWithoutInitialUnderwriter() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            setup_data.ClassUnderTest.showBulkMoveToUnderwriterPopup();
            Test.startTest();
                Integer dml_before = Limits.getDMLRows();
                setup_data.ClassUnderTest.confirmAction();
                Integer dml_after = Limits.getDMLRows();
            Test.stopTest();
            System.assert(MessageUtility.checkCurrentPageContainsExact('Updated succesfully!'), 'Should have success message');

            for(Case test_case : setup_data.TestCases){
                System.assertEquals('Open', test_case.Status, 'Status should be changed to In Progress');
            }
        }
    }

    static testMethod void testPerformBulkMoveToActionUnderwriterForCasesWithInitialUnderwriter(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.setInitialUnderwriterForAllCases();
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            setup_data.ClassUnderTest.showBulkMoveToUnderwriterPopup();
            Test.startTest();
                Integer dml_before = Limits.getDMLRows();
                setup_data.ClassUnderTest.confirmAction();
                Integer dml_after = Limits.getDMLRows();
            Test.stopTest();

            setup_data.queryCases();
            System.assert(MessageUtility.checkCurrentPageContainsExact('Updated succesfully!'), 'Should have success message');

            for(Case test_case : setup_data.TestCases){
                System.assertEquals(setup_data.TestInitialUnderwriter.Id, test_case.OwnerId, 'Case should be assigned to it`s Initial Underwriter');
                System.assertEquals('In Progress', test_case.Status, 'Status should be changed to In Progress');
            }
        }
    }

    static testMethod void testPerformBulkApproveActionSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            setup_data.setMockForResponse(true);
            setup_data.ClassUnderTest.showBulkApprovePopup();
            Test.startTest();
                Integer dml_before = Limits.getDMLRows();
                setup_data.ClassUnderTest.confirmAction();
                Integer dml_after = Limits.getDMLRows();
            Test.stopTest();
            setup_data.queryCases();
            System.assert(MessageUtility.checkCurrentPageContainsExact('Loan applications approved succesfully!'), 'Should have success message');
            System.assertEquals(BULK_SIZE, setup_data.TestCases.size());
            for (Case new_case : setup_data.TestCases) {
                System.assertEquals('Closed - Approved', new_case.Status, 'Should change status');
            }
        }
    }

    static testMethod void testPerformBulkApproveActionUnsuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            setup_data.setMockForResponse(false);
            setup_data.ClassUnderTest.showBulkApprovePopup();
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            setup_data.queryCases();
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Request error: Internal issues.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(BULK_SIZE, setup_data.TestCases.size());
            for (Case new_case : setup_data.TestCases) {
                System.assertNotEquals('Closed - Approved', new_case.Status, 'Should not change status');
            }
        }
    }

    static testMethod void testPerformBulkApproveActionErroredSomeLoans() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.selectAllCasesForBulkAction();
            setup_data.setErroredBulApproveResponse(true);
            setup_data.ClassUnderTest.showBulkApprovePopup();
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            setup_data.queryCases();
            System.assert(MessageUtility.checkCurrentPageContainsExact('Failed to approve test2'), 'Should have error message');
            System.assert(MessageUtility.checkCurrentPageContainsExact('Failed to approve test3'), 'Should have error message');
            System.assert(MessageUtility.checkCurrentPageContainsExact('Failed to approve test7'), 'Should have error message');

            System.assert(MessageUtility.checkCurrentPageContainsExact('Some loan applications were approved succesfully!'), 'Should have success message');
            System.assertEquals(BULK_SIZE, setup_data.TestCases.size());
            for (Case new_case : setup_data.TestCases) {
                if(new_case.Loan_Application__r.Loan_ID__c == 'test2'||new_case.Loan_Application__r.Loan_ID__c == 'test3'||new_case.Loan_Application__r.Loan_ID__c == 'test7'){
                    System.assertNotEquals('Closed - Approved', new_case.Status, 'Should not change status');
                }else{
                    System.assertEquals('Closed - Approved', new_case.Status, 'Should change status');
                }
            }
        }
    }

    private class SetupDataClass {
        public List<Case> TestCases;
        public Case CaseForApproveAndWaiveQuickPayTest;
        public List<Loan_Application__c> TestLoanApplications;
        public Account TestAccount;
        public User TestUser;
        public User TestInitialUnderwriter;
        public BulkCaseProcessingController ClassUnderTest;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'BulkCaseProcessingControllerTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplications = [SELECT Id FROM Loan_Application__c LIMIT :BULK_SIZE];
            TestInitialUnderwriter = [SELECT Id FROM User WHERE LastName = 'InitialUnderwriter' LIMIT 1];
            queryCases();
        }

        public void initClassUnderTest() {
            ClassUnderTest = new BulkCaseProcessingController();
        }

        public void selectAllCasesForBulkAction() {
            for (BulkCaseProcessingController.CaseWrapper wrapped_case : ClassUnderTest.WrappedCases) {
                wrapped_case.Selected = true;
            }
        }

        public void setInitialUnderwriterForAllCases(){
            for(Case test_case : TestCases){
                test_case.Initial_Underwriter__c = TestInitialUnderwriter.Id;
            }
            update TestCases;
        }

        public void selectOneCaseToApproveAndWaveQuickPay(){
            ClassUnderTest.WrappedCases[0].Selected = true;
            CaseForApproveAndWaiveQuickPayTest = ClassUnderTest.WrappedCases[0].CaseRecord;
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }

        public void setErroredBulApproveResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success, true));
        }

        public void setSelectAllForController(Boolean select_all) {
            ClassUnderTest.SelectAll = select_all;
        }

        public void queryCases() {
            TestCases = [SELECT Id, Status, Loan_Application__r.Loan_ID__c, OwnerId FROM Case];
        }

        public void reQueryCaseForApproveAndWaiveQuickPayTest(){
            CaseForApproveAndWaiveQuickPayTest = [SELECT Id, Status FROM Case WHERE Id=:CaseForApproveAndWaiveQuickPayTest.Id];
        }
    }

    @testSetup
    static void setupTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('BulkCaseProcessingControllerTest')
                                     .save().getRecord();

        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                                     .setLastName('InitialUnderwriter')
                                     .save();

        System.runAs(test_user) {
            FeatureSwitch.enable('ZOPA-4');
            Account test_account = AccountBuilder.getBuilder('BulkCaseProcessingControllerTest').save().getRecord();
            List<Loan_Application__c> loans = new List<Loan_Application__c>();
            for (Integer i = 0; i < BULK_SIZE; i++) {
                loans.add(LoanApplicationBuilder.getBuilder(test_account).setApplicationStatus('RequiresManualUnderwriting').setExternalId('test'+i).setTriggeredReferralCodes('test').setQuickPay(true).getRecord());
            }
            insert loans;
            List<Case> cases = [SELECT OwnerId FROM Case LIMIT :BULK_SIZE];
            Id team_leader_queue_id = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.TEAM_LEADER);
            for (Case team_leader_case : cases) {
                team_leader_case.OwnerId = team_leader_queue_id;
            }
            update cases;
        }
    }
}