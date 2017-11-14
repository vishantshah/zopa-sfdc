@isTest
private class LoanStateCollectionsHelperTest {

    static testMethod void testChangeLoanStatusToRialtoToCollectionsSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            Test.startTest();
                LoanStateCollectionsHelper.changeLoanStatusToRialtoToCollections('test');
            Test.stopTest();
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Loan State was updated successfully'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testChangeLoanStatusToRialtoToCollectionsUnsuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(false);
            Test.startTest();
                LoanStateCollectionsHelper.changeLoanStatusToRialtoToCollections('test');
            Test.stopTest();
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Request error: Internal issues.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testDeterminateAndUpdateLoansState() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            setup_data.createLoan();
            setup_data.queryTestCase();
            Test.startTest();
                LoanStateCollectionsHelper.determinateAndUpdateLoansState(new List<id> {setup_data.TestCase.Id});
            Test.stopTest();
            System.assertEquals(1,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed']);
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan');
    }

        static testMethod void testDeterminateAndUpdateLoansStateWithoutLog() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            Test.startTest();
                LoanStateCollectionsHelper.determinateAndUpdateLoansState(new List<id> {setup_data.TestCase.Id});
            Test.stopTest();
            System.assertEquals(0,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed'], 'When ZCP-149 disabled, task Should not created');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should not create chatter posts.');
    }

    static testMethod void testGetListLoanUuidForUpdateState() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            Test.startTest();
                Map<String, String> test_map_loan_uuid = LoanStateCollectionsHelper.getListLoanUuidForUpdateState(new List<id> {setup_data.TestCase.Id});
            Test.stopTest();
            System.assertEquals(1, test_map_loan_uuid.size(), 'Should be return one uuid');
        }
    }

    static testMethod void testGetListLoanUuidForUpdateStateBulk() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            setup_data.createListCollectionsRecoveriesCases(5);
            Test.startTest();
                Map<String, String> test_map_loan_uuid = LoanStateCollectionsHelper.getListLoanUuidForUpdateState(new List<id>(setup_data.TestSetCasesId));
            Test.stopTest();
            System.assertEquals(5, test_map_loan_uuid.size(), 'Should be return five uuid');
        }
    }

    static testMethod void testGetListLoanUuidForUpdateStateIncorrectRatio() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            setup_data.createLoanWithZeroArrearsRatio();
            setup_data.createCollectionsRecoveriesCase();
            Test.startTest();
                Map<String, String> test_map_loan_uuid = LoanStateCollectionsHelper.getListLoanUuidForUpdateState(new List<id> {setup_data.TestCase.Id});
            Test.stopTest();
            System.assertEquals(0, test_map_loan_uuid.size(), 'Should be return empty map');
        }
    }

    static testMethod void testChangeLoanStatusToRialtoToCollectionsAutoSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            setup_data.createLoanWithZeroArrearsRatio();
            setup_data.createCollectionsRecoveriesCase();
            Test.startTest();
                LoanStateCollectionsHelper.changeLoanStatusToRialtoToCollectionsAuto('test', setup_data.TestCase.Loan__c);
            Test.stopTest();
            System.assertEquals(1,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed']);
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(2, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should create 2 chatter posts. For Case and Loan');
    }

    static testMethod void testChangeLoanStatusToRialtoToCollectionsAutoSuccessWithoutLog() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            Test.startTest();
                LoanStateCollectionsHelper.changeLoanStatusToRialtoToCollectionsAuto('test', setup_data.TestCase.Loan__c);
            Test.stopTest();
            System.assertEquals(0,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed'], 'When ZCP-149 disabled, task Should not created');
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should not create chatter posts.');
    }

    static testMethod void testChangeLoanStatusToRialtoToCollectionsAutoUnsuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(false);
            setup_data.createLoan();
            setup_data.createCollectionsRecoveriesCase();
            Test.startTest();
                LoanStateCollectionsHelper.changeLoanStatusToRialtoToCollectionsAuto('test', setup_data.TestCase.Loan__c);
            Test.stopTest();
            System.assertEquals(0,[SELECT COUNT() FROM Task WHERE WhatId = :setup_data.TestCase.Loan__c AND Status = 'Completed']);
        }
        Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
        System.assertEquals(0, [SELECT COUNT() FROM FeedItem WHERE ParentId IN :set_owner_id], 'Should not create chatter posts.');
    }

    private class SetupDataClass {
        public Case TestCase;
        public Account TestAccount;
        public User TestUser;
        public Loan__c TestLoan;
        public Set<Id> TestSetCasesId;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'LoanStateCollectionsHelperTest' AND LastName = 'LoanStateCollectionsHelperTest' LIMIT 1];
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }

        public void createCollectionsRecoveriesCase() {
            createAccount();
            TestCase = CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).setLoan(TestLoan).save().getRecord();
        }

        public void createLoan(){
            createAccount();
            TestLoan = LoanBuilder.getBuilder(TestAccount).setLoanStatus('withdrawn').setArrearsRatio(2).setExternalId(Utility.getRandomString(8)).save().getRecord();
        }

        public void createLoanWithZeroArrearsRatio(){
            createAccount();
            TestLoan = LoanBuilder.getBuilder(TestAccount).setLoanStatus('withdrawn').setArrearsRatio(0).setExternalId(Utility.getRandomString(8)).save().getRecord();
        }

        public void queryTestCase(){
            TestCase = [SELECT id, Loan__c FROM Case WHERE Loan__c = :TestLoan.Id AND isClosed = false];
        }

        private void createAccount() {
            TriggerHandler.IsTriggerActive = false;
            TestAccount = AccountBuilder.getBuilder('CaseCollectionsRecoveriesExtension').save().getRecord();
            TriggerHandler.IsTriggerActive = true;
        }

        public void createListCollectionsRecoveriesCases(Integer count) {
            createAccount();
            TestSetCasesId = new Set<Id>();
            List<Loan__c> list_loans = new List<Loan__c>();
            for (Integer i = 0; i < count; i++){
                list_loans.add(LoanBuilder.getBuilder(TestAccount).setLoanStatus('withdrawn').setArrearsRatio(2).setExternalId('test' + i).getRecord());
            }
            insert list_loans;
            List<Case> test_list_cases = new List<Case>();
            for (Loan__c current_loan : list_loans){
                test_list_cases.add(CaseBuilder.getBuilder(TestAccount).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).setLoan(current_loan).getRecord());
            }
            insert test_list_cases;
            for (Case current_case: test_list_cases){
                TestSetCasesId.add(current_case.Id);
            }
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('LoanStateCollectionsHelperTest')
                                     .setLastName('LoanStateCollectionsHelperTest')
                                     .save();
    }
}