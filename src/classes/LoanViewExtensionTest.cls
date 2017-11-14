@isTest public class LoanViewExtensionTest {
    private static final String TEST_USER = 'CaseViewCasePrep';

    static testMethod void testLoanViewExtensionInitializationWithLoanDetailsCallSuccess() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.setMockForLoanDetails(true, 200);

            Test.startTest();
                setup_data.initController();
            Test.stopTest();

            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentLoan.Id, 'Should be initialized by appropriate Loan.');
            System.assertNotEquals(null, setup_data.ClassUnderTest.LoanDetails, 'Loan Details should be retrieved.');
        }
    }

    static testMethod void testLoanViewExtensionInitializationWithLoanDetailsCallFail() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.setMockForLoanDetails(false, 500);

            Test.startTest();
            setup_data.initController();
            Test.stopTest();

            System.assertEquals(setup_data.TestLoan.Id, setup_data.ClassUnderTest.CurrentLoan.Id, 'Should be initialized by appropriate Loan.');
            System.assertEquals(null, setup_data.ClassUnderTest.LoanDetails, 'Loan Details should not be retrieved.');
        }
    }

    static testMethod void testSetIsCustomerInArrearsZeroRatio() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-106');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.TestLoan.Arrears_Ratio__c = 0;
            update setup_data.TestLoan;
            Test.startTest();
                setup_data.initController();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.IsCustomerInArrears, 'Should be false');
        }
    }

    static testMethod void testSetIsCustomerInArrearsMoreThanZeroRatio() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0.5);
            setup_data.initController();
            update setup_data.TestLoan;
            Test.startTest();
                setup_data.initController();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.IsCustomerInArrears, 'Should be true');
        }
    }

    static testMethod void testShowConfirmDeceasedPopup() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.showConfirmDeceasedPopup();
            Test.stopTest();
            System.assertEquals(LoanViewExtension.Process.CONFIRM_DECEASED, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testShowConfirmCollectionsPopup() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.showConfirmCollectionsPopup();
            Test.stopTest();

            System.assertEquals(LoanViewExtension.Process.CONFIRM_COLLECTIONS, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testHidePopup() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.setMockForResponse(true);
                setup_data.ClassUnderTest.showConfirmDeceasedPopup();
            Test.startTest();
                setup_data.ClassUnderTest.hidePopup();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null');
        }
    }

    static testMethod void testGetIsZcp105IsEnabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-105');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp105IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-105 should be enabled');
        }
    }

    static testMethod void testGetIsMakeDefaultButtonAvailableWhenShouldBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-23', 'ZOPA-16', 'ZCP-74', 'ZCP-76'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.setLoanDetailsWithState('Not Default');

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsMakeDefaultButtonAvailable();
            Test.stopTest();

            System.assertEquals(true, result, 'Make Default button should be available.');
        }
    }

    static testMethod void testGetIsMakeDefaultButtonAvailableWhenShouldNotBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable(new Set<String>{'ZOPA-23', 'ZOPA-16', 'ZCP-74'});
        FeatureSwitch.disable('ZCP-76');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.setLoanDetailsWithState('Default');

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsMakeDefaultButtonAvailable();
            Test.stopTest();

            System.assertEquals(false, result, 'Make Default button should not be available.');
        }
    }

    static testMethod void testGetIsAssignToDmcButtonAvailableWhenShouldBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsAssignToDmcButtonAvailable();
            Test.stopTest();

            System.assertEquals(true, result, 'Assign to DMC button should be available.');
        }
    }

    static testMethod void testGetIsAssignToDmcButtonAvailableWhenShouldNotBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.createDmcAccount();
            setup_data.assignTestLoanAndCaseToDmc();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsAssignToDmcButtonAvailable();
            Test.stopTest();

            System.assertEquals(false, result, 'Assign to DMC button should not be available.');
        }
    }

    static testMethod void testGetIsRecallFromDmcButtonAvailableWhenShouldBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(2);
            setup_data.reQueryTestCase();
            setup_data.createDmcAccount();
            setup_data.assignTestLoanAndCaseToDmc();
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsRecallFromDmcButtonAvailable();
            Test.stopTest();

            System.assertEquals(true, result, 'Recall from DMC button should be available.');
        }
    }

    static testMethod void testGetIsRecallFromDmcButtonAvailableWhenShouldNotBeAvailable() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsRecallFromDmcButtonAvailable();
            Test.stopTest();

            System.assertEquals(false, result, 'Recall from DMC button should not be available.');
        }
    }

    static testMethod void testGetIsTheConfirmCollectionsButtonAvailable() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-107');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestCase.Process__c = 'test';
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsTheConfirmCollectionsButtonAvailable();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Button should be enabled');
        }
    }

    static testMethod void testGetIsTheConfirmCollectionsButtonAvailableIncorrect() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-107');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestCase.Process__c = 'Recoveries';
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsTheConfirmCollectionsButtonAvailable();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Button should be disabled');
        }
    }

    static testMethod void testSettleLoanActionSuccessfulConfirmDeceased() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setMockForResponse(true);
            setup_data.setControllerProcess(LoanViewExtension.Process.CONFIRM_DECEASED);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            String expected_message = 'Loan State was updated successfully';
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact(expected_message),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(1,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed']);
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan');
    }

    static testMethod void testSettleLoanActionSuccessfulConfirmCollections() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setMockForResponse(true);
            setup_data.setControllerProcess(LoanViewExtension.Process.CONFIRM_COLLECTIONS);
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            String expected_message = 'Loan State was updated successfully';
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact(expected_message),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(1,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed']);
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan');
    }

    static testMethod void testShowSetTowithdrawnPopup() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.showSetWithdrawnPopup();
            Test.stopTest();
            System.assertEquals(LoanViewExtension.Process.SET_WITHDRAWN, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testShowRecallDcaPopup() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.showRecallDcaPopup();
            Test.stopTest();
            System.assertEquals(LoanViewExtension.Process.RECALL_FROM_DCA, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testShowAssignDcaPopup() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.createCollectionsRecoveriesCase();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.showAssignDcaPopup();
            Test.stopTest();
            System.assertEquals(LoanViewExtension.Process.ASSIGN_DCA, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testShowAssignDmcPopup() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.showAssignDmcPopup();
            Test.stopTest();

            System.assertEquals(LoanViewExtension.Process.ASSIGN_DMC, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testShowRecallDmcPopup() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.showRecallDmcPopup();
            Test.stopTest();

            System.assertEquals(LoanViewExtension.Process.RECALL_FROM_DMC, setup_data.ClassUnderTest.CurrentProcess, 'Should be equals Process');
        }
    }

    static testMethod void testSetLoanTowithdrawnSuccessByClickingButtonProcess() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-106','ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setMockForResponse(true);
            setup_data.ClassUnderTest.showSetWithdrawnPopup();
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            setup_data.reQueryTestCase();
            setup_data.reQueryTestLoan();
            System.assertEquals('Withdrawn', setup_data.TestCase.Status, 'Should be in Withdrawn Status');
            System.assertEquals(1,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed']);
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan');
    }

    static testMethod void testSetLoanTowithdrawnNotSuccessByClickingButtonProcess() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-106');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.createCollectionsRecoveriesCase();
            setup_data.initController();
            setup_data.setMockForResponse(false);
            setup_data.ClassUnderTest.showSetWithdrawnPopup();
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            setup_data.reQueryTestCase();
            setup_data.reQueryTestLoan();
            System.assertNotEquals('Withdrawn', setup_data.TestCase.Status, 'Should NOT be in Withdrawn Status');
        }
    }

    static testMethod void testGetIsZcp106IsEnabledWhenEnabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-106');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp106IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-106 should be enabled');
        }
    }

    static testMethod void testGetShownManualSetWithdrawn() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-106');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.setProcessForTestCase(CaseUtility.CASE_PROCESS_COLLECTIONS);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getShownManualSetWithdrawn();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Set Withdrawn should be enabled');
        }
    }

    static testMethod void testGetShownManualSetWithdrawnNegative() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-106');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.setProcessForTestCase(CaseUtility.CASE_PROCESS_RECOVERIES);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getShownManualSetWithdrawn();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Set Withdrawn should not be enabled');
        }
    }

    static testMethod void testGetShownManualSetWithdrawnWithDisabledFs() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-106');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.setProcessForTestCase(CaseUtility.CASE_PROCESS_COLLECTIONS);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getShownManualSetWithdrawn();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Set Withdrawn should not be enabled');
        }
    }

    static testMethod void testGetIsZcp106IsEnabledWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-106');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp106IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-106 should be disabled');
        }
    }

    static testMethod void testGetIsCollectionsNotesInEditMode() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.IsCollectionsNotesInEditMode;
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Collections Notes should be not editable');
        }
    }

    static testMethod void testClickEditButton() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                setup_data.ClassUnderTest.enableEditModeForCollectionsNotes();
            Test.stopTest();
            Boolean is_enabled = setup_data.ClassUnderTest.IsCollectionsNotesInEditMode;
            System.assertEquals(true, is_enabled, 'Collections Notes should be editable');
        }
    }

    static testMethod void testclickSaveButton() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.ClassUnderTest.enableEditModeForCollectionsNotes();
            setup_data.TestLoan.Collections_Notes__c = 'test notes value';
            Test.startTest();
                setup_data.ClassUnderTest.saveCollectionsNotes();
            Test.stopTest();
            Boolean is_enabled = setup_data.ClassUnderTest.IsCollectionsNotesInEditMode;
            Loan__c loan_after_update = [SELECT Collections_Notes__c FROM Loan__c WHERE Id = :setup_data.TestLoan.Id];
            System.assertEquals('test notes value', loan_after_update.Collections_Notes__c, 'Collections Notes value should be changed');
            System.assertEquals(false, is_enabled, 'Collections Notes should be not editable');
        }
    }

    static testMethod void testGetIsZcp98IsEnabledForEnabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-98');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp98IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-98 should be enabled');
        }
    }

    static testMethod void testGetIsZcp98IsEnabledForDisabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-98');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp98IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-98 should be disabled');
        }
    }

    static testMethod void testGetIsZcp123IsEnabledForEnabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp123IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-123 should be enabled');
        }
    }

    static testMethod void testGetIsZcp123IsEnabledForDisabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp123IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-123 should be disabled');
        }
    }

    static testMethod void testGetIsZcp76IsEnabledForEnabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-76');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp76IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-76 should be enabled');
        }
    }

    static testMethod void testGetIsZcp76IsEnabledForDisabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-76');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp76IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-76 should be disabled');
        }
    }

    static testMethod void testGetIsDefaultAction(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.setControllerProcess(LoanViewExtension.Process.CONFIRM_DEFAULT);
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsDefaultAction();
            Test.stopTest();
            System.assertEquals(true, result, 'Should be true, when current process is CONFIRM_DEFAULT');
        }
    }

    static testMethod void testGetIsDefaultActionIncorrect(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.setControllerProcess(LoanViewExtension.Process.CONFIRM_COLLECTIONS);
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsDefaultAction();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be true, when current process is not CONFIRM_DEFAULT');
        }
    }

    static testMethod void testConfirmMakeDefaultActionWithSuccessMock() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.ClassUnderTest.showMakeDefaultPopup();
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
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.ClassUnderTest.showMakeDefaultPopup();
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
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.updateLoanWithDefaultState();

            Test.startTest();
                setup_data.ClassUnderTest.checkIfLoanStateChanged();
            Test.stopTest();

            System.assertEquals(true, setup_data.ClassUnderTest.IsPageReadyToRefresh, 'Page should be ready to refresh.');
        }
    }

    static testMethod void testCheckIfLoanStateChangedWhenNotChanged() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();

            Test.startTest();
                setup_data.ClassUnderTest.checkIfLoanStateChanged();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.IsPageReadyToRefresh, 'Page should not be ready to refresh.');
        }
    }

    static testMethod void testGetIsZcp24IsEnabledForEnabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-24');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp24IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'ZCP-24 should be enabled');
        }
    }

    static testMethod void testGetIsZcp24IsEnabledForDisabled() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-24');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZcp24IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'ZCP-24 should be disabled');
        }
    }

    static testMethod void testIsDcaForLoan(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.changeDcaOnLoan(setup_data.TestAccount.Id);
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.isDcaForLoan();
            Test.stopTest();
            System.assertEquals(true, result, 'Should be true, if Loan have DCA');
        }
    }

    static testMethod void testIsDcaForLoanWithoutDca(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.isDcaForLoan();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be false, if Loan have not DCA');
        }
    }

    static testMethod void testGetIsAssignToDcaButtonAvailableDisableFs(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsAssignToDcaButtonAvailable();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be false, if zcp-123 disabled');
        }
    }

    static testMethod void testGetIsAssignToDcaButtonAvailableLoanWithDca(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.changeDcaOnLoan(setup_data.TestAccount.Id);
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsAssignToDcaButtonAvailable();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be false, if Loan have DCA');
        }
    }

    static testMethod void testGetIsAssignToDcaButtonAvailable(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsAssignToDcaButtonAvailable();
            Test.stopTest();
            System.assertEquals(true, result, 'Should be true, if Loan have not DCA and zcp-123 enabled');
        }
    }

    static testMethod void testGetIsUnassignToDcaButtonAvailableDisableFs(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsUnassignToDcaButtonAvailable();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be false, if zcp-123 disabled');
        }
    }

    static testMethod void testGetIsUnassignToDcaButtonAvailableLoanWithDca(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsUnassignToDcaButtonAvailable();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be false, if Loan have not DCA');
        }
    }

    static testMethod void testGetIsUnassignToDcaButtonAvailable(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.changeDcaOnLoan(setup_data.TestAccount.Id);
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsUnassignToDcaButtonAvailable();
            Test.stopTest();
            System.assertEquals(true, result, 'Should be true, if Loan have DCA and zcp-123 enabled');
        }
    }

    static testMethod void testGetIsPicklistDcaAccountsVisibleWithCorrectProcess(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.ClassUnderTest.showAssignDcaPopup();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsPicklistDcaAccountsVisible();
            Test.stopTest();
            System.assertEquals(true, result, 'Should be true, if current process is ASSIGN_DCA and assign button are visible');
        }
    }

    static testMethod void testGetIsPicklistDcaAccountsVisibleWithInCorrectProcess(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-123');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsPicklistDcaAccountsVisible();
            Test.stopTest();
            System.assertEquals(false, result, 'Should be false for all process exept ASSIGN_DCA');
        }
    }

    static testMethod void testGetIsPicklistDmcAccountsVisibleWithCorrectProcess(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.ClassUnderTest.showAssignDmcPopup();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsPicklistDmcAccountsVisible();
            Test.stopTest();

            System.assertEquals(true, result, 'Should be true, if current process is ASSIGN_DMC and assign button are visible');
        }
    }

    static testMethod void testGetIsPicklistDmcAccountsVisibleWithInCorrectProcess(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsPicklistDmcAccountsVisible();
            Test.stopTest();

            System.assertEquals(false, result, 'Should be false for all process exept ASSIGN_DMC');
        }
    }

    static testMethod void testGetIsPicklistDmcAccountsVisibleWhenAlreadyAssignedToDmc(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.createDmcAccount();
            setup_data.assignTestLoanAndCaseToDmc();
            setup_data.initController();
            setup_data.ClassUnderTest.showAssignDmcPopup();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsPicklistDmcAccountsVisible();
            Test.stopTest();

            System.assertEquals(false, result, 'Should be false when Loan is already assigned to DMC.');
        }
    }

    static testMethod void testGetIsCreateCollectionsAndRecoveriesCaseButtonAvailableWhenThereIsAnOpenCollectionsAndRecoveriesCase(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(1);
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsCreateCollectionsAndRecoveriesCaseButtonAvailable();
            Test.stopTest();

            System.assertEquals(false, result, 'Should return false when Loan has already an open C&R Case.');
        }
    }

    static testMethod void testGetIsCreateCollectionsAndRecoveriesCaseButtonAvailableWhenThereAreNotOpenCollectionsAndRecoveriesCases(){
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsCreateCollectionsAndRecoveriesCaseButtonAvailable();
            Test.stopTest();

            System.assertEquals(true, result, 'Should return true when Loan has not an open C&R Case.');
        }
    }

    static testMethod void testConfirmRecallFromDca() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-123', 'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createDcaAccount();
            setup_data.createLoanAssignedToDca();
            setup_data.createCollectionsRecoveriesCaseAssignedToDca();
            setup_data.reQueryTestCase();
            setup_data.initController();
            setup_data.setMockForResponseAgency(true, 200);
            setup_data.setControllerProcess(LoanViewExtension.Process.RECALL_FROM_DCA);
            setup_data.ClassUnderTest.AccountDcaId = setup_data.TestDcaAccount.Id;

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(1, [SELECT COUNT() FROM Loan__c WHERE AccountDca__c = null], 'Should unassign Loan from DCA');
            System.assertEquals(1, [SELECT COUNT() FROM Case WHERE AccountDca__c = null], 'Should unassign Case from DCA');
            System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed'], 'Should be created the task for the tracking action');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(1, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 1 chatter posts for Loan - Case is closed now.');
    }

    static testMethod void testConfirmRecallFromDcaWithoutTracking() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-123');
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccount();
            setup_data.createDcaAccount();
            setup_data.createLoanAssignedToDca();
            setup_data.createCollectionsRecoveriesCaseAssignedToDca();
            setup_data.initController();
            setup_data.setMockForResponseAgency(true, 200);
            setup_data.setControllerProcess(LoanViewExtension.Process.RECALL_FROM_DCA);
            setup_data.ClassUnderTest.AccountDcaId = setup_data.TestDcaAccount.Id;

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(1, [SELECT COUNT() FROM Loan__c WHERE AccountDca__c = null], 'Should unassign Loan from DCA');
            System.assertEquals(1, [SELECT COUNT() FROM Case WHERE AccountDca__c = null], 'Should unassign Case from DCA');
            System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed'], 'The task should not created, if zcp-149 is disable');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should not create chatter posts. For Case and Loan, if zcp-149 is disable');
    }

    static testMethod void testConfirmAssignDcaWithSuccess() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-123', 'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(1);
            setup_data.initController();
            setup_data.reQueryTestCase();
            setup_data.setMockForResponse(true);
            setup_data.setControllerProcess(LoanViewExtension.Process.ASSIGN_DCA);
            setup_data.createDcaAccount();
            setup_data.ClassUnderTest.AccountDcaId = setup_data.TestDcaAccount.Id;

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            String expected_message = 'Loan assigned to DCA successfully. Response: Success';
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact(expected_message),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(1, [SELECT COUNT() FROM Loan__c WHERE AccountDca__c = :setup_data.TestDcaAccount.Id], 'Should be assigned the correct DCA for Loan');
            System.assertEquals(1, [SELECT COUNT() FROM Case WHERE AccountDca__c = :setup_data.TestDcaAccount.Id AND Sub_Process__c = 'DCA' AND IsLockedFromUpdatesInProcess__c = true], 'Should be assigned the correct DCA for Case. Also, should be changed sub process to DCA and the case must be blocked for process builder');
            System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed' AND Type != 'Letter'], 'Should be created the task for the tracking action');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan');
    }

    static testMethod void testConfirmAssignDcaWithFail() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-123', 'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(1);
            setup_data.initController();
            setup_data.reQueryTestCase();
            setup_data.setMockForResponse(false);
            setup_data.setControllerProcess(LoanViewExtension.Process.ASSIGN_DCA);
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
            System.assertEquals(0, [SELECT COUNT() FROM Loan__c WHERE AccountDca__c = :setup_data.TestDcaAccount.Id], 'Loan should not be assigned to DCA');
            System.assertEquals(0, [SELECT COUNT() FROM Case WHERE AccountDca__c = :setup_data.TestDcaAccount.Id AND Sub_Process__c = 'DCA' AND IsLockedFromUpdatesInProcess__c = true], 'Case should not be assigned to DCA');
            System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed' AND Type != 'Letter'], 'Tasks should not be created');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Chatter posts should not be created');
    }

    static testMethod void testConfirmAssignDcaWithoutTrackingWithSuccess() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-123');
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(1);
            setup_data.createLoanWithArrearsRatio(1);
            setup_data.initController();
            setup_data.reQueryTestCase();
            setup_data.setMockForResponse(true);
            setup_data.setControllerProcess(LoanViewExtension.Process.ASSIGN_DCA);
            setup_data.createDcaAccount();
            setup_data.ClassUnderTest.AccountDcaId = setup_data.TestDcaAccount.Id;

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            String expected_message = 'Loan assigned to DCA successfully. Response: Success';
            System.assertEquals(true, MessageUtility.checkCurrentPageContainsExact(expected_message),'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage());
            System.assertEquals(1, [SELECT COUNT() FROM Loan__c WHERE AccountDca__c = :setup_data.TestDcaAccount.Id], 'Should be assigned the correct DCA for Loan');
            System.assertEquals(1, [SELECT COUNT() FROM Case WHERE AccountDca__c = :setup_data.TestDcaAccount.Id AND Sub_Process__c = 'DCA' AND IsLockedFromUpdatesInProcess__c = true], 'Should be assigned the correct DCA for Case. Also, should be changed sub process to DCA and the case must be blocked for process builder');
            System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed' AND Type != 'Letter'], 'The task should not created, if zcp-149 is disable');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should not create chatter posts. For Case and Loan, if zcp-149 is disable');
    }

    static testMethod void testConfirmAssignDmc() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(4);
            setup_data.reQueryTestCase();
            setup_data.initController();
            setup_data.setControllerProcess(LoanViewExtension.Process.ASSIGN_DMC);
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
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(4);
            setup_data.reQueryTestCase();
            setup_data.initController();
            setup_data.setControllerProcess(LoanViewExtension.Process.ASSIGN_DMC);
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

    static testMethod void testConfirmRecallDmc() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable(new Set<String>{'ZCP-149'});
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(4);
            setup_data.reQueryTestCase();
            setup_data.createDmcAccount();
            setup_data.assignTestLoanAndCaseToDmc();
            setup_data.initController();
            setup_data.setControllerProcess(LoanViewExtension.Process.RECALL_FROM_DMC);

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

    static testMethod void testConfirmRecallDmcWithoutTracking() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(4);
            setup_data.reQueryTestCase();
            setup_data.createDmcAccount();
            setup_data.assignTestLoanAndCaseToDmc();
            setup_data.initController();
            setup_data.setControllerProcess(LoanViewExtension.Process.RECALL_FROM_DMC);

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

    static testMethod void testConfirmCreateCollectionsRecoveriesCase() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.setControllerProcess(LoanViewExtension.Process.CREATE_COLLECTIONS_AND_RECOVERIES_CASE);

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('New Collections & Recoveries Case created successfully - ' + setup_data.ClassUnderTest.RelatedCase.Id),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            List<Case> related_cases = [
                    SELECT Id, Status, Process__c, Sub_Process__c, AccountId
                    FROM Case
                    WHERE Loan__c = :setup_data.TestLoan.Id
                    AND IsClosed = false
                    AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
            ];
            System.assertEquals(1, related_cases.size(), '1 C&R Case should be created.');
            System.assertEquals('New', related_cases[0].Status, 'Status of new Case should be set as "New".');
            System.assertEquals('Collections', related_cases[0].Process__c, 'Process of new Case should be set as "Collections".');
            System.assertEquals('Early Arrears', related_cases[0].Sub_Process__c, 'Sub-Process of new Case should be set as "Early Arrears".');
            System.assertEquals(setup_data.TestLoan.Account__c, related_cases[0].AccountId, 'Case should be related to Loan\'s Account.');
            System.assertEquals(related_cases[0].Id, setup_data.ClassUnderTest.RelatedCase.Id, 'New Case should be set as RelatedCase.');
            Set<Id> set_owner_id = new Set<Id> {setup_data.ClassUnderTest.RelatedCase.Id, setup_data.TestLoan.Id};
            System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId IN :set_owner_id AND Type != 'Letter'], 'Should create 2 tasks. For Case and Loan.');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.ClassUnderTest.RelatedCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan.');
    }

    static testMethod void testConfirmCreateCollectionsRecoveriesCaseWithoutTracking() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.setControllerProcess(LoanViewExtension.Process.CREATE_COLLECTIONS_AND_RECOVERIES_CASE);

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('New Collections & Recoveries Case created successfully - ' + setup_data.ClassUnderTest.RelatedCase.Id),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            List<Case> related_cases = [
                    SELECT Id, Status, Process__c, Sub_Process__c, AccountId
                    FROM Case
                    WHERE Loan__c = :setup_data.TestLoan.Id
                    AND IsClosed = false
                    AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
            ];
            System.assertEquals(1, related_cases.size(), '1 C&R Case should be created.');
            System.assertEquals('New', related_cases[0].Status, 'Status of new Case should be set as "New".');
            System.assertEquals('Collections', related_cases[0].Process__c, 'Process of new Case should be set as "Collections".');
            System.assertEquals('Early Arrears', related_cases[0].Sub_Process__c, 'Sub-Process of new Case should be set as "Early Arrears".');
            System.assertEquals(setup_data.TestLoan.Account__c, related_cases[0].AccountId, 'Case should be related to Loan\'s Account.');
            System.assertEquals(related_cases[0].Id, setup_data.ClassUnderTest.RelatedCase.Id, 'New Case should be set as RelatedCase.');
            Set<Id> set_owner_id = new Set<Id> {setup_data.ClassUnderTest.RelatedCase.Id, setup_data.TestLoan.Id};
            System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId IN :set_owner_id AND Type != 'Letter'], 'The tasks should not be created because ZCP-149 is disabled.');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.ClassUnderTest.RelatedCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'The chatter posts should not be created because ZCP-149 is disabled.');
    }

    static testMethod void testConfirmCreateCollectionsRecoveriesCaseWhenThereIsAnOpenCollectionsAndRecoveriesCase() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.setControllerProcess(LoanViewExtension.Process.CREATE_COLLECTIONS_AND_RECOVERIES_CASE);
            setup_data.createCollectionsRecoveriesCase();

            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentProcess, 'Should be null for popup to be hidden');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('There is an existing open Collections & Recoveries Case - ' + setup_data.ClassUnderTest.RelatedCase.Id),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testGetIsManagePaymentPlanVisible() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.enable('ZCP-24');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(1);
            setup_data.initController();
            Test.startTest();
                Boolean is_visible = setup_data.ClassUnderTest.getIsManagePaymentPlanVisible();
            Test.stopTest();
            System.assertEquals(true, is_visible, 'Button should be visible, when FS is enable and Case is existing');
        }
    }

    static testMethod void testGetIsManagePaymentPlanVisibleDisableFs() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        FeatureSwitch.disable('ZCP-24');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(1);
            setup_data.initController();
            Test.startTest();
                Boolean is_visible = setup_data.ClassUnderTest.getIsManagePaymentPlanVisible();
            Test.stopTest();
            System.assertEquals(false, is_visible, 'Button should not be visible, when FS is disable');
        }
    }

    static testMethod void testGetIsLoanDefaultWhenDefaultReasonIsNotBlank() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            setup_data.setDefaultReasonForTestLoan('Bankruptcy');
            Test.startTest();
                Boolean is_loan_default = setup_data.ClassUnderTest.getIsLoanDefault();
            Test.stopTest();
            System.assertEquals(true, is_loan_default, 'Should return true because Default Reason field is not blank.');
        }
    }

    static testMethod void testGetIsLoanDefaultWhenDefaultReasonIsBlank() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
            setup_data.initController();
            Test.startTest();
                Boolean is_loan_default = setup_data.ClassUnderTest.getIsLoanDefault();
            Test.stopTest();
            System.assertEquals(false, is_loan_default, 'Should return false because Default Reason field is blank.');
        }
    }

    static testMethod void testGetAccountsDca() {
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
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
        SetupDataClass setup_data = new SetupDataClass(TEST_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForTest(0);
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

    private class SetupDataClass {
        public Loan__c TestLoan;
        public Account TestAccount;
        public User TestUser;
        public User AssignedToUser;
        public LoanViewExtension ClassUnderTest;
        public Case TestCase;
        public Account TestDcaAccount;
        public Account TestDmcAccount;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        private void createDataForTest(Decimal arrears_ratio) {
            TriggerHandler.IsTriggerActive = false;
            createTestAccount();
            createLoanWithArrearsRatio(arrears_ratio);
            TriggerHandler.IsTriggerActive = true;
        }

        public void createTestAccount() {
            TestAccount = AccountBuilder.getBuilder('LoanViewExtensionTest')
                    .save()
                    .getRecord();
        }

        public void createLoanWithArrearsRatio(Decimal arrears_ratio){
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setArrearsRatio(arrears_ratio)
                    .setExternalId(Utility.getRandomString(8))
                    .save()
                    .getRecord();
        }

        public void createLoanAssignedToDca(){
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setAccountDCAID(TestDcaAccount.Id)
                    .setExternalId(Utility.getRandomString(8))
                    .save()
                    .getRecord();
        }

        public void initController() {
            ClassUnderTest = new LoanViewExtension(new ApexPages.StandardController(TestLoan));
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }

        public void setMockForResponseAgency(Boolean is_success, Integer error_code) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandGetCollectionAgencyMock(is_success, error_code));
        }

        public void setMockForLoanDetails(Boolean is_success, Integer error_code) {
            Test.setMock(HttpCalloutMock.class, new LoanDetailsViewMock(is_success, error_code));
        }

        public void createCollectionsRecoveriesCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setLoan(TestLoan)
                    .setStatus('Open')
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .save()
                    .getRecord();
        }

        public void createCollectionsRecoveriesCaseAssignedToDca() {
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setLoan(TestLoan)
                    .setStatus('Open')
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setAccountDCAID(TestDcaAccount.Id)
                    .save()
                    .getRecord();
        }

        public void setControllerProcess(LoanViewExtension.Process process) {
            ClassUnderTest.CurrentProcess = process;
        }

        public void reQueryTestCase() {
            TestCase = [SELECT Id, Status, Process__c, Loan__c FROM Case WHERE Loan__c = :TestLoan.Id AND IsClosed = false LIMIT 1];
        }

        public void reQueryTestLoan() {
            TestLoan = [SELECT id, State__c, Collections_Notes__c FROM Loan__c WHERE Id = : TestLoan.Id];
        }

        public void changeDcaOnLoan(Id dca_id){
            TestLoan = LoanBuilder.getBuilder(TestLoan)
                    .setAccountDCAID(dca_id)
                    .save()
                    .getRecord();
        }

        public void setProcessForTestCase(String process){
            createCollectionsRecoveriesCase();
            TestCase.Process__c = process;
            update TestCase;
        }

        public void createDcaAccount(){
            TestDcaAccount = AccountBuilder.getBuilder('LoanViewExtensionTest')
                    .setRecordType(RecordTypeUtility.ACCOUNT_DCA_ACCOUNT)
                    .setDcaId('test')
                    .save()
                    .getRecord();
        }

        public void createDmcAccount(){
            TestDmcAccount = AccountBuilder.getBuilder('TestDmcName')
                    .setRecordType(RecordTypeUtility.ACCOUNT_DMC_ACCOUNT)
                    .setDcaId('testDmcExternalId')
                    .save()
                    .getRecord();
        }

        public void setDefaultReasonForTestLoan(String default_reason){
            TestLoan.Default_Reason__c = default_reason;
            update TestLoan;
        }

        public void setLoanDetailsWithState(String state){
            ClassUnderTest.LoanDetails = new ApiCommandGetLoanDetails.LoanDetails();
            ClassUnderTest.LoanDetails.State = state;
        }

        public void updateLoanWithDefaultState(){
            Loan__c loan_to_update = TestLoan.clone(true);
            loan_to_update.State__c = 'Default';
            update loan_to_update;
        }

        public void assignTestLoanAndCaseToDmc(){
            TestLoan.AccountDMC__c = TestDmcAccount.Id;
            update TestLoan;
            if(TestCase != null) {
                TestCase.AccountDMC__c = TestDmcAccount.Id;
                update TestCase;
            }
        }

        public String getTaskSubjectForAction(AgentActionsRecorderForCollections.Action action){
            return '%' + AgentActionsRecorderForCollections.SUBJECT_FOR_ACTIONS.get(action) + '%';
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName(TEST_USER)
                .save();
    }
}