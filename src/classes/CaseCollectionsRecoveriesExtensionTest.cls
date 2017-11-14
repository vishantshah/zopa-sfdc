@isTest
public class CaseCollectionsRecoveriesExtensionTest {
    private static final String TEAM_LEADER_USER = 'CaseViewTeamLeader';
    private static final String STANDARD_USER = 'CaseViewStandard';
    private static final String SYSADMIN = 'CaseViewSysAdmin';
    private static final String PEXLIFY_DEV_TEST_WITH_PERMISSIONS = 'PexlifyDevTestWithPermissions';
    private static final String PEXLIFY_DEV_TEST_WITHOUT_PERMISSIONS = 'PexlifyDevTestWithoutPermissions';

    static testMethod void testCaseCollectionsRecoveriesExtensionInitialization() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            Test.startTest();
                setup_data.initController();
            Test.stopTest();
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentCase.Id, 'Should be initialized by appropriate case');
        }
    }

    static testMethod void testCaseCollectionsRecoveriesExtensionInitializationWithoutRelatedLoan() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            Test.startTest();
                setup_data.initControllerWithoutRelatedLoan();
            Test.stopTest();
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.CurrentCase.Id, 'Should be initialized by appropriate case');
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('This Case is not related to Loan!'), 'Proper message should be added');
        }
    }

    static testMethod void testInitActionsWhenApiCallSuccessful() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCaseWithOwner();
            setup_data.initController();
            setup_data.setLoanUuid();
            setup_data.setControllerTestLoan();
            setup_data.setMockForGetLoanDetails(true, 200);

            Test.startTest();
                setup_data.ClassUnderTest.initActions();
            Test.stopTest();

            System.assertNotEquals(null, setup_data.ClassUnderTest.RelatedLoanDetails, 'Related Loan Details should be set.');
        }
    }

    static testMethod void testInitActionsWhenApiCallFailed() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCaseWithOwner();
            setup_data.initController();
            setup_data.setLoanUuid();
            setup_data.setControllerTestLoan();
            setup_data.setMockForGetLoanDetails(false, 500);

            Test.startTest();
                setup_data.ClassUnderTest.initActions();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.RelatedLoanDetails, 'Related Loan Details should not be set.');
            System.assert(MessageUtility.checkCurrentPageContainsExact('Internal Server Error: Internal Error'), 'Proper message should be added.');
        }
    }

    static testMethod void testInitActionsWhenCaseIsNotRelatedToLoan() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCaseWithOwner();
            setup_data.initControllerWithoutRelatedLoan();

            Test.startTest();
                setup_data.ClassUnderTest.initActions();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.RelatedLoanDetails, 'Related Loan Details should not be set.');
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('This Case is not related to Loan!'), 'Proper message should be added');
        }
    }

    static testMethod void testInitActionsWithOmniFix() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-23', 'ZOPA-16', 'ZCP-74'});
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCaseWithOwner();
            setup_data.initController();
            setup_data.TestCase.Status = 'New';
            setup_data.ClassUnderTest.CurrentCase = setup_data.TestCase;
            setup_data.setLoanUuid();
            setup_data.setControllerTestLoan();
            setup_data.setMockForGetLoanDetails(true, 200);

            Test.startTest();
                setup_data.ClassUnderTest.initActionsWithOmniFix();
            Test.stopTest();

            System.assertEquals('In Progress', setup_data.TestCase.Status, 'Case should be in progress');
            System.assertNotEquals(null, setup_data.ClassUnderTest.RelatedLoanDetails, 'Related Loan Details should be set.');
        }
    }

    static testMethod void testGetIsSettleCaseButtonAvailableWhenShouldBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable(new Set<String>{'ZOPA-23', 'ZOPA-16', 'ZCP-74', 'ZCP-94'});
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            setup_data.setLoanDetailsWithState('Default');

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsSettleCaseButtonAvailable();
            Test.stopTest();

            System.assertEquals(true, result, 'Settle Case button should be available.');
        }
    }

    static testMethod void testGetIsSettleCaseButtonAvailableWhenShouldNotBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable(new Set<String>{'ZOPA-23', 'ZOPA-16', 'ZCP-74'});
        FeatureSwitch.disable('ZCP-94');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            setup_data.setLoanDetailsWithState('Not Default');

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsSettleCaseButtonAvailable();
            Test.stopTest();

            System.assertEquals(false, result, 'Settle Case button should not be available.');
        }
    }

    static testMethod void testGetIsMakeDefaultButtonAvailableWhenShouldBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable(new Set<String>{'ZOPA-23', 'ZOPA-16', 'ZCP-74', 'ZCP-76'});
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            setup_data.setLoanDetailsWithState('Not Default');

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsMakeDefaultButtonAvailable();
            Test.stopTest();

            System.assertEquals(true, result, 'Make Default button should be available.');
        }
    }

    static testMethod void testGetIsMakeDefaultButtonAvailableWhenShouldNotBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable(new Set<String>{'ZOPA-23', 'ZOPA-16', 'ZCP-74'});
        FeatureSwitch.disable('ZCP-76');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            setup_data.setLoanDetailsWithState('Default');

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsMakeDefaultButtonAvailable();
            Test.stopTest();

            System.assertEquals(false, result, 'Make Default button should not be available.');
        }
    }

    static testMethod void testGetIsAssignToDmcButtonAvailableWhenShouldBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsAssignToDmcButtonAvailable();
            Test.stopTest();

            System.assertEquals(true, result, 'Assign to DMC button should be available.');
        }
    }

    static testMethod void testGetIsAssignToDmcButtonAvailableWhenShouldNotBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.createDmcAccount();
            setup_data.assignTestCaseAndLoanToDmc();
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsAssignToDmcButtonAvailable();
            Test.stopTest();

            System.assertEquals(false, result, 'Assign to DMC button should not be available.');
        }
    }

    static testMethod void testGetIsRecallFromDmcButtonAvailableWhenShouldBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.createDmcAccount();
            setup_data.assignTestCaseAndLoanToDmc();
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsRecallFromDmcButtonAvailable();
            Test.stopTest();

            System.assertEquals(true, result, 'Recall from DMC button should be available.');
        }
    }

    static testMethod void testGetIsRecallFromDmcButtonAvailableWhenShouldNotBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsRecallFromDmcButtonAvailable();
            Test.stopTest();

            System.assertEquals(false, result, 'Recall from DMC button should not be available.');
        }
    }

    static testMethod void testGetIsSendTextButtonAvailableWhenCaseIsClosed() {
        SetupDataClass setup_data = new SetupDataClass(PEXLIFY_DEV_TEST_WITH_PERMISSIONS);
        System.runAs(setup_data.TestUser) {
            setup_data.createClosedCollectionsRecoveriesCase();
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
            setup_data.createCollectionsRecoveriesCase();
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
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsSendTextButtonAvailable();
            Test.stopTest();

            System.assertEquals(false, result, 'Send Text button should not be available when user has not permissions.');
        }
    }

    static testMethod void testAssignToMeAssignToContextUser() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.assignToMe();
            Test.stopTest();
            System.assertEquals(setup_data.TestUser.Id, setup_data.TestCase.OwnerId, 'Should assign to context user');
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact('The case was assigned to you'), 'Expected to have a success message on the page');
        }
    }

    static testMethod void testOpenLogCall() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                PageReference actual_result = setup_data.ClassUnderTest.openLogCall();
            Test.stopTest();
            System.assertEquals('/apex/LogCallFirst?id=' + setup_data.TestCase.Id, actual_result.getUrl(), 'Should be have the same url');
        }
    }

    static testMethod void testGetIsZcp76IsEnabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-76');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp76IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-76 should be enabled');
        }
    }

    static testMethod void testGetIsLitigationProcessCorrect() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.TestCase.Sub_Process__c = 'Litigation';
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsLitigationProcess();
            Test.stopTest();
            System.assertEquals(true, result, 'Case should have Litigation sub process');
        }
    }

    static testMethod void testGetIsLitigationProcessUncorrect() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsLitigationProcess();
            Test.stopTest();
            System.assertEquals(false, result, 'Case should not have Litigation sub process');
        }
    }

    static testMethod void testGetIsZcp76IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-76');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp76IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-76 should be disable');
        }
    }

    static testMethod void testGetIsSensitiveCase() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestCase.Is_Sensitive__c = true;
            setup_data.initController();
            Test.startTest();
                Boolean is_sensitive_case = setup_data.ClassUnderTest.getIsSensitiveCase();
            Test.stopTest();
            System.assertEquals(true, is_sensitive_case, 'Case should be Sensitive');
        }
    }

    static testMethod void testGetIsNotSensitiveCase() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_sensitive_case = setup_data.ClassUnderTest.getIsSensitiveCase();
            Test.stopTest();
            System.assertEquals(false, is_sensitive_case, 'Case should be Not Sensitive');
        }
    }

    static testMethod void testSettleLoanActionSuccessful() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.SETTLE_CASE);
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            setup_data.reQueryTestCase();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals('Closed - Settled', setup_data.TestCase.Status, 'Status should be Closed - Settled');
        }
    }

    static testMethod void testSettleLoanActionUnsuccessful() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.SETTLE_CASE);
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            setup_data.reQueryTestCase();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertNotEquals('Closed - Settled', setup_data.TestCase.Status, 'Status should be Closed - Settled');
        }
    }

    static testMethod void testGetIsZcp94IsEnabledWhenEnabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-94');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp94IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-94 should be enabled');
        }
    }

    static testMethod void testGetIsZcp94IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-94');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp94IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-94 should be disabled');
        }
    }

    static testMethod void testGetIsCaseNotClosed() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_not_closed = setup_data.ClassUnderTest.getIsCaseNotClosed();
            Test.stopTest();
            System.assertEquals(true, is_not_closed, 'IsCaseNotClosed should be true');
        }
    }

    static testMethod void testGetIsCaseNotClosedWhenClosed() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestCase.Status = 'Closed';
            update setup_data.TestCase;
            setup_data.reQueryTestCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_not_closed = setup_data.ClassUnderTest.getIsCaseNotClosed();
            Test.stopTest();
            System.assertEquals(false, is_not_closed, 'IsCaseNotClosed should be fasle');
        }
    }

    static testMethod void testHidePopup() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.showConfirmDeceasedPopup();
            Test.startTest();
                setup_data.ClassUnderTest.hidePopup();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null');
        }
    }

    static testMethod void testShowConfirmDeceasedPopup() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showConfirmDeceasedPopup();
            Test.stopTest();
            System.assertEquals(CaseCollectionsRecoveriesExtension.Process.CONFIRM_DECEASED, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testConfirmCollectionsPopup() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showConfirmCollectionsPopup();
            Test.stopTest();
            System.assertEquals(CaseCollectionsRecoveriesExtension.Process.CONFIRM_COLLECTIONS, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testShowMakeDefaultPopup() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.showMakeDefaultPopup();
            Test.stopTest();
            System.assertEquals(CaseCollectionsRecoveriesExtension.Process.CONFIRM_DEFAULT, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testGetIsZcp105IsEnabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-105');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp105IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-105 should be enabled');
        }
    }

    static testMethod void testGetIsZcp107IsEnabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-107');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp107IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-107 should be enabled');
        }
    }

    static testMethod void testGetShownManualSetWithdrawn() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-106');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setProcessForTestCase(CaseUtility.CASE_PROCESS_COLLECTIONS);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getShownManualSetWithdrawn();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Set Withdrawn should be enabled');
        }
    }

    static testMethod void testGetShownManualSetWithdrawnNegative() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-106');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setProcessForTestCase('test');
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getShownManualSetWithdrawn();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Set Withdrawn should not be enabled');
        }
    }

    static testMethod void testCheckProcess() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-106');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setProcessForTestCase(CaseUtility.CASE_PROCESS_COLLECTIONS);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.checkProcess(CaseUtility.CASE_PROCESS_COLLECTIONS);
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Set Withdrawn should be enabled');
        }
    }

    static testMethod void testCheckProcessNegative() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-106');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setProcessForTestCase('test');
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.checkProcess(CaseUtility.CASE_PROCESS_COLLECTIONS);
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Case Process should be false because the value is not Collections');
        }
    }

    static testMethod void testGetIsZcp107IsDisable() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-107');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp107IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-107 should be disabled');
        }
    }

    static testMethod void testGetIsRecoveriesCaseProcess() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.TestCase.Process__c = 'Recoveries';
            Test.startTest();
                Boolean is_recoveries_process = setup_data.ClassUnderTest.getIsRecoveriesCaseProcess();
            Test.stopTest();
            System.assertEquals(true, is_recoveries_process, 'Process should be Recoveries');
        }
    }

    static testMethod void testGetIsRecoveriesCaseProcessIncorrectProcess() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.TestCase.Process__c = 'incorrect';
            Test.startTest();
                Boolean is_recoveries_process = setup_data.ClassUnderTest.getIsRecoveriesCaseProcess();
            Test.stopTest();
            System.assertEquals(false, is_recoveries_process, 'Process should not be Recoveries');
        }
    }

    static testMethod void testGetIsTheConfirmCollectionsButtonAvailable() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-107');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.TestCase.Process__c = 'test';
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsTheConfirmCollectionsButtonAvailable();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Button should be enabled');
        }
    }

    static testMethod void testGetIsTheConfirmCollectionsButtonAvailableIncorrect() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-107');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.TestCase.Process__c = 'Recoveries';
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsTheConfirmCollectionsButtonAvailable();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Button should be disabled');
        }
    }

    static testMethod void testSettleLoanActionSuccessfulConfirmDeceased() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.CONFIRM_DECEASED);
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            String expected_message = 'Loan State was updated successfully';
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact(expected_message),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(1,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.ClassUnderTest.CurrentCase.Id]);
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan');
    }

    static testMethod void testSettleLoanActionSuccessfulConfirmDeceasedWithoutRelatedLogic() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.CONFIRM_DECEASED);
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            String expected_message = 'Loan State was updated successfully';
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact(expected_message),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(0,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.ClassUnderTest.CurrentCase.Id]);
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should not create chatter posts.');
    }

    static testMethod void testSettleLoanActionSuccessfulConfirmCollections() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.CONFIRM_COLLECTIONS);
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            String expected_message = 'Loan State was updated successfully';
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact(expected_message),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(1,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.ClassUnderTest.CurrentCase.Id]);
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan');
    }

    static testMethod void testSettleLoanActionSuccessfulConfirmCollectionsWithoutRelatedLogic() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.CONFIRM_COLLECTIONS);
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            String expected_message = 'Loan State was updated successfully';
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact(expected_message),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(0,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.ClassUnderTest.CurrentCase.Id]);
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should not create chatter posts.');
    }

    static testMethod void testGetIsZcp61IsEnabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-61');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp61IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-61 should be enabled');
        }
    }

    static testMethod void testGetIsZcp61IsDisable() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-61');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp61IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-61 should be disabled');
        }
    }

    static testMethod void testGetIsAccessToLitigationUpdate() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-61');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestCase.Process__c = 'Recoveries';
            setup_data.initController();
            Test.startTest();
                Boolean is_access = setup_data.ClassUnderTest.getIsAccessToLitigationUpdate();
            Test.stopTest();
            System.assertEquals(true, is_access, 'Litigation Update should be available');
        }
    }

    static testMethod void testGetIsAccessToLitigationUpdateWithoutAccess() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-61');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestCase.Process__c = 'test';
            setup_data.initController();
            Test.startTest();
                Boolean is_access = setup_data.ClassUnderTest.getIsAccessToLitigationUpdate();
            Test.stopTest();
            System.assertEquals(false, is_access, 'Litigation Update should not be available');
        }
    }

    static testMethod void testConfirmMakeDefaultActionWithSuccessMock() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.CONFIRM_DEFAULT);
            setup_data.setMockForResponse(true);

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            String expected_message = 'Make Default request has been sent successfully!';
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact(expected_message),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testConfirmMakeDefaultActionWithFailMock() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.CONFIRM_DEFAULT);
            setup_data.setMockForResponse(false);

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Request error: Internal issues.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testCheckIfLoanStateChangedWhenChanged() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.updateLoanWithDefaultState();

            Test.startTest();
                setup_data.ClassUnderTest.checkIfLoanStateChanged();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsPageReadyToRefresh, 'Page should be ready to refresh.');
        }
    }

    static testMethod void testCheckIfLoanStateChangedWhenNotChanged() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.checkIfLoanStateChanged();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.IsPageReadyToRefresh, 'Page should not be ready to refresh.');
        }
    }

    static testMethod void testGetIsDefaultAction(){
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.CONFIRM_DEFAULT);
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsDefaultAction();
            Test.stopTest();
            System.assertEquals(true, result, 'Should be true, when current process is CONFIRM_DEFAULT');
        }
    }

    static testMethod void testGetIsDefaultActionIncorrect(){
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.CONFIRM_COLLECTIONS);
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsDefaultAction();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be true, when current process is not CONFIRM_DEFAULT');
        }
    }

    static testMethod void testGetIsZcp24IsEnabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-24');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp24IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-24 should be enabled');
        }
    }

    static testMethod void testGetIsZcp24IsDisable() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-24');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp24IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-24 should be disabled');
        }
    }

    static testMethod void testisDcaForCase(){
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.changeDcaOnCase(setup_data.TestAccount.Id);
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.isDcaForCase();
            Test.stopTest();
            System.assertEquals(true, result, 'Should be true, if Case have DCA');
        }
    }

    static testMethod void testisDcaForCaseWithoutDca(){
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.isDcaForCase();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be false, if Case have not DCA');
        }
    }

    static testMethod void testGetIsAssignToDcaButtonAvailableDisableFs(){
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsAssignToDcaButtonAvailable();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be false, if zcp-123 disabled');
        }
    }

    static testMethod void testGetIsAssignToDcaButtonAvailableLoanWithDca(){
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.changeDcaOnCase(setup_data.TestAccount.Id);
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsAssignToDcaButtonAvailable();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be false, if Loan have DCA');
        }
    }

    static testMethod void testGetIsAssignToDcaButtonAvailable(){
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsAssignToDcaButtonAvailable();
            Test.stopTest();
            System.assertEquals(true, result, 'Should be true, if Loan have not DCA and zcp-123 enabled');
        }
    }

    static testMethod void testGetIsUnassignToDcaButtonAvailableDisableFs(){
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsUnassignToDcaButtonAvailable();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be false, if zcp-123 disabled');
        }
    }

    static testMethod void testGetIsUnassignToDcaButtonAvailableLoanWithDca(){
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsUnassignToDcaButtonAvailable();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be false, if Loan have not DCA');
        }
    }

    static testMethod void testGetIsUnassignToDcaButtonAvailable(){
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.changeDcaOnCase(setup_data.TestAccount.Id);
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsUnassignToDcaButtonAvailable();
            Test.stopTest();
            System.assertEquals(true, result, 'Should be true, if Loan have DCA and zcp-123 enabled');
        }
    }

    static testMethod void testGetIsPicklistDcaAccountsVisibleWithCorrectProcess(){
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.showAssignDcaPopup();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsPicklistDcaAccountsVisible();
            Test.stopTest();
            System.assertEquals(true, result, 'Should be true, if current process is ASSIGN_DCA and assign button are visible');
        }
    }

    static testMethod void testGetIsPicklistDcaAccountsVisibleWithInCorrectProcess(){
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsPicklistDcaAccountsVisible();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be false for all process exept ASSIGN_DCA');
        }
    }

    static testMethod void testGetIsPicklistDmcAccountsVisibleWithCorrectProcess(){
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.showAssignDmcPopup();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsPicklistDmcAccountsVisible();
            Test.stopTest();

            System.assertEquals(true, result, 'Should be true, if current process is ASSIGN_DMC and assign button are visible');
        }
    }

    static testMethod void testGetIsPicklistDmcAccountsVisibleWithInCorrectProcess(){
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsPicklistDmcAccountsVisible();
            Test.stopTest();

            System.assertEquals(false, result, 'Should be false for all process exept ASSIGN_DMC');
        }
    }

    static testMethod void testGetIsPicklistDmcAccountsVisibleWhenAlreadyAssignedToDmc(){
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.createDmcAccount();
            setup_data.assignTestCaseAndLoanToDmc();
            setup_data.initController();
            setup_data.ClassUnderTest.showAssignDmcPopup();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsPicklistDmcAccountsVisible();
            Test.stopTest();

            System.assertEquals(false, result, 'Should be false when Loan is already assigned to DMC.');
        }
    }

    static testMethod void testConfirmRecallFromDca() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-123', 'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDcaAccount();
            setup_data.createCollectionsRecoveriesCaseWithDca(setup_data.TestDcaAccount);
            setup_data.initController();
            setup_data.setMockForResponseAgency(true, 200);
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.RECALL_FROM_DCA);

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(1,[SELECT COUNT() FROM Loan__c WHERE AccountDca__c = null AND Id = :setup_data.TestLoan.Id]);
            System.assertEquals(1,[SELECT COUNT() FROM Case WHERE AccountDca__c = null]);
            System.assertEquals(1,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.ClassUnderTest.CurrentCase.Id], 'Should be created the task for the tracking action');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan');
    }

    static testMethod void testConfirmRecallFromDcaWithoutTracking() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-123');
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDcaAccount();
            setup_data.createCollectionsRecoveriesCaseWithDca(setup_data.TestDcaAccount);
            setup_data.initController();
            setup_data.setMockForResponseAgency(true, 200);
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.RECALL_FROM_DCA);

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(1,[SELECT COUNT() FROM Loan__c WHERE AccountDca__c = null AND Id = :setup_data.TestLoan.Id]);
            System.assertEquals(1,[SELECT COUNT() FROM Case WHERE AccountDca__c = null]);
            System.assertEquals(0,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed'], 'The task should not created, if zcp-149 is disable');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should not create chatter posts. For Case and Loan, if zcp-149 is disable');
    }

    static testMethod void testConfirmAssignDcaWithSuccess() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-123', 'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createLoanWithArrearsRatio(1);
            setup_data.reQueryTestCaseRelatedToLoan();
            setup_data.initController();
            setup_data.setMockForResponse(true);
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.ASSIGN_DCA);
            setup_data.createDcaAccount();
            setup_data.ClassUnderTest.AccountDcaId = setup_data.TestDcaAccount.Id;

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            String expected_message = 'Loan assigned to DCA successfully. Response: Success';
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact(expected_message), 'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(1, [SELECT COUNT() FROM Loan__c WHERE AccountDca__c = :setup_data.TestDcaAccount.Id AND Id = :setup_data.TestLoan.Id], 'Should be assigned the correct DCA for Loan');
            System.assertEquals(1, [SELECT COUNT() FROM Case WHERE AccountDca__c = :setup_data.TestDcaAccount.Id AND Id = :setup_data.TestCase.Id AND Sub_Process__c = 'DCA' AND IsLockedFromUpdatesInProcess__c = true], 'Should be assigned the correct DCA for Case. Also, should be changed sub process to DCA and the case must be blocked for process builder');
            System.assertEquals(2, [SELECT COUNT() FROM Task WHERE Subject LIKE :setup_data.getTaskSubjectForAction(AgentActionsRecorderForCollections.Action.ASSIGN_DCA) AND (WhatId = :setup_data.TestCase.Id OR WhatId = :setup_data.TestLoan.Id)], '2 tasks should be created for the tracking action');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan');
    }

    static testMethod void testConfirmAssignDcaWithFail() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-123', 'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createLoanWithArrearsRatio(1);
            setup_data.reQueryTestCaseRelatedToLoan();
            setup_data.initController();
            setup_data.setMockForResponse(false);
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.ASSIGN_DCA);
            setup_data.createDcaAccount();
            setup_data.ClassUnderTest.AccountDcaId = setup_data.TestDcaAccount.Id;

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Request error: Internal issues.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(0, [SELECT COUNT() FROM Loan__c WHERE AccountDca__c = :setup_data.TestDcaAccount.Id AND Id = :setup_data.TestLoan.Id], 'Loan should not be assigned to DCA');
            System.assertEquals(0, [SELECT COUNT() FROM Case WHERE AccountDca__c = :setup_data.TestDcaAccount.Id AND Id = :setup_data.TestCase.Id AND Sub_Process__c = 'DCA' AND IsLockedFromUpdatesInProcess__c = true], 'Case should not be assigned to DCA');
            System.assertEquals(0, [SELECT COUNT() FROM Task WHERE Subject LIKE :setup_data.getTaskSubjectForAction(AgentActionsRecorderForCollections.Action.ASSIGN_DCA) AND (WhatId = :setup_data.TestCase.Id OR WhatId = :setup_data.TestLoan.Id)], 'Tasks should not be created');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Chatter posts should not be created');
    }

    static testMethod void testConfirmAssignDcaWithoutTrackingWithSuccess() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-123');
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createLoanWithArrearsRatio(1);
            setup_data.reQueryTestCaseRelatedToLoan();
            setup_data.initController();
            setup_data.setMockForResponse(true);
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.ASSIGN_DCA);
            setup_data.createDcaAccount();
            setup_data.ClassUnderTest.AccountDcaId = setup_data.TestDcaAccount.Id;

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            String expected_message = 'Loan assigned to DCA successfully. Response: Success';
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact(expected_message),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(1, [SELECT COUNT() FROM Loan__c WHERE AccountDca__c = :setup_data.TestDcaAccount.Id AND Id = :setup_data.TestLoan.Id], 'Should be assigned the correct DCA for Loan');
            System.assertEquals(1, [SELECT COUNT() FROM Case WHERE AccountDca__c = :setup_data.TestDcaAccount.Id AND Id = :setup_data.TestCase.Id AND Sub_Process__c = 'DCA' AND IsLockedFromUpdatesInProcess__c = true], 'Should be assigned the correct DCA for Case. Also, should be changed sub process to DCA and the case must be blocked for process builder');
            System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed' AND Type != 'Letter'], 'The task should not be created, if zcp-149 is disable');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should not create chatter posts. For Case and Loan, if zcp-149 is disable');
    }

    static testMethod void testConfirmAssignDmc() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable(new Set<String>{'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createLoanWithArrearsRatio(1);
            setup_data.reQueryTestCaseRelatedToLoan();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.ASSIGN_DMC);
            setup_data.createDmcAccount();
            setup_data.ClassUnderTest.AccountDmcId = setup_data.TestDmcAccount.Id;

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Loan assigned to DMC successfully.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(1, [SELECT COUNT() FROM Loan__c WHERE AccountDmc__c = :setup_data.TestDmcAccount.Id AND Id = :setup_data.TestLoan.Id], 'Should be assigned the correct DMC for Loan');
            System.assertEquals(1, [SELECT COUNT() FROM Case WHERE AccountDmc__c = :setup_data.TestDmcAccount.Id AND Id = :setup_data.TestCase.Id AND Sub_Process__c = 'With DMC' AND IsLockedFromUpdatesInProcess__c = true], 'Should be assigned the correct DMC for Case. Also, should be changed sub process to DMC and the case must be blocked for process builder');
            System.assertEquals(2, [SELECT COUNT() FROM Task WHERE Subject LIKE :setup_data.getTaskSubjectForAction(AgentActionsRecorderForCollections.Action.ASSIGN_DMC) AND (WhatId = :setup_data.TestCase.Id OR WhatId = :setup_data.TestLoan.Id)], 'Should be created the task for the tracking action');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan');
    }

    static testMethod void testConfirmAssignDmcWithoutTracking() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createLoanWithArrearsRatio(1);
            setup_data.reQueryTestCaseRelatedToLoan();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.ASSIGN_DMC);
            setup_data.createDmcAccount();
            setup_data.ClassUnderTest.AccountDmcId = setup_data.TestDmcAccount.Id;

            Test.startTest();
            setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Loan assigned to DMC successfully.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(1, [SELECT COUNT() FROM Loan__c WHERE AccountDmc__c = :setup_data.TestDmcAccount.Id AND Id = :setup_data.TestLoan.Id], 'Should be assigned the correct DMC for Loan');
            System.assertEquals(1, [SELECT COUNT() FROM Case WHERE AccountDmc__c = :setup_data.TestDmcAccount.Id AND Id = :setup_data.TestCase.Id AND Sub_Process__c = 'With DMC' AND IsLockedFromUpdatesInProcess__c = true], 'Should be assigned the correct DMC for Case. Also, should be changed sub process to DMC and the case must be blocked for process builder');
            Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
            System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId IN :set_owner_id AND Status = 'Completed' AND Type != 'Letter'], 'The task should not be created, if zcp-149 is disable');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should not create chatter posts. For Case and Loan, if zcp-149 is disable');
    }

    static testMethod void testConfirmRecallFromDmc() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.enable(new Set<String>{'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createLoanWithArrearsRatio(1);
            setup_data.reQueryTestCaseRelatedToLoan();
            setup_data.createDmcAccount();
            setup_data.assignTestCaseAndLoanToDmc();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.RECALL_FROM_DMC);

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Loan has been successfully unassigned from DMC.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(1, [SELECT COUNT() FROM Loan__c WHERE AccountDmc__c = null AND Id = :setup_data.TestLoan.Id], 'Loan should be unassigned from DMC.');
            System.assertEquals(1, [SELECT COUNT() FROM Case WHERE AccountDmc__c = null AND Id = :setup_data.TestCase.Id AND IsLockedFromUpdatesInProcess__c = false], 'Case should be unassigned from DMC. Also, Case must be unlocked for process builder.');
            System.assertEquals(2, [SELECT COUNT() FROM Task WHERE Subject LIKE :setup_data.getTaskSubjectForAction(AgentActionsRecorderForCollections.Action.RECALL_FROM_DMC) AND (WhatId = :setup_data.TestCase.Id OR WhatId = :setup_data.TestLoan.Id)], 'Should be created the task for the tracking action');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan.');
    }

    static testMethod void testConfirmRecallFromDmcWithoutTracking() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createLoanWithArrearsRatio(1);
            setup_data.reQueryTestCaseRelatedToLoan();
            setup_data.createDmcAccount();
            setup_data.assignTestCaseAndLoanToDmc();
            setup_data.initController();
            setup_data.setControllerProcess(CaseCollectionsRecoveriesExtension.Process.RECALL_FROM_DMC);

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Loan has been successfully unassigned from DMC.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            System.assertEquals(1, [SELECT COUNT() FROM Loan__c WHERE AccountDmc__c = null AND Id = :setup_data.TestLoan.Id], 'Loan should be unassigned from DMC.');
            System.assertEquals(1, [SELECT COUNT() FROM Case WHERE AccountDmc__c = null AND Id = :setup_data.TestCase.Id AND IsLockedFromUpdatesInProcess__c = false], 'Case should be unassigned from DMC. Also, Case must be unlocked for process builder.');
            Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
            System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId IN :set_owner_id AND Status = 'Completed' AND Type != 'Letter'], 'The tasks should not be created because ZCP-149 is disabled.');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'The chatter posts should not be created because ZCP-149 is disabled.');
    }

    static testMethod void testShowRecallDcaPopup() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.showRecallDcaPopup();
            Test.stopTest();
            System.assertEquals(CaseCollectionsRecoveriesExtension.Process.RECALL_FROM_DCA, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testShowAssignDcaPopup() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.showAssignDcaPopup();
            Test.stopTest();
            System.assertEquals(CaseCollectionsRecoveriesExtension.Process.ASSIGN_DCA, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testShowAssignDmcPopup() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.showAssignDmcPopup();
            Test.stopTest();

            System.assertEquals(CaseCollectionsRecoveriesExtension.Process.ASSIGN_DMC, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testShowRecallDmcPopup() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.showRecallDmcPopup();
            Test.stopTest();

            System.assertEquals(CaseCollectionsRecoveriesExtension.Process.RECALL_FROM_DMC, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testShowSetWithdrawnPopup() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.showSetWithdrawnPopup();
            Test.stopTest();

            System.assertEquals(CaseCollectionsRecoveriesExtension.Process.SET_WITHDRAWN, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testShowSettleCasePopup() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
            setup_data.ClassUnderTest.showSettleCasePopup();
            Test.stopTest();

            System.assertEquals(CaseCollectionsRecoveriesExtension.Process.SETTLE_CASE, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testGetIsZcp123IsEnabledForEnabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp123IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-123 should be enabled');
        }
    }

    static testMethod void testGetIsZcp123IsEnabledForDisabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp123IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-123 should be disabled');
        }
    }

    static testMethod void testGetIsZcp169IsEnabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-169');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp169IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-169 should be enabled');
        }
    }

    static testMethod void testGetIsZcp169IsDisable() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-169');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp169IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-169 should be disabled');
        }
    }

    static testMethod void testGetIsZcp189IsEnabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable('ZCP-189');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp189IsEnabled();
            Test.stopTest();

            System.assertEquals(true, is_enabled, 'ZCP-189 should be enabled');
        }
    }

    static testMethod void testGetIsZcp189IsDisabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-189');
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp189IsEnabled();
            Test.stopTest();

            System.assertEquals(false, is_enabled, 'ZCP-189 should be disabled');
        }
    }

    static testMethod void testSaveAfterInlineCaseEditWhenOnlyNextReviewDateChanged() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-189', 'ZCP-80'});
        setup_data.setMockForResponse(true);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            Datetime test_date_time = Datetime.now().addDays(1);
            setup_data.setNextReviewDateForTestCase(test_date_time);

            Test.startTest();
                setup_data.ClassUnderTest.save();
            Test.stopTest();

            Case actual_case = [SELECT Next_Review_Date__c, Stop_Communication_Until__c, Sub_Process__c, OwnerId, Review_Counter__c FROM Case WHERE id = :setup_data.TestCase.Id];
            System.assertEquals(test_date_time, actual_case.Next_Review_Date__c,'Next_Review_Date__c was updated');
            System.assertNotEquals(test_date_time, actual_case.Stop_Communication_Until__c,'Stop_Communication_Until__c was not updated');
            System.assertEquals('Collections', actual_case.Sub_Process__c,'Sub_Process__c should not be changed');
            System.assertEquals(setup_data.getOnHoldQueueId(), actual_case.OwnerId,'Owner set to On-Hold queue');
        }
    }

    static testMethod void testSaveAfterInlineCaseEditWhenOnlyStopCommunicationChangedAndCalloutSuccess() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable(new Set<String> {'ZCP-189', 'ZCP-80'});
        setup_data.setMockForPutStopCommunication(true);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            Datetime test_date_time = Datetime.now().addDays(1);
            setup_data.setStopCommunicationUntilForTestCase(test_date_time);

            Test.startTest();
                setup_data.ClassUnderTest.save();
            Test.stopTest();

            Case actual_case = [SELECT Next_Review_Date__c, Stop_Communication_Until__c, Sub_Process__c, OwnerId, Review_Counter__c FROM Case WHERE id = :setup_data.TestCase.Id];
            System.assertEquals(test_date_time, actual_case.Stop_Communication_Until__c,'Stop_Communication_Until__c was updated');
            System.assertEquals(test_date_time, actual_case.Next_Review_Date__c,'Next_Review_Date__c was updated');
            System.assertEquals('Collections', actual_case.Sub_Process__c,'Sub_Process__c should not be changed');
            System.assertEquals(setup_data.getOnHoldQueueId(), actual_case.OwnerId,'Owner set to On-Hold queue');
        }
    }

    static testMethod void testSaveAfterInlineCaseEditWhenOnlyStopCommunicationChangedAndCalloutFail() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.enable(new Set<String> {'ZCP-189', 'ZCP-80'});
        setup_data.setMockForPutStopCommunication(false);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            Datetime test_date_time = Datetime.now();
            setup_data.setStopCommunicationUntilForTestCase(test_date_time);
            String initial_sub_process = setup_data.TestCase.Sub_Process__c;
            Id initial_owner_id = setup_data.TestCase.OwnerId;

            Test.startTest();
                setup_data.ClassUnderTest.save();
            Test.stopTest();

            Case actual_case = [SELECT Next_Review_Date__c, Stop_Communication_Until__c, Sub_Process__c, OwnerId, Review_Counter__c FROM Case WHERE id = :setup_data.TestCase.Id];
            System.assertNotEquals(test_date_time, actual_case.Stop_Communication_Until__c,'Stop_Communication_Until__c was not updated');
            System.assertNotEquals(test_date_time, actual_case.Next_Review_Date__c,'Next_Review_Date__c was not updated');
            System.assertEquals(initial_sub_process, actual_case.Sub_Process__c,'Sub_Process__c not updated');
            System.assertEquals(initial_owner_id, actual_case.OwnerId,'OwnerId not updated');
        }
    }

    static testMethod void testSaveAfterInlineCaseEditWhenStopCommunicationChangedAndZcp189Disabled() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        FeatureSwitch.disable('ZCP-189');
        setup_data.setMockForPutStopCommunication(true);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            Datetime test_date_time = Datetime.now().addDays(1);
            setup_data.setStopCommunicationUntilForTestCase(test_date_time);

            Test.startTest();
                setup_data.ClassUnderTest.save();
            Test.stopTest();

            Case actual_case = [SELECT Next_Review_Date__c, Stop_Communication_Until__c, Sub_Process__c, OwnerId FROM Case WHERE id = :setup_data.TestCase.Id];
            System.assertEquals(test_date_time, actual_case.Stop_Communication_Until__c,'Stop_Communication_Until__c was updated');
            System.assertNotEquals(test_date_time, actual_case.Next_Review_Date__c,'Next_Review_Date__c was not updated');
            System.assertEquals('Collections', actual_case.Sub_Process__c,'Sub_Process__c should not be changed');
            System.assertEquals(setup_data.getOnHoldQueueId(), actual_case.OwnerId,'Owner updated to On-Hold queue');
        }
    }

    static testMethod void testPerformCalloutToUpdateStopCommunicationDateSuccess() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        setup_data.setMockForPutStopCommunication(true);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            Datetime test_date_time = Datetime.now();
            setup_data.setStopCommunicationUntilForTestCase(test_date_time);

            Test.startTest();
                Boolean callout_successfull = setup_data.ClassUnderTest.performCalloutToUpdateStopCommunicationDate();
            Test.stopTest();

            System.assertEquals(true, callout_successfull,'Callout performed with success.');
        }
    }

    static testMethod void testPerformCalloutToUpdateStopCommunicationDateNotSuccess() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        setup_data.setMockForPutStopCommunication(false);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            Datetime test_date_time = Datetime.now();
            setup_data.setStopCommunicationUntilForTestCase(test_date_time);

            Test.startTest();
                Boolean callout_successfull = setup_data.ClassUnderTest.performCalloutToUpdateStopCommunicationDate();
            Test.stopTest();

            System.assertEquals(false, callout_successfull,'Callout failed.');
        }
    }

    static testMethod void testValidateInlineEditFormWhenNothingHasChanged() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();

            Test.startTest();
                Boolean validation_successfull = setup_data.ClassUnderTest.validateInlineForm();
            Test.stopTest();

            System.assertEquals(true, validation_successfull,'There were no changes, form is valid.');
        }
    }

    static testMethod void testValidateInlineEditFormWhenNextReviewDateChangedToInvalidValue() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            setup_data.setNextReviewDateForTestCase(Datetime.now().addDays(-1));

            Test.startTest();
                Boolean validation_successfull = setup_data.ClassUnderTest.validateInlineForm();
            Test.stopTest();

            System.assertEquals(false, validation_successfull,'There are some validation errors.');
        }
    }

    static testMethod void testValidateInlineEditFormWhenStopCommunicationUntilChangedToInvalidValue() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            setup_data.setStopCommunicationUntilForTestCase(Datetime.now().addDays(-1));

            Test.startTest();
                Boolean validation_successfull = setup_data.ClassUnderTest.validateInlineForm();
            Test.stopTest();

            System.assertEquals(false, validation_successfull,'There are some validation errors.');
        }
    }

    static testMethod void testValidateInlineEditFormWhenFieldsChangedToValidValues() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCase();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setControllerTestLoan();
            setup_data.setNextReviewDateForTestCase(Datetime.now().addDays(+1));
            setup_data.setStopCommunicationUntilForTestCase(Datetime.now().addDays(+1));

            Test.startTest();
                Boolean validation_successfull = setup_data.ClassUnderTest.validateInlineForm();
            Test.stopTest();

            System.assertEquals(true, validation_successfull,'There were changes but form is valid.');
        }
    }

    static testMethod void testGetIsLoanDefaultWhenRelatedLoanIsNull() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.ClassUnderTest.RelatedLoan = null;

            Test.startTest();
                Boolean is_loan_default = setup_data.ClassUnderTest.getIsLoanDefault();
            Test.stopTest();

            System.assertEquals(false, is_loan_default,' Should return false because there are no related Loan.');
        }
    }

    static testMethod void testGetIsLoanDefaultWhenDefaultReasonFieldIsNull() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                Boolean is_loan_default = setup_data.ClassUnderTest.getIsLoanDefault();
            Test.stopTest();

            System.assertEquals(false, is_loan_default, 'Should return false because Default Reason field is blank.');
        }
    }

    static testMethod void testGetIsLoanDefaultWhenDefaultReasonFieldIsNotNull() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setDefaultReasonForTestLoan('Bankruptcy');
            setup_data.initController();

            Test.startTest();
                Boolean is_loan_default = setup_data.ClassUnderTest.getIsLoanDefault();
            Test.stopTest();

            System.assertEquals(true, is_loan_default, 'Should return true because Default Reason field is not blank.');
        }
    }

    static testMethod void testGetAccountsDca() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.createDcaAccount();

            Test.startTest();
                List<SelectOption> dca_accounts = setup_data.ClassUnderTest.getAccountsDca();
            Test.stopTest();

            System.assertEquals(1, dca_accounts.size(), 'Should return SelectOption for 1 DCA Account.');
            System.assertEquals(setup_data.TestDcaAccount.Name, dca_accounts[0].getLabel(), 'Should set DCA Account.Name for label.');
            System.assertEquals(setup_data.TestDcaAccount.Id, dca_accounts[0].getValue(), 'Should set DCA Account.Id for value.');
        }
    }

    static testMethod void testGetAccountsDmc() {
        SetupDataClass setup_data = new SetupDataClass(STANDARD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.createDmcAccount();

            Test.startTest();
                List<SelectOption> dmc_accounts = setup_data.ClassUnderTest.getAccountsDmc();
            Test.stopTest();

            System.assertEquals(1, dmc_accounts.size(), 'Should return SelectOption for 1 DMC Account.');
            System.assertEquals(setup_data.TestDmcAccount.Name, dmc_accounts[0].getLabel(), 'Should set DMC Account.Name for label.');
            System.assertEquals(setup_data.TestDmcAccount.Id, dmc_accounts[0].getValue(), 'Should set DMC Account.Id for value.');
        }
    }

    static testMethod void testGetBlankEmailTemplate(){
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();

            Test.startTest();
                String result = setup_data.ClassUnderTest.getBlankEmailTemplate();
            Test.stopTest();

            String blank_email_template_id = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Blank_Template' LIMIT 1].Id;
            System.assertEquals('&template_id=' + blank_email_template_id, result, 'Should return url parameter for Blank_Template email template.');
        }
    }


    private class SetupDataClass {
        public Case TestCase;
        public Account TestAccount;
        public CaseCollectionsRecoveriesExtension ClassUnderTest;
        public User TestUser;
        public Loan__c TestLoan;
        public List<FeedItem> CreatedCaseFeedItems;
        public Account TestDcaAccount;
        public Account TestDmcAccount;
        private Integer UniqueIdCounter = 0;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        public void createCollectionsRecoveriesCase() {
            createDataForCase();
            TriggerHandler.IsTriggerActive = false;
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setLoan(TestLoan)
                    .setProcess('Collections')
                    .setSubProcess('Collections')
                    .save()
                    .getRecord();
            reQueryTestCase();
            TriggerHandler.IsTriggerActive = true;
        }

        public void createClosedCollectionsRecoveriesCase() {
            createDataForCase();
            TriggerHandler.IsTriggerActive = false;
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setLoan(TestLoan)
                    .setProcess('Collections')
                    .setSubProcess('Collections')
                    .setStatus('Closed')
                    .save()
                    .getRecord();
            reQueryTestCase();
            TriggerHandler.IsTriggerActive = true;
        }

        public void createCollectionsRecoveriesCaseWithDca(Account dca_account) {
            createDataForCase();
            TriggerHandler.IsTriggerActive = false;
            TestCase = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).setLoan(TestLoan).setAccountDCAID(dca_account.Id).save().getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public void createDataForCase() {
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('CaseCollectionsRecoveriesExtension').save().getRecord();
            TestLoan = LoanBuilder.getBuilder(TestAccount).setExternalId('test' + UniqueIdCounter).save().getRecord();
            UniqueIdCounter++;
            TriggerHandler.IsTriggerActive = true;
        }

        public void reQueryTestCase() {
            TestCase = [SELECT CreatedDate, First_Time_Picked__c, IsClosed, Subject, Status, Next_Review_Date__c, Stop_Communication_Until__c, Is_Sensitive__c, AccountDCA__c, AccountDMC__c, Loan__r.Loan_ID__c, Owner.Profile.Name, RecordTypeId, Review_Counter__c, Sub_Process__c, OwnerId FROM Case WHERE Id = : TestCase.Id];
        }

        public void reQueryTestCaseRelatedToLoan() {
            TestCase = [SELECT CreatedDate, First_Time_Picked__c, IsClosed, Subject, Status, Next_Review_Date__c, Stop_Communication_Until__c, Is_Sensitive__c, AccountDCA__c, AccountDMC__c, Loan__r.Loan_ID__c, Owner.Profile.Name, RecordTypeId, Sub_Process__c, OwnerId FROM Case WHERE Loan__c = : TestLoan.Id AND IsClosed = false];
        }

        public void initController() {
            ClassUnderTest = new CaseCollectionsRecoveriesExtension(new ApexPages.StandardController(TestCase));
        }

        public void initControllerWithoutRelatedLoan() {
            TestCase.Loan__c = null;
            update TestCase;
            initController();
        }

        public void createLoanWithArrearsRatio(Decimal arrears_ratio){
            TestLoan = LoanBuilder.getBuilder(TestAccount).setArrearsRatio(arrears_ratio).setExternalId(Utility.getRandomString(8)).save().getRecord();
        }

        public void createCollectionsRecoveriesCaseWithOwner() {
            createDataForCase();
            TestCase = CaseBuilder.getBuilder(TestAccount).setOwner(TestUser.Id).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).save().getRecord();
        }

        public void setControllerProcess(CaseCollectionsRecoveriesExtension.Process process) {
            ClassUnderTest.CurrentProcess = process;
        }

        public void setControllerTestLoan() {
            ClassUnderTest.RelatedLoan = TestLoan;
        }

        public void setProcessForTestCase(String process){
            TestCase.Process__c = process;
            update TestCase;
        }

        public void setNextReviewDateForTestCase(Datetime next_review_date) {
            TestCase.Next_Review_Date__c = next_review_date;
        }

        public void setStopCommunicationUntilForTestCase(Datetime stop_communication_until) {
            TestCase.Stop_Communication_Until__c = stop_communication_until;
        }

        public void setDefaultReasonForTestLoan(String default_reason){
            TestLoan.Default_Reason__c = default_reason;
            update TestLoan;
        }

        public void setLoanDetailsWithState(String state) {
            ClassUnderTest.RelatedLoanDetails = new ApiCommandGetLoanDetails.LoanDetails();
            ClassUnderTest.RelatedLoanDetails.State = state;
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }

        public void setMockForResponseAgency(Boolean is_success, Integer error_code) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandGetCollectionAgencyMock(is_success, error_code));
        }

        public void setMockForPutStopCommunication(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandPutStopCommunicationDateMock(is_success));
        }

        public void setMockForGetLoanDetails(Boolean is_success, Integer error_code) {
            Test.setMock(HttpCalloutMock.class, new LoanDetailsViewMock(is_success, error_code));
        }

        public void queryFeedItems() {
            CreatedCaseFeedItems = [SELECT ParentId, Body FROM FeedItem];
        }

        public void changeDcaOnCase(Id dca_id){
            TestCase = CaseBuilder.getBuilder(TestCase).setAccountDCAID(dca_id).save().getRecord();
        }

        public void createDcaAccount(){
            TestDcaAccount = AccountBuilder.getBuilder('LoanViewExtensionTest').setRecordType(RecordTypeUtility.ACCOUNT_DCA_ACCOUNT).setDcaId('test').save().getRecord();
        }

        public void createDmcAccount(){
            TestDmcAccount = AccountBuilder.getBuilder('TestDmcName').setRecordType(RecordTypeUtility.ACCOUNT_DMC_ACCOUNT).setDcaId('testDmcExternalId').save().getRecord();
        }

        public Id getOnHoldQueueId() {
            return CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD);
        }

        public void setLoanUuid() {
            TestLoan.Loan_Id__c = '1234-1234-1234-1234';
        }

        public void updateLoanWithDefaultState(){
            Loan__c loan_to_update = TestLoan.clone(true);
            loan_to_update.State__c = 'Default';
            update loan_to_update;
        }

        public void assignTestCaseAndLoanToDmc(){
            TestLoan.AccountDMC__c = TestDmcAccount.Id;
            update TestLoan;
            TestCase.AccountDMC__c = TestDmcAccount.Id;
            update TestCase;
        }

        public String getTaskSubjectForAction(AgentActionsRecorderForCollections.Action action){
            return '%' + AgentActionsRecorderForCollections.SUBJECT_FOR_ACTIONS.get(action) + '%';
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