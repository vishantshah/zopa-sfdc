@isTest
public class CaseManualUnderwriterExtensionTest {
    private static final String CASE_PREP_USER = 'CaseViewCasePrep';
    private static final String FRAUD_USER = 'CaseViewFraud';
    private static final String UNDERWRITER_USER = 'CaseViewUnderwriting';
    private static final String UNDERWRITER_USER_WITHOUT_CASE = 'CaseViewUnderwritingWithoutOwnership';
    private static final String TEAM_LEADER_USER = 'CaseViewTeamLeader';
    private static final String STANDARD_USER = 'CaseViewStandard';
    private static final String SYSADMIN = 'CaseViewSysAdmin';
    private static final String PEXLIFY_DEV_TEST_WITH_PERMISSIONS = 'PexlifyDevTestWithPermissions';
    private static final String PEXLIFY_DEV_TEST_WITHOUT_PERMISSIONS = 'PexlifyDevTestWithoutPermissions';

    static testMethod void testCaseViewExtensionInitialization() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            Test.startTest();
                setup_data.initController();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'By default should close tab');
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentCase.Id, 'Should be initialized by appropriate case');
        }
    }

    static testMethod void testShowPendingActionPopupForCasePrepElseUpdateStatusShowPopup() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-7');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createPendingTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showPendingActionPopupForCasePrepElseUpdateStatus();
            Test.stopTest();
            System.assertEquals(CaseManualUnderwriterExtension.Process.PENDING, setup_data.ClassUnderTest.CurrentProcess, 'Should be pending type');
            System.assertEquals(false, setup_data.ClassUnderTest.NeedToCloseTab, 'Should not close tab');
        }
    }

    static testMethod void testPendingActionForCasePrepAssignToQueueHidePopup() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-7');
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.PENDING);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should not stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals('Pending', setup_data.ClassUnderTest.CurrentCase.Status, 'Status should be Pending');
            System.assertEquals(setup_data.getCorrectQueueIdToAssignTo(CaseUtility.QueueName.PENDING_CASE_PREP), setup_data.ClassUnderTest.CurrentCase.OwnerId, 'Owner should be Pending Case Prep Queue');
        }
    }

    static testMethod void testMoveToTeamLeaderQueueAssignToQueueHidePopup() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-19');
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.APPROVE_LOAN);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should not stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals('Approved - Pending Admin Approval', setup_data.ClassUnderTest.CurrentCase.Status, 'Status should be Approved - Pending Admin Approval');
            System.assertEquals(setup_data.getCorrectQueueIdToAssignTo(CaseUtility.QueueName.TEAM_LEADER), setup_data.ClassUnderTest.CurrentCase.OwnerId, 'Owner should be Team Leader Queue');
        }
    }

    static testMethod void testMoveToPendingLoanConslidationQueueAssignToQueueHidePopup() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-19');
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.PENDING_LOAN_CONSOLIDATION);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should not stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals('Pending Loan Consolidation', setup_data.ClassUnderTest.CurrentCase.Status, 'Status should be Pending Loan Consolidation');
            System.assertEquals(setup_data.getCorrectQueueIdToAssignTo(CaseUtility.QueueName.PENDING_LOAN_CONSOLIDATION), setup_data.ClassUnderTest.CurrentCase.OwnerId, 'Owner should be Pending Loan Consolidation Queue');
        }
    }

    static testMethod void testShowPendingActionPopupForCasePrepElseUpdateStatusUpdateTeamLead() {
        SetupDataClass setup_data = new SetupDataClass(TEAM_LEADER_USER);
        FeatureSwitch.enable('ZOPA-7');
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createPendingTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showPendingActionPopupForCasePrepElseUpdateStatus();
            Test.stopTest();
            System.assertEquals('Pending', setup_data.ClassUnderTest.CurrentCase.Status, 'Status should be Pending');
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should close tab');
        }
    }

    static testMethod void testShowPendingActionPopupForCasePrepElseUpdateStatusUpdateUnderwriterWithPendingTask() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        FeatureSwitch.enable('ZOPA-7');
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createPendingTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showPendingActionPopupForCasePrepElseUpdateStatus();
            Test.stopTest();
            System.assertEquals('Pending', setup_data.ClassUnderTest.CurrentCase.Status, 'Status should be Pending');
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should close tab');
        }
    }

    static testMethod void testShowPendingActionPopupForCasePrepElseUpdateStatusUpdateUnderwriterWithOutPendingTask() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        FeatureSwitch.enable('ZOPA-7');
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showPendingActionPopupForCasePrepElseUpdateStatus();
            Test.stopTest();
            System.assertNotEquals('Pending', setup_data.ClassUnderTest.CurrentCase.Status, 'Status should be Pending');
            System.assertEquals(false, setup_data.ClassUnderTest.NeedToCloseTab, 'Should close tab');
            System.assert(MessageUtility.checkCurrentPageContainsExact('The case should have at least one task of status Pending to perform this action'), 'Expected to have a warning message on the page');
        }
    }

    static testMethod void testShowPendingActionPopupForCasePrepElseUpdateStatusUpdateFraud() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        FeatureSwitch.enable('ZOPA-7');
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createPendingTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showPendingActionPopupForCasePrepElseUpdateStatus();
            Test.stopTest();
            System.assertEquals('Pending', setup_data.ClassUnderTest.CurrentCase.Status, 'Status should be Pending');
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should close tab');
        }
    }

    static testMethod void testGetShowSmartActivitySectionZopa9Enabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-9');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_shown = setup_data.ClassUnderTest.getShowSmartActivitySection();
            Test.stopTest();
            System.assertEquals(true, is_shown, 'Should be shown');
        }
    }

    static testMethod void testGetShowSmartActivitySectionZopa9Disabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-9');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_shown = setup_data.ClassUnderTest.getShowSmartActivitySection();
            Test.stopTest();
            System.assertEquals(false, is_shown, 'Should be hidden');
        }
    }

    static testMethod void testGetIsZopa10IsEnabledWhenEnabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-10');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa10IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZOPA-10 should be enabled');
        }
    }

    static testMethod void testGetIsZopa10IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-10');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa10IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZOPA-10 should be disabled');
        }
    }

    static testMethod void testGetIsZopa20IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-20');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa20IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZOPA-20 should be disabled');
        }
    }

    static testMethod void testGetIsZopa21IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-21');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa21IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZOPA-21 should be disabled');
        }
    }

    static testMethod void testGetIsZopa11IsEnabledWhenEnabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-11');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa11IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZOPA-11 should be enabled');
        }
    }

    static testMethod void testGetIsZopa11IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-11');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa11IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZOPA-11 should be disabled');
        }
    }

    static testMethod void testGetIsZopa22IsEnabledWhenEnabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-22');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa22IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZOPA-2 should be enabled');
        }
    }

    static testMethod void testGetIsZopa22IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-22');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa22IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZOPA-22 should be disabled');
        }
    }

    static testMethod void testGetIsZopa29IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-29');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa29IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZOPA-29 should be disabled');
        }
    }

    static testMethod void testGetIsZopa34IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-34');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa34IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZOPA-34 should be disabled');
        }
    }

    static testMethod void testGetIsZopa35IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-35');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa35IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZOPA-35 should be disabled');
        }
    }

    static testMethod void testGetIsSendTextButtonAvailableWhenCaseIsClosed() {
        SetupDataClass setup_data = new SetupDataClass(PEXLIFY_DEV_TEST_WITH_PERMISSIONS);
        System.runAs(setup_data.TestUser) {
            setup_data.createClosedManualUnderwritingCase();
            setup_data.reQueryTestCase();
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsSendTextButtonAvailable();
            Test.stopTest();

            System.assertEquals(false, result, 'Send Text button should not be available when Case is closed.');
        }
    }

    static testMethod void testGetIsSendTextButtonAvailableWhenCaseIsOpenAndUserHasPermissions() {
        SetupDataClass setup_data = new SetupDataClass(PEXLIFY_DEV_TEST_WITH_PERMISSIONS);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsSendTextButtonAvailable();
            Test.stopTest();

            System.assertEquals(true, result, 'Send Text button should be available when user has permissions and Case is open.');
        }
    }

    static testMethod void testGetIsSendTextButtonAvailableWhenCaseIsOpenAndUserHasNotPermissions() {
        SetupDataClass setup_data = new SetupDataClass(PEXLIFY_DEV_TEST_WITHOUT_PERMISSIONS);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsSendTextButtonAvailable();
            Test.stopTest();

            System.assertEquals(false, result, 'Send Text button should not be available when user has not permissions..');
        }
    }

    static testMethod void testMoveToUnderwritersFromCasePrep() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-10','ZOPA-89'});
        FeatureSwitch.disable('ZOPA-59');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.MOVE_TO_UNDERWRITERS_FROM_CASE_PREP);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should not stay on this tab');
            System.assertEquals('Open', setup_data.ClassUnderTest.CurrentCase.Status, 'Should be equals status');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
        }
    }

    static testMethod void testMoveToUnderwritersFromTeamLeader() {
        SetupDataClass setup_data = new SetupDataClass(TEAM_LEADER_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-22','ZOPA-89'});
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseWithInitialUnderwriter();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.MOVE_TO_UNDERWRITERS_FROM_TEAM_LEADER);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should not stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(setup_data.AssignedToUser.Id, setup_data.ClassUnderTest.CurrentCase.OwnerId, 'Should reassign to old underwriter');
        }
    }

    static testMethod void testMoveToUnderwritersFromTeamLeaderInitialUnderwriterIsBlank() {
        SetupDataClass setup_data = new SetupDataClass(TEAM_LEADER_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-22','ZOPA-89'});
        FeatureSwitch.disable('ZOPA-59');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseWithInitialUnderwriter();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.MOVE_TO_UNDERWRITERS_FROM_TEAM_LEADER);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should not stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals('Open', setup_data.ClassUnderTest.CurrentCase.Status, 'Should be equals status');
        }
    }

    static testMethod void testMoveToCasePrepFromUnderwriters() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        FeatureSwitch.enable('ZOPA-89');
        FeatureSwitch.disable('ZOPA-59');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.MOVE_TO_CASE_PREP);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should not stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals('Open', setup_data.ClassUnderTest.CurrentCase.Status, 'Should be equals status');
        }
    }

    static testMethod void testMoveToFraudFromUnderwriters() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        FeatureSwitch.enable('ZOPA-89');
        FeatureSwitch.disable('ZOPA-59');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.MOVE_TO_FRAUD);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should not stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals('Open', setup_data.ClassUnderTest.CurrentCase.Status, 'Should be equals status');}
    }

    static testMethod void testMakeQuickPaySuccesful() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.reQueryTestCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.MAKE_QUICK_PAY);
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            setup_data.assertPageMessage('The loan application was made quick pay successfully');
        }
    }

    static testMethod void testMakeQuickPayUnsuccesful() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.reQueryTestCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.MAKE_QUICK_PAY);
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.NeedToCloseTab, 'Should stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            setup_data.assertPageMessage('Internal issues.');
        }
    }

    static testMethod void testGetIsCancelLoanProcessForCancel() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.CANCEL_LOAN);
            Test.startTest();
                Boolean is_cancel_process = setup_data.ClassUnderTest.getIsCancelLoanProcess();
            Test.stopTest();
            System.assertEquals(true, is_cancel_process, 'Should be true');
        }
    }

    static testMethod void testGetIsCancelLoanProcessForApprove() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.APPROVE_LOAN);
            Test.startTest();
                Boolean is_cancel_process = setup_data.ClassUnderTest.getIsCancelLoanProcess();
            Test.stopTest();
            System.assertEquals(false, is_cancel_process, 'Should be false');
        }
    }

    static testMethod void testGetIsDeclineLoanProcessForDecline() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.DECLINE_LOAN);
            Test.startTest();
                Boolean is_decline_process = setup_data.ClassUnderTest.getIsDeclineLoanProcess();
            Test.stopTest();
            System.assertEquals(true, is_decline_process, 'Should be true');
        }
    }

    static testMethod void testGetIsDeclineLoanProcessForApprove() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.APPROVE_LOAN);
            Test.startTest();
                Boolean is_decline_process = setup_data.ClassUnderTest.getIsDeclineLoanProcess();
            Test.stopTest();
            System.assertEquals(false, is_decline_process, 'Should be false');
        }
    }

    static testMethod void testCancelLoanActionSuccessful() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable(new Set<String>{'ZOPA-23','ZOPA-4','ZOPA-89'});
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.reQueryTestCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.CANCEL_LOAN);
            setup_data.setMockForResponse(true);
            setup_data.setCancelReason('TOOK_TOO_LONG');
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            setup_data.reQueryTestCase();
            setup_data.reQueryTestLoanApplication();
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should not stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals('Closed - Cancelled', setup_data.TestCase.Status, 'Status should be Closed - Cancelled');
            System.assertEquals('Zopa took too long', setup_data.TestLoanApplication.Cancel_Decline_Reason__c, 'Cancel_Decline_Reason__c of loan should be equal to Zopa took too long');
        }
    }

    static testMethod void testCancelLoanActionUnsuccessful() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable(new Set<String>{'ZOPA-23','ZOPA-4'});
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.reQueryTestCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.CANCEL_LOAN);
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            setup_data.reQueryTestCase();
            System.assertEquals(false, setup_data.ClassUnderTest.NeedToCloseTab, 'Should stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertNotEquals('Closed - Cancelled', setup_data.TestCase.Status, 'Status should be Closed - Cancelled');
            setup_data.assertPageMessage('Internal issues.');
        }
    }

    static testMethod void testDeclineLoanActionSuccessful() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable(new Set<String>{'ZOPA-23','ZOPA-4','ZOPA-89'});
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.reQueryTestCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.DECLINE_LOAN);
            setup_data.setMockForResponse(true);
            setup_data.setDeclineReason('InsufficientInfo');
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            setup_data.reQueryTestCase();
            setup_data.reQueryTestLoanApplication();
            System.assertEquals(true, setup_data.ClassUnderTest.NeedToCloseTab, 'Should not stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals('Closed - Declined', setup_data.TestCase.Status, 'Status should be Closed - Declined');
            System.assertEquals('Insufficient Info', setup_data.TestLoanApplication.Cancel_Decline_Reason__c, 'Cancel_Decline_Reason__c of loan should be equal to Insufficient Info');
        }
    }

    static testMethod void testDeclineLoanActionUnsuccessful() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable(new Set<String>{'ZOPA-23','ZOPA-4'});
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.reQueryTestCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseManualUnderwriterExtension.Process.DECLINE_LOAN);
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            setup_data.reQueryTestCase();
            System.assertEquals(false, setup_data.ClassUnderTest.NeedToCloseTab, 'Should stay on this tab');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertNotEquals('Closed - Declined', setup_data.TestCase.Status, 'Status should not be Closed - Declined');
            setup_data.assertPageMessage('Internal issues.');
        }
    }

    static testMethod void testShowDeclineLoanPopupAllowedClose() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createRejectedTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showDeclineLoanPopup();
            Test.stopTest();
            System.assertEquals(CaseManualUnderwriterExtension.Process.DECLINE_LOAN, setup_data.ClassUnderTest.CurrentProcess, 'Should be Decline Loan type even with open tasks');
        }
    }

    static testMethod void testShowDeclineLoanPopupNotAllowedClose() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showDeclineLoanPopup();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null, if there no rejected Task');
            System.assert(MessageUtility.checkCurrentPageContainsExact('The case should have at least one task of status Rejected to perform this action'), 'Expected to have a warning message on the page');
        }
    }

    static testMethod void testShowDeclineLoanPopupByOwnerOfCase(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createRejectedTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showDeclineLoanPopup();
            Test.stopTest();
            System.assertEquals(CaseManualUnderwriterExtension.Process.DECLINE_LOAN, setup_data.ClassUnderTest.CurrentProcess, 'Should be DECLINE_LOAN, if Case has rejected task and it was clicked by case owner');
        }
    }

    static testMethod void testShowDeclineLoanPopupNotByOwnerOfCase(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        setup_data.createUserWithoutCaseOwnership();
        System.runAs(setup_data.TestUserWithoutCaseOwnership) {
            setup_data.createManualUnderwritingCaseWithOwner();
            setup_data.createRejectedTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showDeclineLoanPopup();
            Test.stopTest();
            System.assertNotEquals(setup_data.TestCase.OwnerId, setup_data.TestUserWithoutCaseOwnership.Id);
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null if declination clicked not by owner of case');
            System.assert(MessageUtility.checkCurrentPageContainsExact('Only the owner of the case can decline the loan'), 'Expected to have a warning message on the page');
        }
    }

    static testMethod void testAssignToMeAssignToContextUser() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.assignToMe();
            Test.stopTest();
            setup_data.reQueryTestCase();
            System.assertEquals(setup_data.TestUser.Id, setup_data.TestCase.OwnerId, 'Should assign to context user');
            System.assert(MessageUtility.checkCurrentPageContainsExact('The case was assigned to you'), 'Expected to have a success message on the page');
        }
    }

    static testMethod void testShowCancelLoanPopup() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showCancelLoanPopup();
            Test.stopTest();
            System.assertEquals(CaseManualUnderwriterExtension.Process.CANCEL_LOAN, setup_data.ClassUnderTest.CurrentProcess, 'Should be Cancel Loan type even with open tasks');
        }
    }

    static testMethod void testShowMoveToCasePrepPopupFromUnderwriters() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createOpenTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showMoveToCasePrepPopup();
            Test.stopTest();
            System.assertEquals(CaseManualUnderwriterExtension.Process.MOVE_TO_CASE_PREP, setup_data.ClassUnderTest.CurrentProcess, 'Should be Move to Case-Prep type even with open tasks');
        }
    }

    static testMethod void testShowMoveToFraudPopupFromUnderwriters() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createOpenTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showMoveToFraudPopup();
            Test.stopTest();
            System.assertEquals(CaseManualUnderwriterExtension.Process.MOVE_TO_FRAUD, setup_data.ClassUnderTest.CurrentProcess, 'Should be Move to Fraud type even with open tasks');
        }
    }

    static testMethod void testShowMoveToUnderwritersPopupFromCasePrep() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-10', 'ZOPA-15'});
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createOpenTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showMoveToUnderwritersPopupFromCasePrep();
            Test.stopTest();
            System.assertEquals(CaseManualUnderwriterExtension.Process.MOVE_TO_UNDERWRITERS_FROM_CASE_PREP, setup_data.ClassUnderTest.CurrentProcess, 'Should be Move to Underwriting type');
        }
    }

    static testMethod void testShowMoveToUnderwritersPopupFromTeamLeader() {
        SetupDataClass setup_data = new SetupDataClass(TEAM_LEADER_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-10', 'ZOPA-15'});
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createOpenTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showMoveToUnderwritersPopupFromTeamLeader();
            Test.stopTest();
            System.assertEquals(CaseManualUnderwriterExtension.Process.MOVE_TO_UNDERWRITERS_FROM_TEAM_LEADER, setup_data.ClassUnderTest.CurrentProcess, 'Should be Move to Underwriting type');
        }
    }

    static testMethod void testShowApproveLoanPopupZopa81Off() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        FeatureSwitch.enable('ZOPA-10');
        FeatureSwitch.disable(new Set<String>{'ZOPA-15','ZOPA-81'});
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createOpenTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showApproveLoanPopup();
            Test.stopTest();
            System.assertEquals(CaseManualUnderwriterExtension.Process.APPROVE_LOAN, setup_data.ClassUnderTest.CurrentProcess, 'Should be ApproveLoan type');
        }
    }

    static testMethod void testShowApproveLoanPopupZopa81OnConsolidationSuccessResponsePaymentPending() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-10','ZOPA-81'});
        FeatureSwitch.disable('ZOPA-15');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createOpenTaskForTheCase();
            setup_data.initController();
            setup_data.setMockForConsolidationResponse(true, false);
            Test.startTest();
                setup_data.ClassUnderTest.showApproveLoanPopup();
            Test.stopTest();
            System.assertEquals(CaseManualUnderwriterExtension.Process.PENDING_LOAN_CONSOLIDATION, setup_data.ClassUnderTest.CurrentProcess, 'Should be ApproveLoan type');
        }
    }

    static testMethod void testShowApproveLoanPopupZopa81OnConsolidationSuccessResponseNoPaymentPending() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-10','ZOPA-81'});
        FeatureSwitch.disable('ZOPA-15');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createOpenTaskForTheCase();
            setup_data.initController();
            setup_data.setMockForConsolidationResponse(true, true);
            Test.startTest();
                setup_data.ClassUnderTest.showApproveLoanPopup();
            Test.stopTest();
            System.assertEquals(CaseManualUnderwriterExtension.Process.APPROVE_LOAN, setup_data.ClassUnderTest.CurrentProcess, 'Should be ApproveLoan type');
        }
    }

    static testMethod void testShowApproveLoanPopupZopa81OnConsolidationErrorResponse() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-10','ZOPA-81'});
        FeatureSwitch.disable('ZOPA-15');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createOpenTaskForTheCase();
            setup_data.initController();
            setup_data.setMockForConsolidationResponse(false, true);
            Test.startTest();
                setup_data.ClassUnderTest.showApproveLoanPopup();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be ApproveLoan type');
            System.assert(MessageUtility.checkCurrentPageContainsExact('There has been an error checking if there are loans pending consolidation. Error: Internal Server Error: Internal Error'), 'Expected to have an error message on the page');
        }
    }

    static testMethod void testShowApproveLoanPopupOpenTasksForbidToSubmit() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-10', 'ZOPA-15'});
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.createOpenTaskForTheCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showApproveLoanPopup();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should not show popup');
            setup_data.assertPageMessage('You cannot approve this loan application. The manual underwriting case still has open tasks. If you cannot see the open tasks please contact your team lead');
        }
    }

    static testMethod void testShowApproveLoanPopupNoOpenTask() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-10', 'ZOPA-15', 'ZOPA-81'});
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            setup_data.setMockForConsolidationResponse(true, true);
            Test.startTest();
                setup_data.ClassUnderTest.showApproveLoanPopup();
            Test.stopTest();
            System.assertEquals(CaseManualUnderwriterExtension.Process.APPROVE_LOAN, setup_data.ClassUnderTest.CurrentProcess, 'Should be ApproveLoan type');
        }
    }

    static testMethod void testHidePopup() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        FeatureSwitch.enable('ZOPA-10');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.hidePopup();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
        }
    }

    static testMethod void testGetIsCaseNotClosedOpenCase() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-17');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.reQueryTestCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_not_blocked = setup_data.ClassUnderTest.getIsCaseNotClosed();
            Test.stopTest();
            System.assertEquals(true, is_not_blocked, 'Open case should not be blocked for Case Prep');
        }
    }

    static testMethod void testGetIsCaseNotClosedClosedCase() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-17');
        System.runAs(setup_data.TestUser) {
            setup_data.createClosedManualUnderwritingCase();
            setup_data.reQueryTestCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_not_blocked = setup_data.ClassUnderTest.getIsCaseNotClosed();
            Test.stopTest();
            System.assertEquals(false, is_not_blocked, 'Closed case should be blocked for Case Prep');
        }
    }

    static testMethod void testGetIsCaseNotClosedClosedCaseDisabledZopa17() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-17');
        System.runAs(setup_data.TestUser) {
            setup_data.createClosedManualUnderwritingCase();
            setup_data.reQueryTestCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_not_blocked = setup_data.ClassUnderTest.getIsCaseNotClosed();
            Test.stopTest();
            System.assertEquals(true, is_not_blocked, 'Closed case should not be blocked if disable FeatureSwitch');
        }
    }

    static testMethod void testFixOmniChannelConflict() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-23', 'ZOPA-16','ZCP-74'});
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseWithOwner();
            setup_data.reQueryTestCase();
            setup_data.initController();
            setup_data.ClassUnderTest.CurrentCase = setup_data.TestCase;
            Test.startTest();
                setup_data.ClassUnderTest.fixOmniChannelConflict();
            Test.stopTest();
            setup_data.reQueryTestCase();
            System.assertEquals(setup_data.TestUser.Id, setup_data.TestCase.Initial_Underwriter__c, 'Case should be populated');
            System.assertEquals('In Progress', setup_data.TestCase.Status, 'Case should be in progress');
        }
    }

    static testMethod void testFixOmniChannelConflictDisabled() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        FeatureSwitch.disable(new Set<String>{'ZOPA-23', 'ZOPA-16','ZCP-74'});
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseWithOwner();
            setup_data.reQueryTestCase();
            setup_data.initController();
            setup_data.ClassUnderTest.CurrentCase = setup_data.TestCase;
            Test.startTest();
                setup_data.ClassUnderTest.fixOmniChannelConflict();
            Test.stopTest();
            setup_data.reQueryTestCase();
            System.assertEquals(null, setup_data.TestCase.Initial_Underwriter__c, 'Case should not be populated');
        }
    }

    static testMethod void testGetisInitialUnderwriterReasonRequiredToDisplayWithCaseStatusCanceled(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseWithCanceledStatus();
            Test.startTest();
                setup_data.initController();
                setup_data.ClassUnderTest.CurrentCase = setup_data.TestCase;
                Boolean result =setup_data.ClassUnderTest.getisInitialUnderwriterReasonRequiredToDisplay();
            Test.stopTest();
            System.assertEquals(true, result, 'Result is not correct when case status is equal to' + setup_data.TestCase.Status);
        }
    }

    static testMethod void testGetisInitialUnderwriterReasonRequiredToDisplayWithCaseStatusDeclined(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseWithDeclinedStatus();
            Test.startTest();
                setup_data.initController();
                setup_data.ClassUnderTest.CurrentCase = setup_data.TestCase;
                Boolean result =setup_data.ClassUnderTest.getisInitialUnderwriterReasonRequiredToDisplay();
            Test.stopTest();
            System.assertEquals(true, result, 'Result is not correct when case status is equal to' + setup_data.TestCase.Status);
        }
    }

    static testMethod void testGetisInitialUnderwriterReasonRequiredToDisplayWithAutoCancelStatus(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseWithAutoDeclinedStatus();
            Test.startTest();
                setup_data.initController();
                setup_data.ClassUnderTest.CurrentCase = setup_data.TestCase;
                Boolean result =setup_data.ClassUnderTest.getisInitialUnderwriterReasonRequiredToDisplay();
            Test.stopTest();
            System.assertEquals(false, result, 'Result is not correct when case status is equal to' + setup_data.TestCase.Status);
        }
    }

    static testMethod void testGetBlankEmailTemplate(){
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseWithOwner();
            setup_data.initController();

            Test.startTest();
                String result = setup_data.ClassUnderTest.getBlankEmailTemplate();
            Test.stopTest();

            String blank_email_template_id = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Blank_Template' LIMIT 1].Id;
            System.assertEquals('&template_id=' + blank_email_template_id, result, 'Should return url parameter for Blank_Template email template.');
        }
    }

    static testMethod void testGetDocumentReminderTemplate(){
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseWithOwner();
            setup_data.initController();

            Test.startTest();
                String result = setup_data.ClassUnderTest.getDocumentReminderTemplate();
            Test.stopTest();

            String email_template_id = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'DocReqRem' LIMIT 1].Id;
            System.assertEquals('&template_id=' + email_template_id, result, 'Should return url parameter for DocReqRem email template.');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Loan_Application__c TestLoanApplication;
        public Account TestAccount;
        public CaseManualUnderwriterExtension ClassUnderTest;
        public User TestUser;
        public User TestUserWithoutCaseOwnership;
        public User AssignedToUser;
        private Id EmailTemplateId;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        public void createUserWithoutCaseOwnership(){
            TestUserWithoutCaseOwnership = [SELECT Id FROM User WHERE LastName =:UNDERWRITER_USER_WITHOUT_CASE LIMIT 1];
        }

        private void createDataForCase() {
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('CaseManualUnderwriterExtension').save().getRecord();
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus('RequiresManualUnderwriting').setExpiryDate(System.now()).setExternalId(Utility.getRandomString(8)).save().getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public void createManualUnderwritingCaseWithInitialUnderwriter() {
            createDataForCase();
            AssignedToUser = [SELECT Id FROM User WHERE LastName = :UNDERWRITER_USER LIMIT 1];
            TestCase = CaseBuilder.getBuilder(TestAccount).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).setInitialUnderwriter(AssignedToUser.Id).save().getRecord();
        }

        public void createManualUnderwritingCaseWithCanceledStatus(){
            TestCase = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).setStatus('Closed - Cancelled').save().getRecord();
        }


        public void createManualUnderwritingCaseWithDeclinedStatus(){
            TestCase = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).setStatus('Closed - Declined').save().getRecord();
        }

        public void createManualUnderwritingCaseWithAutoDeclinedStatus(){
            TestCase = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).setStatus('Closed - Auto Cancelled').save().getRecord();
        }

        public void createManualUnderwritingCase() {
            createDataForCase();
            TestCase = CaseBuilder.getBuilder(TestAccount).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createManualUnderwritingCaseWithOwner() {
            createDataForCase();
            TestCase = CaseBuilder.getBuilder(TestAccount).setLoanApplication(TestLoanApplication).setOwner(TestUser.Id).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createClosedManualUnderwritingCase() {
            createDataForCase();
            TestCase = CaseBuilder.getBuilder(TestAccount).setStatus('Closed - Auto Approved').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createPendingTaskForTheCase() {
            TaskBuilder.getBuilder().setRelatedTo(TestCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setTaskFor('Case-Prep').setStatus('Pending').save();
        }

        public void createOpenTaskForTheCase() {
            TaskBuilder.getBuilder().setRelatedTo(TestCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setTaskFor('Case-Prep').setStatus('Open').save();
        }

        public void createRejectedTaskForTheCase() {
            TaskBuilder.getBuilder().setRelatedTo(TestCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setTaskFor('Case-Prep').setStatus('Rejected').save();
        }

        public void createCustomerCase() {
            createDataForCase();
            TestCase = CaseBuilder.getBuilder(TestAccount).setStatus('Open').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_CUSTOMER).save().getRecord();
        }

        public void initController() {
            ClassUnderTest = new CaseManualUnderwriterExtension(new ApexPages.StandardController(TestCase));
        }

        public void setControllerProcess(CaseManualUnderwriterExtension.Process process) {
            ClassUnderTest.CurrentProcess = process;
        }

        public void setCancelReason(String cancel_reason){
            ClassUnderTest.CancellationReason = cancel_reason;
        }

        public void setDeclineReason(String decline_reason){
            ClassUnderTest.DeclineReason = decline_reason;
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }

        public void setMockForConsolidationResponse(Boolean is_success, Boolean is_empty) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanConsolidationCandidatesTestMock(is_success, is_empty));
        }

        public void createEmailTemplateIfNotExist() {
            List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Documents_Reminder'];
            if (templates.size() == 0) {
                EmailTemplate test_template = new EmailTemplate(DeveloperName = 'Documents_Reminder', Name = 'TestCaseView', TemplateType = 'text', FolderId = UserInfo.getUserId());
                insert test_template;
                EmailTemplateId = test_template.Id;
            } else {
                EmailTemplateId = templates.get(0).Id;
            }
        }

        public Id getCorrectQueueIdToAssignTo(CaseUtility.QueueName queue) {
            return CaseUtility.getInstance().getQueueIdFromName(queue);
        }

        public void reQueryTestCase() {
            TestCase = [SELECT First_Time_Picked__c, IsClosed, Subject, Status, Loan_Application__r.Loan_ID__c, Initial_Underwriter__c,Owner.Profile.Name,RecordTypeId FROM Case WHERE Id = : TestCase.Id];
        }

        public void reQueryTestLoanApplication(){
            TestLoanApplication = [SELECT Cancel_Decline_Reason__c FROM Loan_Application__c WHERE Id=:TestCase.Loan_Application__r.Id];
        }

        public void setLoanToCase() {
            ClassUnderTest.CurrentCase.Loan_Application__r = TestLoanApplication;
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

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.STANDARD_USER)
                .setLastName(STANDARD_USER)
                .save();
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName(SYSADMIN)
                .save();
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                .setLastName(CASE_PREP_USER)
                .save();
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                .setLastName(UNDERWRITER_USER)
                .save();
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                .setLastName(UNDERWRITER_USER_WITHOUT_CASE)
                .save();
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.FRAUD)
                .setLastName(FRAUD_USER)
                .save();
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.TEAM_LEADER)
                .setLastName(TEAM_LEADER_USER)
                .save();
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.PEXLIFY_DEV_TEST_WITH_PERMISSIONS)
                .setLastName(PEXLIFY_DEV_TEST_WITH_PERMISSIONS)
                .save();
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.PEXLIFY_DEV_TEST_WITHOUT_PERMISSIONS)
                .setLastName(PEXLIFY_DEV_TEST_WITHOUT_PERMISSIONS)
                .save();
    }
}