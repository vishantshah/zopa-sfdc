@IsTest
private class BulkCaseChangeExtensionTest {
    static Integer BULK_SIZE = 10;

    static testMethod void testInitControllerWhenThereAreOnlyCollectionsAndRecoveriesCases() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCases();
            setup_data.createCollectionsRecoveriesCases(BULK_SIZE);

            Test.startTest();
            setup_data.initController();
            Test.stopTest();

            System.assertEquals(BULK_SIZE, setup_data.ClassUnderTest.SelectedCases.size(), BULK_SIZE + ' Cases should be selected.');
            System.assertNotEquals(null, setup_data.ClassUnderTest.CaseBulkChange, 'CaseBulkChange should be created.');
            System.assertEquals(true, setup_data.ClassUnderTest.AllRecordsHasCollectionsAndRecoveriesRecordType, 'Should be set to true.');
        }
    }

    static testMethod void testInitControllerWhenThereAreNoCollectionsAndRecoveriesCases() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCases();
            setup_data.createManualUnderwritingCases(BULK_SIZE);

            Test.startTest();
            setup_data.initController();
            Test.stopTest();

            System.assertEquals(BULK_SIZE, setup_data.ClassUnderTest.SelectedCases.size(), BULK_SIZE + ' Cases should be selected.');
            System.assertNotEquals(null, setup_data.ClassUnderTest.CaseBulkChange, 'CaseBulkChange should be created.');
            System.assertEquals(false, setup_data.ClassUnderTest.AllRecordsHasCollectionsAndRecoveriesRecordType, 'Should be set to false.');
        }
    }

    static testMethod void testInitControllerWhenThereAreNotOnlyCollectionsAndRecoveriesCases() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCases();
            setup_data.createCollectionsRecoveriesCases(BULK_SIZE);
            setup_data.createManualUnderwritingCases(BULK_SIZE);

            Test.startTest();
            setup_data.initController();
            Test.stopTest();

            System.assertEquals(BULK_SIZE * 2, setup_data.ClassUnderTest.SelectedCases.size(), (BULK_SIZE * 2) + ' Cases should be selected.');
            System.assertNotEquals(null, setup_data.ClassUnderTest.CaseBulkChange, 'CaseBulkChange should be created.');
            System.assertEquals(false, setup_data.ClassUnderTest.AllRecordsHasCollectionsAndRecoveriesRecordType, 'Should be set to false.');
        }
    }

    static testMethod void testSetStatusOptions() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setStatusJsonMap();

            Test.startTest();
            setup_data.ClassUnderTest.setStatusOptions();
            Test.stopTest();

            System.assertEquals(3, setup_data.ClassUnderTest.StatusOptions.size(), '3 Status options (2 + None) should be set.');
        }
    }

    static testMethod void testIsAnyChangesInCaseBulkChangeWhenThereAreNoChanges() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();

            Test.startTest();
            Boolean result = setup_data.ClassUnderTest.isAnyChanges();
            Test.stopTest();

            System.assertEquals(false, result, 'Should return false because there are no changes in CaseBulkChange.');
        }
    }

    static testMethod void testIsAnyChangesInCaseBulkChangeWhenThereAreSomeChanges() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.changeSubProcessInCaseBulkChange();

            Test.startTest();
            Boolean result = setup_data.ClassUnderTest.isAnyChanges();
            Test.stopTest();

            System.assertEquals(true, result, 'Should return true because there are changes in CaseBulkChange.');
        }
    }

    static testMethod void testSaveMethodWhenThereAreNoChanges() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();

            Test.startTest();
            setup_data.ClassUnderTest.save();
            Test.stopTest();

            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('You need to add some changes!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testSaveMethodWhenThereAreSomeChanges() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCases();
            setup_data.createCollectionsRecoveriesCases(BULK_SIZE);
            setup_data.initController();
            setup_data.changeSubProcessInCaseBulkChange();

            Test.startTest();
            setup_data.ClassUnderTest.save();
            Test.stopTest();

            setup_data.reQueryTestCases();
            for(Case case_item : setup_data.TestCases.values()) {
                System.assertEquals('Need to Contact', case_item.Sub_Process__c, 'SubProcess should be updated.');
            }
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Cases has been updated successfully!'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testGetIsBulkChangePermissionAvailable() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();

            Test.startTest();
            Boolean result = setup_data.ClassUnderTest.getIsBulkChangePermissionAvailable();
            Test.stopTest();

            Boolean has_current_user_bulk_change_permission = CustomPermissions.getInstance().isCustomPermissionAvailable('Collections_Recoveries_Bulk_Change');
            System.assertEquals(has_current_user_bulk_change_permission, result, 'Should return proper value for System Administrator.');
        }
    }

    static testMethod void testGetIsAnyRecordsSelectedWhenThereAreNoSelectedRecords() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();

            Test.startTest();
            Boolean result = setup_data.ClassUnderTest.getIsAnyRecordsSelected();
            Test.stopTest();

            System.assertEquals(false, result, 'Should return false because there are no selected records.');
        }
    }

    static testMethod void testGetIsAnyRecordsSelectedWhenThereAreSelectedRecords() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCases();
            setup_data.createCollectionsRecoveriesCases(BULK_SIZE);
            setup_data.initController();

            Test.startTest();
            Boolean result = setup_data.ClassUnderTest.getIsAnyRecordsSelected();
            Test.stopTest();

            System.assertEquals(true, result, 'Should return true because there are selected records.');
        }
    }

    static testMethod void testIsCasesRelatedToLoansWhenAllCasesAreRelatedToLoans() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCases();
            setup_data.createCollectionsRecoveriesCases(BULK_SIZE);
            setup_data.initController();

            Test.startTest();
            Boolean result = setup_data.ClassUnderTest.isCasesRelatedToLoans();
            Test.stopTest();

            System.assertEquals(true, result, 'Should return true because there are no cases without loans.');
        }
    }

    static testMethod void testIsCasesRelatedToLoansWhenNotAllCasesAreRelatedToLoans() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCasesNotRelatedToLoans(BULK_SIZE);
            setup_data.initController();

            Test.startTest();
            Boolean result = setup_data.ClassUnderTest.isCasesRelatedToLoans();
            Test.stopTest();

            System.assertEquals(false, result, 'Should return false because there are cases without loans.');
            String expected_message = 'Some of the selected Cases are not assigned to Loans. Please check the following Cases: ' + String.join(new List<Id>(setup_data.TestCases.keySet()), ', ');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact(expected_message),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testIsRelatedLoansStateProperToAssignLoanToDcaWhenStatesAreProper() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCasesWithLoanState('Default');
            setup_data.createCollectionsRecoveriesCases(BULK_SIZE);
            setup_data.initController();

            Test.startTest();
            Boolean result = setup_data.ClassUnderTest.isRelatedLoansStateProperToAssignLoanToDca();
            Test.stopTest();

            System.assertEquals(true, result, 'Should return true because there are no related loans with improper State.');
        }
    }

    static testMethod void testIsRelatedLoansStateProperToAssignLoanToDcaWhenStatesAreImproper() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCasesWithLoanState('Arrangement');
            setup_data.createCollectionsRecoveriesCases(BULK_SIZE);
            setup_data.initController();

            Test.startTest();
            Boolean result = setup_data.ClassUnderTest.isRelatedLoansStateProperToAssignLoanToDca();
            Test.stopTest();

            System.assertEquals(false, result, 'Should return false because there are related loans with improper State.');
            String expected_message = 'You can not assign Loan to DCA when current Loan Status equals: Arrangement, Closed, Deceased or Settled. Please check the following related Loans: ' + setup_data.TestLoan.Id;
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact(expected_message),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testShowAssignToDcaPopupWhenValidationSucceed() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCasesWithLoanState('Default');
            setup_data.createCollectionsRecoveriesCases(BULK_SIZE);
            setup_data.initController();

            Test.startTest();
            setup_data.ClassUnderTest.showAssignToDcaPopup();
            Test.stopTest();

            System.assertEquals(BulkCaseChangeExtension.Action.ASSIGN_TO_DCA, setup_data.ClassUnderTest.CurrentAction, 'Assign to DCA action should be set as Current Action.');
        }
    }

    static testMethod void testShowAssignToDcaPopupWhenValidationFailed() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCasesWithLoanState('Arrangement');
            setup_data.createCollectionsRecoveriesCases(BULK_SIZE);
            setup_data.initController();

            Test.startTest();
            setup_data.ClassUnderTest.showAssignToDcaPopup();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.CurrentAction, 'Current Action should be null.');
        }
    }

    static testMethod void testGetIsCurrentActionAssignToDcaWhenItIs() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();
            setup_data.setCurrentActionAs(BulkCaseChangeExtension.Action.ASSIGN_TO_DCA);

            Test.startTest();
            Boolean result = setup_data.ClassUnderTest.getIsCurrentActionAssignToDca();
            Test.stopTest();

            System.assertEquals(true, result, 'Should return true.');
        }
    }

    static testMethod void testGetIsCurrentActionAssignToDcaWhenItIsNot() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initController();

            Test.startTest();
            Boolean result = setup_data.ClassUnderTest.getIsCurrentActionAssignToDca();
            Test.stopTest();

            System.assertEquals(false, result, 'Should return false.');
        }
    }

    static testMethod void testGetDcaAccounts() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createDcaAccount();
            setup_data.initController();

            Test.startTest();
            List<SelectOption> result = setup_data.ClassUnderTest.getDcaAccounts();
            Test.stopTest();

            System.assertEquals(1, result.size(), 'Should return one DCA Account.');
            System.assertEquals(setup_data.TestDcaAccount.Name, result[0].getLabel(), 'Should set Account Name as label.');
            System.assertEquals(setup_data.TestDcaAccount.Id, result[0].getValue(), 'Should set Account Id as value.');
        }
    }

    static testMethod void testConfirmActionWhenActionIsAssignToDcaWithCalloutSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCasesWithLoanState('Default');
            setup_data.createCollectionsRecoveriesCases(1);
            setup_data.createDcaAccount();
            setup_data.initController();
            setup_data.setMockForResponse(true);
            setup_data.setCurrentActionAs(BulkCaseChangeExtension.Action.ASSIGN_TO_DCA);
            setup_data.setDcaAccountId();

            Test.startTest();
            setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            String expected_message = 'Cases successfully assigned to DCA: ' + setup_data.TestCases.values()[0].Id;
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact(expected_message),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            setup_data.reQueryTestCases();
            System.assertEquals('DCA', setup_data.TestCases.values()[0].Sub_Process__c, 'Case Sub Process should be set to DCA.');
            System.assertEquals(CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD), setup_data.TestCases.values()[0].OwnerId, 'Case Owner should be set to On-Hold.');
            System.assertEquals(true, setup_data.TestCases.values()[0].IsLockedFromUpdatesInProcess__c, 'Case should be Locked From Updates In Process.');
            System.assertEquals(setup_data.TestDcaAccount.Id, setup_data.TestCases.values()[0].AccountDCA__c, 'Case should be assigned to DCA.');
            setup_data.reQueryTestLoan();
            System.assertEquals(setup_data.TestDcaAccount.Id, setup_data.TestLoan.AccountDCA__c, 'Loan should be assigned to DCA.');
            Set<Id> task_parents = new Set<Id>{setup_data.TestCases.values()[0].Id, setup_data.TestLoan.Id};
            System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId IN :task_parents AND Type != 'Letter'], '2 Tasks should be created.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentAction, 'Current action should be set to null.');
        }
        Set<Id> task_parents = new Set<Id>{setup_data.TestCases.values()[0].Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :task_parents], '2 chatter posts should be created.');
    }

    static testMethod void testConfirmActionWhenActionIsAssignToDcaWithCalloutFail() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createDataForCasesWithLoanState('Default');
            setup_data.createCollectionsRecoveriesCases(1);
            setup_data.createDcaAccount();
            setup_data.initController();
            setup_data.setMockForResponse(false);
            setup_data.setCurrentActionAs(BulkCaseChangeExtension.Action.ASSIGN_TO_DCA);
            setup_data.setDcaAccountId();

            Test.startTest();
            setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();

            String expected_message = 'Cases not assigned to DCA:<br/>' + setup_data.TestCases.values()[0].Id + ' - Request error: Internal issues.';
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact(expected_message),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
            setup_data.reQueryTestCases();
            System.assertNotEquals('DCA', setup_data.TestCases.values()[0].Sub_Process__c, 'Case Sub Process should not be set to DCA.');
            System.assertEquals(false, setup_data.TestCases.values()[0].IsLockedFromUpdatesInProcess__c, 'Case should not be Locked From Updates In Process.');
            System.assertEquals(null, setup_data.TestCases.values()[0].AccountDCA__c, 'Case should not be assigned to DCA.');
            setup_data.reQueryTestLoan();
            System.assertEquals(null, setup_data.TestLoan.AccountDCA__c, 'Loan should not be assigned to DCA.');
            Set<Id> task_parents = new Set<Id>{setup_data.TestCases.values()[0].Id, setup_data.TestLoan.Id};
            System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId IN :task_parents AND Type != 'Letter'], 'No Tasks should be created.');
            System.assertEquals(null, setup_data.ClassUnderTest.CurrentAction, 'Current action should be set to null.');
        }
        Set<Id> task_parents = new Set<Id>{setup_data.TestCases.values()[0].Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :task_parents], 'No chatter posts should be created.');
    }

    private class SetupDataClass {
        public BulkCaseChangeExtension ClassUnderTest;
        public User TestUser;
        public Account TestAccount;
        public Loan__c TestLoan;
        public Map<Id, Case> TestCases;
        public Account TestDcaAccount;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' LIMIT 1];
            TestCases = new Map<Id, Case>();
        }

        public void createDataForCases() {
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .save()
                    .getRecord();
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setExternalId('0000-0000-0000-0001')
                    .save()
                    .getRecord();
        }

        public void createDataForCasesWithLoanState(String loan_state) {
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .save()
                    .getRecord();
            TestLoan = LoanBuilder.getBuilder(TestAccount)
                    .setExternalId('0000-0000-0000-0001')
                    .setLoanStatus(loan_state)
                    .save()
                    .getRecord();
        }

        public void createCollectionsRecoveriesCases(Integer number_of_cases) {
            List<Case> cases = CaseBuilder.getBuilder(TestAccount)
                .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                .setLoan(TestLoan)
                .setProcess('Collections')
                .setSubProcess('Collections')
                .getRecordList(number_of_cases);
            insert cases;
            TestCases.putAll(cases);
        }

        public void createCollectionsRecoveriesCasesNotRelatedToLoans(Integer number_of_cases) {
            List<Case> cases = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setProcess('Collections')
                    .setSubProcess('Collections')
                    .getRecordList(number_of_cases);
            insert cases;
            TestCases.putAll(cases);
        }

        public void createManualUnderwritingCases(Integer number_of_cases) {
            List<Case> cases = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)
                    .setLoan(TestLoan)
                    .getRecordList(number_of_cases);
            insert cases;
            TestCases.putAll(cases);
        }

        public void initController() {
            ApexPages.StandardSetController controller = new ApexPages.StandardSetController(TestCases.values());
            controller.setSelected(TestCases.values());
            ClassUnderTest = new BulkCaseChangeExtension(controller);
        }

        public void reQueryTestCases() {
            TestCases = new Map<Id, Case>([SELECT Id, AccountDCA__c, IsLockedFromUpdatesInProcess__c, Process__c, Sub_Process__c, Status, OwnerId FROM Case WHERE Id IN :TestCases.keySet()]);
        }

        public void reQueryTestLoan() {
            TestLoan = [SELECT Id, AccountDCA__c FROM Loan__c WHERE Id = :TestLoan.Id LIMIT 1];
        }

        public void setStatusJsonMap() {
            Map<String, String> status_map = new Map<String, String> {
                    'label1' => 'value1',
                    'label2' => 'value2'
            };
            ClassUnderTest.StatusJsonMap = JSON.serialize(status_map);
        }

        public void changeSubProcessInCaseBulkChange() {
            ClassUnderTest.CaseBulkChange.Sub_Process__c = 'Need to Contact';
        }

        public void createDcaAccount(){
            TestDcaAccount = AccountBuilder.getBuilder('TestDcaAccountName')
                    .setRecordType(RecordTypeUtility.ACCOUNT_DCA_ACCOUNT)
                    .setDcaId('0000-5555-0000-0001')
                    .save()
                    .getRecord();
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }

        public void setCurrentActionAs(BulkCaseChangeExtension.Action action) {
            ClassUnderTest.CurrentAction = action;
        }

        public void setDcaAccountId() {
            ClassUnderTest.DcaAccountId = TestDcaAccount.Id;
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('TestLastName')
                .save();
    }
}