@IsTest
private class LoanSetToDefaultHandlerTest {
    static Integer BULK_SIZE = 10;

    private static testMethod void testHandleLoansSetToDefaultWhenAllLoansHaveCases() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccountAndLoans();
            setup_data.createTestCollectionsRecoveriesCases();

            Test.startTest();
            LoanSetToDefaultHandler.handleLoansSetToDefault(setup_data.TestLoans.values());
            Test.stopTest();

            Map<Id, Case> related_cases = setup_data.queryTestCases();
            System.assertEquals(BULK_SIZE, related_cases.size(), 'Should retrieve 10 Cases.');
            for (Case case_item : related_cases.values()) {
                System.assertEquals('Recoveries', case_item.Process__c, 'Should be set to "Recoveries" process.');
                System.assertEquals('Default', case_item.Sub_Process__c, 'Should be set to "Default" sub-process.');
                System.assertEquals('Open - Need to Contact', case_item.Status, 'Should be set to "Open - Need to Contact" status.');
            }
            System.assertEquals(
                    BULK_SIZE * 2,
                    [SELECT COUNT() FROM Task WHERE (WhatId IN :setup_data.TestLoans.keySet() OR WhatId IN :related_cases.keySet())AND Type != 'Letter'],
                    'Should create 10 tasks for Cases and 10 tasks for Loans.'
            );
            System.assertEquals(
                    BULK_SIZE * 2,
                    [SELECT COUNT() FROM FeedItem WHERE ParentId IN :setup_data.TestLoans.keySet() OR ParentId IN :related_cases.keySet()],
                    'Should create 10 chatter posts for Loans and 10 chatter posts for Cases.'
            );
        }
    }

    private static testMethod void testHandleLoansSetToDefaultWhenAllLoansHaveNotCases() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccountAndLoans();

            Test.startTest();
            LoanSetToDefaultHandler.handleLoansSetToDefault(setup_data.TestLoans.values());
            Test.stopTest();

            Map<Id, Case> related_cases = setup_data.queryTestCases();
            System.assertEquals(BULK_SIZE, related_cases.size(), 'Should retrieve 10 Cases.');
            for (Case case_item : related_cases.values()) {
                System.assertEquals('Recoveries', case_item.Process__c, 'Should be set to "Recoveries" process.');
                System.assertEquals('Default', case_item.Sub_Process__c, 'Should be set to "Default" sub-process.');
                System.assertEquals('Open - Need to Contact', case_item.Status, 'Should be set to "Open - Need to Contact" status.');
            }
            System.assertEquals(
                    BULK_SIZE * 2,
                    [SELECT COUNT() FROM Task WHERE (WhatId IN :setup_data.TestLoans.keySet() OR WhatId IN :related_cases.keySet())AND Type != 'Letter'],
                    'Should create 10 tasks for Cases and 10 tasks for Loans.'
            );
            System.assertEquals(
                    BULK_SIZE * 2,
                    [SELECT COUNT() FROM FeedItem WHERE ParentId IN :setup_data.TestLoans.keySet() OR ParentId IN :related_cases.keySet()],
                    'Should create 10 chatter posts for Loans and 10 chatter posts for Cases.'
            );
        }
    }

    private static testMethod void testHandleLoansSetToDefaultWhenZcp149IsDisabed() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccountAndLoans();
            setup_data.createTestCollectionsRecoveriesCases();

            Test.startTest();
            LoanSetToDefaultHandler.handleLoansSetToDefault(setup_data.TestLoans.values());
            Test.stopTest();

            Map<Id, Case> related_cases = setup_data.queryTestCases();
            System.assertEquals(BULK_SIZE, related_cases.size(), 'Should retrieve 10 Cases.');
            for (Case case_item : related_cases.values()) {
                System.assertEquals('Recoveries', case_item.Process__c, 'Should be set to "Recoveries" process.');
                System.assertEquals('Default', case_item.Sub_Process__c, 'Should be set to "Default" sub-process.');
                System.assertEquals('Open - Need to Contact', case_item.Status, 'Should be set to "Open - Need to Contact" status.');
            }
            System.assertEquals(
                    0,
            [SELECT COUNT() FROM Task WHERE (WhatId IN :setup_data.TestLoans.keySet() OR WhatId IN :related_cases.keySet())AND Type != 'Letter'],
                    'Should create 0 tasks for Cases and Loans.'
            );
            System.assertEquals(
                    0,
            [SELECT COUNT() FROM FeedItem WHERE ParentId IN :setup_data.TestLoans.keySet() OR ParentId IN :related_cases.keySet()],
                    'Should create 0 chatter posts for Loans and Cases.'
            );
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public List<Account> TestAccounts;
        public Map<Id, Loan__c> TestLoans;
        public Map<Id, Case> TestCases;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'SYSADMIN' LIMIT 1];
        }

        public void createTestAccountAndLoans() {
            createTestAccounts();
            createTestLoans();
        }

        private void createTestAccounts() {
            TestAccounts = new List<Account>();
            for (Integer i = 0; i < BULK_SIZE; i++) {
                TestAccounts.add(createAccount('TestName' + i));
            }
            insert TestAccounts;
        }

        public Account createAccount(String name) {
            return AccountBuilder.getBuilder(name)
                    .getRecord();
        }

        private void createTestLoans() {
            List<Loan__c> new_loans = new List<Loan__c>();
            for (Integer i = 0; i < BULK_SIZE; i++) {
                new_loans.add(createLoan(TestAccounts[i], '0000-0000-0000-000' + i));
            }
            insert new_loans;
            TestLoans = new Map<Id, Loan__c>(new_loans);
        }

        public Loan__c createLoan(Account account_item, String external_id) {
            return LoanBuilder.getBuilder(account_item)
                    .setExternalId(external_id)
                    .getRecord();
        }

        public void createTestCollectionsRecoveriesCases() {
            List<Case> new_cases = new List<Case>();
            for (Loan__c loan : TestLoans.values()) {
                new_cases.add(createCollectionsRecoveriesCase(loan));
            }
            insert new_cases;
            TestCases = new Map<Id, Case>(new_cases);
        }

        public Case createCollectionsRecoveriesCase(Loan__c loan) {
            return CaseBuilder.getBuilder(loan.Account__r)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .setLoan(loan)
                    .getRecord();
        }

        public Map<Id, Case> queryTestCases() {
            return new Map<Id, Case>([
                    SELECT Process__c, Sub_Process__c, Status
                    FROM Case
                    WHERE Loan__c IN :TestLoans.keySet()
            ]);
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('SYSADMIN')
                .save();
    }
}