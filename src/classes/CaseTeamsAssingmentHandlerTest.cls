@isTest
public class CaseTeamsAssingmentHandlerTest {
    static Integer BULK_SIZE = 10;

    static testMethod void testAssignCollectionsCasesToTeamsOnNextReviewDateWithPromiseToPaySubProcess() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccounts();
            setup_data.createTestLoans();
            setup_data.createTestCases('Collections', 'Promise to Pay');

            Test.startTest();
            CaseTeamsAssingmentHandler.assignCasesToTeamsOnNextReviewDate(setup_data.getCaseIdsAsList());
            Test.stopTest();

            setup_data.reQueryCases();
            for (Case case_item : setup_data.TestCases.values()) {
                System.assertEquals('Broken Promise to Pay', case_item.Sub_Process__c, 'Sub process should be set as Broken Promise to Pay.');
                System.assertEquals(false, case_item.IsLockedFromUpdatesInProcess__c, 'Case should not be locked from updates in processes.');
            }
            setup_data.queryTasksAndFeedItems();
            System.assertEquals(BULK_SIZE, setup_data.CreatedCaseTasks.size(), BULK_SIZE + ' tasks for Cases should be created.');
            System.assertEquals(BULK_SIZE, setup_data.CreatedLoanTasks.size(), BULK_SIZE + ' tasks for Loans should be created.');
            System.assertEquals(2 * BULK_SIZE, setup_data.CreatedFeedItems.size(), (2 * BULK_SIZE) + ' feed items for Cases and Loans should be created.');
        }
    }

    static testMethod void testAssignCollectionsCasesToTeamsOnNextReviewDateWithCollectionsSubProcess() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccounts();
            setup_data.createTestLoans();
            setup_data.createTestCases('Collections', 'Collections');

            Test.startTest();
            CaseTeamsAssingmentHandler.assignCasesToTeamsOnNextReviewDate(setup_data.getCaseIdsAsList());
            Test.stopTest();

            setup_data.reQueryCases();
            for (Case case_item : setup_data.TestCases.values()) {
                System.assertEquals('Collections', case_item.Sub_Process__c, 'Sub process should not be changed.');
                System.assertEquals(false, case_item.IsLockedFromUpdatesInProcess__c, 'Case should not be locked from updates in processes.');
            }
            setup_data.queryTasksAndFeedItems();
            System.assertEquals(0, setup_data.CreatedCaseTasks.size(), 'No tasks for Cases should be created.');
            System.assertEquals(0, setup_data.CreatedLoanTasks.size(), 'No tasks for Loans should be created.');
            System.assertEquals(0, setup_data.CreatedFeedItems.size(), 'No feed items for Cases and Loans should be created.');
        }
    }

    static testMethod void testAssignRecoveriesCasesToTeamsOnNextReviewDateWithArrangementsSubProcess() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccounts();
            setup_data.createTestLoans();
            setup_data.createTestCases('Recoveries', 'Arrangements');

            Test.startTest();
            CaseTeamsAssingmentHandler.assignCasesToTeamsOnNextReviewDate(setup_data.getCaseIdsAsList());
            Test.stopTest();

            setup_data.reQueryCases();
            for (Case case_item : setup_data.TestCases.values()) {
                System.assertEquals('Arrangements', case_item.Sub_Process__c, 'Sub process should not be changed.');
                System.assertEquals(false, case_item.IsLockedFromUpdatesInProcess__c, 'Case should not be locked from updates in processes.');
            }
            setup_data.queryTasksAndFeedItems();
            System.assertEquals(0, setup_data.CreatedCaseTasks.size(), 'No tasks for Cases should be created.');
            System.assertEquals(0, setup_data.CreatedLoanTasks.size(), 'No tasks for Loans should be created.');
            System.assertEquals(0, setup_data.CreatedFeedItems.size(), 'No feed items for Cases and Loans should be created.');
        }
    }

    static testMethod void testAssignSensitiveCustomersCasesToTeamsOnNextReviewDateWithCollectionsSubProcess() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createTestAccounts();
            setup_data.createTestLoans();
            setup_data.createTestCases('Sensitive Customers', 'Sensitive Case');

            Test.startTest();
            CaseTeamsAssingmentHandler.assignCasesToTeamsOnNextReviewDate(setup_data.getCaseIdsAsList());
            Test.stopTest();

            setup_data.reQueryCases();
            for (Case case_item : setup_data.TestCases.values()) {
                System.assertEquals('Sensitive Case', case_item.Sub_Process__c, 'Sub process should not be changed.');
                System.assertEquals(true, case_item.IsLockedFromUpdatesInProcess__c, 'Case should be locked from updates in processes.');
            }
            setup_data.queryTasksAndFeedItems();
            System.assertEquals(0, setup_data.CreatedCaseTasks.size(), 'No tasks for Cases should be created.');
            System.assertEquals(0, setup_data.CreatedLoanTasks.size(), 'No tasks for Loans should be created.');
            System.assertEquals(0, setup_data.CreatedFeedItems.size(), 'No feed items for Cases and Loans should be created.');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public List<Account> TestAccounts;
        public Map<Id, Loan__c> TestLoans;
        public Map<Id, Case> TestCases;
        public Map<Id, Case> TestCasesOther;
        public List<Task> CreatedLoanTasks;
        public List<Task> CreatedCaseTasks;
        public List<FeedItem> CreatedFeedItems;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' AND FirstName = 'TestFirstName' LIMIT 1];
        }

        public void createTestAccounts() {
            TestAccounts = new List<Account>();
            for(Integer i = 0; i < BULK_SIZE; i++) {
                TestAccounts.add(AccountBuilder.getBuilder('TestAccountName' + i)
                        .setRecordType(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT)
                        .getRecord());
            }
            insert TestAccounts;
        }

        public void createTestLoans() {
            List<Loan__c> loans = new List<Loan__c>();
            for(Integer i = 0; i < BULK_SIZE; i++) {
                loans.add(LoanBuilder.getBuilder(TestAccounts[i])
                        .setLoanStatus('withdrawn')
                        .setExternalId('0000-0000-0000-0000' + i)
                        .getRecord());
            }
            insert loans;
            TestLoans = new Map<Id, Loan__c>(loans);
        }

        public void createTestCases(String process_name, String sub_process_name) {
            Boolean is_sensitive = process_name == 'Sensitive Customers';
            List<Case> cases = new List<Case>();
            for(Integer i = 0; i < BULK_SIZE; i++) {
                cases.add(CaseBuilder.getBuilder(TestAccounts[i])
                        .setOwner(getOnHoldQueueId())
                        .setLoan(TestLoans.values()[i])
                        .setStatus('Open')
                        .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                        .setProcess(process_name)
                        .setSubProcess(sub_process_name)
                        .setIsLockedFromUpdatesInProcess(true)
                        .setIsSensitive(is_sensitive)
                        .getRecord());
            }
            insert cases;
            TestCases = new Map<Id, Case>(cases);
            reQueryCases();
        }

        public Id getOnHoldQueueId() {
            return CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.ON_HOLD);
        }

        public void reQueryCases() {
            TestCases = new Map<Id, Case>([
                    SELECT Id, IsLockedFromUpdatesInProcess__c, OwnerId, Sub_Process__c, RecordTypeId, Loan__c
                    FROM Case
                    WHERE Id IN:TestCases.keySet()
            ]);
        }

        public List<Id> getCaseIdsAsList() {
            return new List<Id>(TestCases.keySet());
        }

        public void queryTasksAndFeedItems() {
            CreatedLoanTasks = [SELECT Id FROM Task WHERE WhatId IN :TestLoans.keySet()];
            CreatedCaseTasks = [SELECT Id FROM Task WHERE WhatId IN :TestCases.keySet()];
            Set<Id> parent_ids = new Set<Id>();
            parent_ids.addAll(TestCases.keySet());
            parent_ids.addAll(TestLoans.keySet());
            CreatedFeedItems = [SELECT Body FROM FeedItem WHERE ParentId IN :parent_ids];
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setFirstName('TestFirstName')
                .setLastName('TestLastName')
                .save()
                .getRecord();
    }
}