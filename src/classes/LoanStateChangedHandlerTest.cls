@IsTest
private class LoanStateChangedHandlerTest {

    static Integer BULK_SIZE = 10;

    static testMethod void testCreateChatterPostsForLoansWithChangedStateWhenStateChanged() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestData();

            Test.startTest();
                setup_data.updateLoansWithChangedState();
            Test.stopTest();

            List<FeedItem> feed_items = [
                    SELECT Body
                    FROM FeedItem
                    WHERE ParentId IN :setup_data.TestLoans.keySet()
                    OR ParentId IN :setup_data.TestCases.keySet()
            ];
            System.assertEquals(BULK_SIZE * 2, feed_items.size(), BULK_SIZE * 2 + ' FeedItems should be created.');
            for (FeedItem item : feed_items) {
                System.assertEquals('changed Loan Status to "Arrangement" (ZOPA BE)', item.Body, 'FeedItem should has proper Body.');
            }
        }
    }

    static testMethod void testCreateChatterPostsForLoansWithChangedStateWhenStateNotChanged() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createTestData();

            Test.startTest();
                setup_data.updateLoansWithoutChangedState();
            Test.stopTest();

            List<FeedItem> feed_items = [
                    SELECT Body
                    FROM FeedItem
                    WHERE ParentId IN :setup_data.TestLoans.keySet()
                    OR ParentId IN :setup_data.TestCases.keySet()
            ];
            System.assertEquals(0, feed_items.size(), '0 FeedItems should be created.');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Account TestAccount;
        public Map<Id, Loan__c> TestLoans;
        public Map<Id, Case> TestCases;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestAdmin' LIMIT 1];
        }

        public void createTestData() {
            createTestAccount();
            createTestLoans();
            createTestCollectionsRecoveriesCases();
        }

        private void createTestAccount() {
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .save()
                    .getRecord();
        }

        private void createTestLoans() {
            List<Loan__c> loans = new List<Loan__c>();
            for(Integer i = 0; i < BULK_SIZE; i++) {
                loans.add(LoanBuilder.getBuilder(TestAccount)
                        .setExternalId('0000-0000-0000-000' + i)
                        .setLoanStatus('Default')
                        .getRecord()
                );
            }
            insert loans;
            TestLoans = new Map<Id, Loan__c>(loans);
        }

        private void createTestCollectionsRecoveriesCases() {
            List<Case> cases = new List<Case>();
            for (Loan__c loan : TestLoans.values()) {
                cases.add(CaseBuilder.getBuilder(TestAccount)
                        .setLoan(loan)
                        .setStatus('Open')
                        .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                        .getRecord());
            }
            insert cases;
            TestCases = new Map<Id, Case>(cases);
        }

        public void updateLoansWithChangedState() {
            for (Loan__c loan : TestLoans.values()) {
                loan.State__c = 'Arrangement';
            }
            update TestLoans.values();
        }

        public void updateLoansWithoutChangedState() {
            update TestLoans.values();
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('TestAdmin')
                .save();
    }
}