@isTest
private class AgentActionsRecorderForCollectionsTest {

    @isTest static void testGetAgentActionsInstance(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED);
            Test.stopTest();

            String subject_for_action = setup_data.getSubjectForAction(AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED);
            System.assertEquals(UserInfo.getName() + ' ' + subject_for_action, setup_data.ClassUnderTest.BaseTask.Subject, 'Should create base task with proper subject.');
            System.assertEquals('', setup_data.ClassUnderTest.BaseTask.Description, 'Should create base task with empty comment.');
            System.assertEquals(subject_for_action, setup_data.ClassUnderTest.FeedMessage, 'Should create proper feed message.');
        }
    }

    @isTest static void testGetAgentActionsInstanceWithDescription(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            String description = 'My action description.';

            Test.startTest();
            setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED, description);
            Test.stopTest();

            String subject_for_action = setup_data.getSubjectForAction(AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED);
            System.assertEquals(UserInfo.getName() + ' ' + subject_for_action, setup_data.ClassUnderTest.BaseTask.Subject, 'Should create base task with proper subject.');
            System.assertEquals(description, setup_data.ClassUnderTest.BaseTask.Description, 'Should create base task with proper description.');
            System.assertEquals(subject_for_action, setup_data.ClassUnderTest.FeedMessage, 'Should create proper feed message.');
        }
    }

    @isTest static void testGetAgentActionsInstanceWithActionTarget(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            String action_target = 'My action target.';

            Test.startTest();
            setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED, '', action_target);
            Test.stopTest();

            String subject_for_action = setup_data.getSubjectForAction(AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED);
            System.assertEquals(UserInfo.getName() + ' ' + subject_for_action + ' ' + action_target, setup_data.ClassUnderTest.BaseTask.Subject, 'Should create base task with proper subject.');
            System.assertEquals('', setup_data.ClassUnderTest.BaseTask.Description, 'Should create base task with empty description.');
            System.assertEquals(subject_for_action + ' ' + action_target, setup_data.ClassUnderTest.FeedMessage, 'Should create proper feed message.');
        }
    }

    @isTest static void testGetAgentActionsInstanceWithDescriptionAndActionTarget(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            String description = 'My action description.';
            String action_target = 'My action target.';

            Test.startTest();
            setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED, description, action_target);
            Test.stopTest();

            String subject_for_action = setup_data.getSubjectForAction(AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED);
            System.assertEquals(UserInfo.getName() + ' ' + subject_for_action + ' ' + action_target, setup_data.ClassUnderTest.BaseTask.Subject, 'Should create base task with proper subject.');
            System.assertEquals(description, setup_data.ClassUnderTest.BaseTask.Description, 'Should create base task with proper description.');
            System.assertEquals(subject_for_action + ' ' + action_target, setup_data.ClassUnderTest.FeedMessage, 'Should create proper feed message.');
        }
    }


    @isTest static void testRecordActionForLoanStateDeceased() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithCase();
            setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestLoan.Id);
                setup_data.ClassUnderTest.insertNewTasks();
                setup_data.ClassUnderTest.insertNewFeedItems();
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            String expected_message = 'changed Loan Status to "Deceased"';
            for (Task child_task : setup_data.CreatedLoanTasks) {
                Date resulted_date = date.newinstance(child_task.CompletedDateTime__c.year(), child_task.CompletedDateTime__c.month(), child_task.CompletedDateTime__c.day());
                System.assertEquals(UserInfo.getName()+ ' ' + expected_message, child_task.Subject, 'Task subject was created incorrectly');
                System.assertEquals(Date.today(), resulted_date, 'Task CompletedDateTime was created incorrectly');
                System.assertEquals(child_task.WhatId, setup_data.TestLoan.Id, 'Should be linket to loan');
            }
            for (Task child_task : setup_data.CreatedCaseTasks) {
                if(!child_task.Subject.contains('case owner')){
                    Date resulted_date = date.newinstance(child_task.CompletedDateTime__c.year(), child_task.CompletedDateTime__c.month(), child_task.CompletedDateTime__c.day());
                    System.assertEquals(UserInfo.getName() + ' ' + expected_message, child_task.Subject, 'Task subject was created incorrectly');
                    System.assertEquals(Date.today(), resulted_date, 'Task CompletedDateTime was created incorrectly');
                    System.assertEquals(child_task.WhatId, setup_data.TestCase.Id, 'Should be linket to case');
                }
            }
            Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
            for (FeedItem child_feed : setup_data.CreatedFeedItems) {
                System.assertEquals(expected_message, child_feed.Body, 'Task subject was created incorrectly');
                System.assert(set_owner_id.contains(child_feed.ParentId), 'Should be linket to case and loan');
            }
        }
    }

    @isTest static void testRecordActionForLoanStateDeceasedWithInccorectCaseRecordType() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithIncorrectCase();
            setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestLoan.Id);
                setup_data.ClassUnderTest.insertNewTasks();
                setup_data.ClassUnderTest.insertNewFeedItems();
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            System.assertEquals(1, setup_data.CreatedLoanTasks.size(), '1 task for Loan should be created');
            System.assertEquals(0, setup_data.CreatedCaseTasks.size(), 'With incorrect record type, should not created tasks for Case');
            System.assertEquals(1, setup_data.CreatedFeedItems.size(), '1 feed item should be created');
            System.assertEquals(setup_data.TestLoan.Id, setup_data.CreatedFeedItems[0].ParentId, '1 feed item related to Loan should be created');
        }
    }

    @isTest static void testRecordActionForLoanStateDeceasedWithoutNewLogic() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithCase();
            setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestLoan.Id);
                setup_data.ClassUnderTest.insertNewTasks();
                setup_data.ClassUnderTest.insertNewFeedItems();
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            System.assertEquals(0, setup_data.CreatedLoanTasks.size(), 'With disable zcp-149, should not created tasks for Loan');
            System.assertEquals(0, setup_data.CreatedCaseTasks.size(), 'With disable zcp-149, should not created tasks for Case');
            System.assertEquals(0, setup_data.CreatedFeedItems.size(), 'With disable zcp-149, should not created chatter posts');
        }
    }

    @isTest static void testRecordActionForLoanStateCollections() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithCase();
            setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.CONFIRM_COLLECTIONS);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestCase);
                setup_data.ClassUnderTest.insertNewTasks();
                setup_data.ClassUnderTest.insertNewFeedItems();
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            String expected_message = 'changed Loan Status to "Collections"';
            for (Task child_task : setup_data.CreatedLoanTasks) {
                System.assertEquals(UserInfo.getName()+ ' ' + expected_message, child_task.Subject, 'Task subject was created incorrectly');
                System.assertEquals(child_task.WhatId, setup_data.TestLoan.Id, 'Should be linket to loan');
            }
            for (Task child_task : setup_data.CreatedCaseTasks) {
                if(!child_task.Subject.contains('case owner')){
                    System.assertEquals(UserInfo.getName() + ' ' + expected_message, child_task.Subject, 'Task subject was created incorrectly');
                    System.assertEquals(child_task.WhatId, setup_data.TestCase.Id, 'Should be linket to case');
                }
            }
            Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
            for (FeedItem child_feed : setup_data.CreatedFeedItems) {
                System.assertEquals(expected_message, child_feed.Body, 'Task subject was created incorrectly');
                System.assert(set_owner_id.contains(child_feed.ParentId), 'Should be linket to case and loan');
            }
        }
    }

    @isTest static void testRecordActionForLoanStateCollectionsWithInccorectCaseRecordType() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithIncorrectCase();
            setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.CONFIRM_COLLECTIONS);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestCase);
                setup_data.ClassUnderTest.insertNewTasks();
                setup_data.ClassUnderTest.insertNewFeedItems();
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            System.assertEquals(0, setup_data.CreatedLoanTasks.size(), 'With incorrect record type, should not created tasks for Loan');
            System.assertEquals(0, setup_data.CreatedCaseTasks.size(), 'With incorrect record type, should not created tasks for Case');
            System.assertEquals(0, setup_data.CreatedFeedItems.size(), 'With incorrect record type, should not created chatter posts');
        }
    }

    @isTest static void testRecordActionForLoanStateCollectionsWithoutNewLogic() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithCase();
            setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.CONFIRM_COLLECTIONS);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestCase);
                setup_data.ClassUnderTest.insertNewTasks();
                setup_data.ClassUnderTest.insertNewFeedItems();
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            System.assertEquals(0, setup_data.CreatedLoanTasks.size(), 'With disable zcp-149, should not created tasks for Loan');
            System.assertEquals(0, setup_data.CreatedCaseTasks.size(), 'With disable zcp-149, should not created tasks for Case');
            System.assertEquals(0, setup_data.CreatedFeedItems.size(), 'With disable zcp-149, should not created chatter posts');
        }
    }

    @isTest static void testRecordActionForLoanStateCollectionsWithDetails() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithCase();
            setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.CREATED_REPAYMENT_ARRANGEMENT, 'TestTest');
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestCase);
                setup_data.ClassUnderTest.insertNewTasks();
                setup_data.ClassUnderTest.insertNewFeedItems();
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            String expected_message = 'created Payment Plan';
            for (Task child_task : setup_data.CreatedCaseTasks) {
                if(!child_task.Subject.contains('case owner')){
                    System.assertEquals(UserInfo.getName() + ' ' + expected_message, child_task.Subject, 'Task subject was created incorrectly');
                    System.assertEquals(child_task.WhatId, setup_data.TestCase.Id, 'Should be linket to case');
                    System.assertEquals('TestTest', child_task.Description, 'Comments to task was not created correct');
                }
            }
        }
    }

    @isTest static void testRecordActionMissedRepaymentArrangementForLoanWithCase() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithCase();
            setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.MISSED_REPAYMENT_ARRANGEMENT, null, null, false);

            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestLoan.Id);
                setup_data.ClassUnderTest.insertNewTasks();
                setup_data.ClassUnderTest.insertNewFeedItems();
            Test.stopTest();

            setup_data.queryTasksAndFeedItems();
            String expected_message = 'Customer has missed a payment plan';
            System.assertEquals(1, setup_data.CreatedCaseTasks.size(), '1 task for Case should be created.');
            Task case_task = setup_data.CreatedCaseTasks[0];
            System.assertEquals(expected_message, case_task.Subject, 'Incorrect task subject.');
            System.assertEquals(null, case_task.Description, 'Task description should be null');

            System.assertEquals(1, setup_data.CreatedLoanTasks.size(), '1 task for Loan should be created.');
            Task loan_task = setup_data.CreatedLoanTasks[0];
            System.assertEquals(expected_message, loan_task.Subject, 'Incorrect task subject.');
            System.assertEquals(null, loan_task.Description, 'Task description should be null');


            Set<Id> set_owner_id = new Set<Id> {setup_data.TestCase.Id, setup_data.TestLoan.Id};
            System.assertEquals(2, setup_data.CreatedFeedItems.size(), '2 feed items should be created. For Loan and Case.');
            for (FeedItem child_feed : setup_data.CreatedFeedItems) {
                System.assertEquals(expected_message, child_feed.Body, 'Incorrect feed body.');
                System.assert(set_owner_id.contains(child_feed.ParentId), 'Should be linked to case or loan.');
            }
        }
    }

    @isTest static void testRecordActionMissedRepaymentArrangementForLoanWithoutCase() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-149');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoan();
            setup_data.initClassUnderTest(AgentActionsRecorderForCollections.Action.MISSED_REPAYMENT_ARRANGEMENT, null, null, false);

            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestLoan.Id);
                setup_data.ClassUnderTest.insertNewTasks();
                setup_data.ClassUnderTest.insertNewFeedItems();
            Test.stopTest();

            setup_data.queryTasksAndFeedItems();
            String expected_message = 'Customer has missed a payment plan';
            System.assertEquals(1, setup_data.CreatedLoanTasks.size(), '1 task for Loan should be created.');
            Task loan_task = setup_data.CreatedLoanTasks[0];
            System.assertEquals(expected_message, loan_task.Subject, 'Incorrect task subject.');
            System.assertEquals(null, loan_task.Description, 'Task description should be null');

            System.assertEquals(1, setup_data.CreatedFeedItems.size(), '1 feed item for Loan should be created.');
            FeedItem loan_feed_item = setup_data.CreatedFeedItems[0];
            System.assertEquals(expected_message, loan_feed_item.Body, 'Incorrect feed body.');
            System.assertEquals(setup_data.TestLoan.Id, loan_feed_item.ParentId, 'Should be linked to loan.');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Loan__c TestLoan;
        public Account TestAccount;
        public User TestUser;
        public AgentActionsRecorderForCollections ClassUnderTest;
        public List<Task> CreatedLoanTasks;
        public List<Task> CreatedCaseTasks;
        public List<FeedItem> CreatedFeedItems;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'AgentActionsRecorderForCollectionsTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
        }

        public void initClassUnderTest(AgentActionsRecorderForCollections.Action action_recording) {
            ClassUnderTest = AgentActionsRecorderForCollections.getInstance(action_recording);
        }

        public void initClassUnderTest(AgentActionsRecorderForCollections.Action action_recording, String description) {
            ClassUnderTest = AgentActionsRecorderForCollections.getInstance(action_recording, description);
        }

        public void initClassUnderTest(AgentActionsRecorderForCollections.Action action_recording, String description, String action_target) {
            ClassUnderTest = AgentActionsRecorderForCollections.getInstance(action_recording, description, action_target);
        }

        public void initClassUnderTest(AgentActionsRecorderForCollections.Action action_recording, String description, String action_target, Boolean add_user) {
            ClassUnderTest = AgentActionsRecorderForCollections.getInstance(action_recording, description, action_target, add_user);
        }

        public String getSubjectForAction(AgentActionsRecorderForCollections.Action action){
            return AgentActionsRecorderForCollections.SUBJECT_FOR_ACTIONS.get(action);
        }

        public void createLoan() {
            TestLoan = LoanBuilder.getBuilder(TestAccount).save().getRecord();
        }

        public void createLoanWithCase() {
            TestLoan = LoanBuilder.getBuilder(TestAccount).save().getRecord();
            TestCase = CaseBuilder.getBuilder(TestAccount).setLoan(TestLoan).setOwner(TestUser.Id).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).save().getRecord();
        }

        public void createLoanWithIncorrectCase(){
            TestLoan = LoanBuilder.getBuilder(TestAccount).save().getRecord();
            TestCase = CaseBuilder.getBuilder(TestAccount).setLoan(TestLoan).setOwner(TestUser.Id).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void queryTasksAndFeedItems() {
            CreatedLoanTasks = [SELECT Subject, WhatId, CompletedDateTime__c, Description FROM Task WHERE WhatId = :TestLoan.Id];
            if(TestCase != null) {
                CreatedCaseTasks = [SELECT Subject, WhatId, CompletedDateTime__c, Description FROM Task WHERE WhatId = :TestCase.Id];
            }
            CreatedFeedItems = [SELECT ParentId, Body FROM FeedItem];
        }
    }

    @testSetup
    static void setupTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('AgentActionsRecorderForCollectionsTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            AccountBuilder.getBuilder('AgentActionsRecorderForCollectionsTest').save();
        }
    }
}