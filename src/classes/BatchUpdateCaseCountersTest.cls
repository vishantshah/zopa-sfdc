@IsTest
private class BatchUpdateCaseCountersTest {
    static Integer UNDONE_REVIEW_TASK_SIZE = 1;
    static Integer DONE_REVIEW_TASK_SIZE = 2;
    static Integer BULK_CASE_SIZE = 50;

    static testMethod void testBatchUpdateCaseCountersWhenThereIs1UndoneNotOutboundCallReviewTaskRelatedToEachOpenCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createTestAccount();
            setup_data.createTestCases('Open');
            setup_data.prepareUndoneReviewTasksRelatedToCases('Some Task Subject');
            setup_data.insertTasks();

            Test.startTest();
                Database.executeBatch(setup_data.ClassUnderTest, BULK_CASE_SIZE);
            Test.stopTest();

            setup_data.reQueryTestCases();
            for (Case case_item : setup_data.TestCases.values()) {
                System.assertEquals(
                        UNDONE_REVIEW_TASK_SIZE,
                        case_item.Task_Counter__c,
                        '"Task Counter" should be set to ' + UNDONE_REVIEW_TASK_SIZE + '.'
                );
                System.assertEquals(
                        0,
                        case_item.Outbound_Calls_Counter__c,
                        '"Outbound Calls Counter" should be set to ' + 0 + '.'
                );
                System.assertEquals(
                        0,
                        case_item.Contacts_Made_Counter__c,
                        '"Contacts Made" counter should be set to ' + 0 + '.'
                );
            }
        }
    }

    static testMethod void testBatchUpdateCaseCountersWhenThereIs1UndoneOutboundCallReviewTaskRelatedToEachOpenCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createTestAccount();
            setup_data.createTestCases('Open');
            setup_data.prepareUndoneReviewTasksRelatedToCases('Outbound Call');
            setup_data.insertTasks();

            Test.startTest();
                Database.executeBatch(setup_data.ClassUnderTest, BULK_CASE_SIZE);
            Test.stopTest();

            setup_data.reQueryTestCases();
            for (Case case_item : setup_data.TestCases.values()) {
                System.assertEquals(
                        UNDONE_REVIEW_TASK_SIZE,
                        case_item.Task_Counter__c,
                        '"Task Counter" should be set to ' + UNDONE_REVIEW_TASK_SIZE + '.'
                );
                System.assertEquals(
                        UNDONE_REVIEW_TASK_SIZE,
                        case_item.Outbound_Calls_Counter__c,
                        '"Outbound Calls Counter" should be set to ' + UNDONE_REVIEW_TASK_SIZE + '.'
                );
                System.assertEquals(
                        0,
                        case_item.Contacts_Made_Counter__c,
                        '"Contacts Made" counter should be set to ' + 0 + '.'
                );
            }
        }
    }

    static testMethod void testBatchUpdateCaseCountersWhenThereAre2DoneNotOutboundCallReviewTasksRelatedToEachOpenCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createTestAccount();
            setup_data.createTestCases('Open');
            setup_data.prepareDoneReviewTasksRelatedToCases('Some Task Subject');
            setup_data.insertTasks();

            Test.startTest();
                Database.executeBatch(setup_data.ClassUnderTest, BULK_CASE_SIZE);
            Test.stopTest();

            setup_data.reQueryTestCases();
            for (Case case_item : setup_data.TestCases.values()) {
                System.assertEquals(
                        DONE_REVIEW_TASK_SIZE,
                        case_item.Task_Counter__c,
                        '"Task Counter" should be set to ' + DONE_REVIEW_TASK_SIZE + '.'
                );
                System.assertEquals(
                        0,
                        case_item.Outbound_Calls_Counter__c,
                        '"Outbound Calls Counter" should be set to ' + 0 + '.'
                );
                System.assertEquals(
                        DONE_REVIEW_TASK_SIZE,
                        case_item.Contacts_Made_Counter__c,
                        '"Contacts Made" counter should be set to ' + DONE_REVIEW_TASK_SIZE + '.'
                );
            }
        }
    }

    static testMethod void testBatchUpdateCaseCountersWhenThereAre2DoneOutboundCallReviewTasksRelatedToEachOpenCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createTestAccount();
            setup_data.createTestCases('Open');
            setup_data.prepareDoneReviewTasksRelatedToCases('Outbound Call');
            setup_data.insertTasks();

            Test.startTest();
                Database.executeBatch(setup_data.ClassUnderTest, BULK_CASE_SIZE);
            Test.stopTest();

            setup_data.reQueryTestCases();
            for (Case case_item : setup_data.TestCases.values()) {
                System.assertEquals(
                        DONE_REVIEW_TASK_SIZE,
                        case_item.Task_Counter__c,
                        '"Task Counter" should be set to ' + DONE_REVIEW_TASK_SIZE + '.'
                );
                System.assertEquals(
                        DONE_REVIEW_TASK_SIZE,
                        case_item.Outbound_Calls_Counter__c,
                        '"Outbound Calls Counter" should be set to ' + DONE_REVIEW_TASK_SIZE + '.'
                );
                System.assertEquals(
                        DONE_REVIEW_TASK_SIZE,
                        case_item.Contacts_Made_Counter__c,
                        '"Contacts Made" counter should be set to ' + DONE_REVIEW_TASK_SIZE + '.'
                );
            }
        }
    }

    static testMethod void testBatchUpdateCaseCountersWhenThereAreNoTasksRelatedToCases() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.createTestAccount();
            setup_data.createTestCases('Open');
            setup_data.insertTasks();

            Test.startTest();
                Database.executeBatch(setup_data.ClassUnderTest, BULK_CASE_SIZE);
            Test.stopTest();

            setup_data.reQueryTestCases();
            for (Case case_item : setup_data.TestCases.values()) {
                System.assertEquals(
                        0,
                        case_item.Task_Counter__c,
                        '"Task Counter" should be set to ' + 0 + '.'
                );
                System.assertEquals(
                        0,
                        case_item.Outbound_Calls_Counter__c,
                        '"Outbound Calls Counter" should be set to ' + 0 + '.'
                );
                System.assertEquals(
                        0,
                        case_item.Contacts_Made_Counter__c,
                        '"Contacts Made" counter should be set to ' + 0 + '.'
                );
            }
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Account TestAccount;
        public Map<Id, Case> TestCases;
        public List<Task> NewTasks;
        public BatchUpdateCaseCounters ClassUnderTest;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' LIMIT 1];
            NewTasks = new List<Task>();
        }

        public void initClassUnderTest() {
            ClassUnderTest = new BatchUpdateCaseCounters();
        }

        public void createTestAccount() {
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .setRecordType(RecordTypeUtility.ACCOUNT_BUSINESS_ACCOUNT)
                    .save()
                    .getRecord();
        }

        public void createTestCases(String status) {
            List<Case> cases = CaseBuilder.getBuilder(TestAccount)
                    .setOwner(TestUser.Id)
                    .setStatus(status)
                    .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                    .getRecordList(BULK_CASE_SIZE);
            TriggerHandler.IsTriggerActive = false;
            insert cases;
            TriggerHandler.IsTriggerActive = true;
            TestCases = new Map<Id, Case>(cases);
        }

        public void prepareUndoneReviewTasksRelatedToCases(String subject) {
            prepareReviewTasksRelatedToCases(UNDONE_REVIEW_TASK_SIZE, false, subject);
        }

        public void prepareDoneReviewTasksRelatedToCases(String subject) {
            prepareReviewTasksRelatedToCases(DONE_REVIEW_TASK_SIZE, true, subject);
        }

        private void prepareReviewTasksRelatedToCases(Integer number_of_tasks, Boolean is_completed, String subject) {
            for (Case case_item : TestCases.values()) {
                NewTasks.addAll(TaskBuilder.getBuilder()
                        .setRelatedTo(case_item.Id)
                        .setSubject(subject)
                        .setRecordType(RecordTypeUtility.TASK_COLLECTIONS_CALL)
                        .setStatus(is_completed ? 'Completed' : 'Open')
                        .setReviewDueDate(is_completed ? System.now().addDays(-1) : null)
                        .setCompletedDateTime(System.now())
                        .getRecordList(number_of_tasks));
            }
        }

        private void insertTasks() {
            insert NewTasks;
        }

        public void reQueryTestCases() {
            TestCases = new Map<id, Case>([
                    SELECT Id, Contacts_Made_Counter__c, Outbound_Calls_Counter__c, Task_Counter__c
                    FROM Case
                    WHERE Id IN :TestCases.keySet()
            ]);
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.COLLECTIONS)
                .setLastName('TestLastName')
                .save()
                .getRecord();
    }
}