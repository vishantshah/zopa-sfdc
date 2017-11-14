@isTest
private class AgentActionsRecorderTest {

    @isTest static void testRecordActionForLoanDeclineLoan() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithCase();
            setup_data.initClassUnderTest(AgentActionsRecorder.Action.DECLINE_LOAN);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestLoanApplication.Id);
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            String expected_message_for_decline_feed = 'declined the loan application';
            for (Task child_task : setup_data.CreatedLoanTasks) {
                Date resulted_date = date.newinstance(child_task.CompletedDateTime__c.year(), child_task.CompletedDateTime__c.month(), child_task.CompletedDateTime__c.day());
                System.assertEquals(UserInfo.getName()+ ' ' + expected_message_for_decline_feed, child_task.Subject, 'Task subject was created incorrectly');
                System.assertEquals(Date.today(), resulted_date, 'Task CompletedDateTime was created incorrectly');
                System.assertEquals(child_task.WhatId, setup_data.TestLoanApplication.Id, 'Should be linket to loan');
            }
            for (Task child_task : setup_data.CreatedCaseTasks) {
                if(!child_task.Subject.contains('case owner')){
                    Date resulted_date = date.newinstance(child_task.CompletedDateTime__c.year(), child_task.CompletedDateTime__c.month(), child_task.CompletedDateTime__c.day());
                    System.assertEquals(UserInfo.getName() + ' ' + expected_message_for_decline_feed, child_task.Subject, 'Task subject was created incorrectly');
                    System.assertEquals(Date.today(), resulted_date, 'Task CompletedDateTime was created incorrectly');
                    System.assertEquals(child_task.WhatId, setup_data.TestCase.Id, 'Should be linket to case');
                }
            }
            for (FeedItem child_feed : setup_data.CreatedCaseFeedItems) {
                System.assertEquals(expected_message_for_decline_feed, child_feed.Body, 'Task subject was created incorrectly');
                System.assertEquals(child_feed.ParentId, setup_data.TestCase.Id, 'Should be linket to case');
            }
        }
    }

    @isTest static void testRecordActionForCaseCancelLoan() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithCase();
            setup_data.initClassUnderTest(AgentActionsRecorder.Action.CANCEL_LOAN);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestCase);
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            String expected_message_for_decline_feed = 'cancelled the loan application';
            for (Task child_task : setup_data.CreatedLoanTasks) {
                System.assertEquals(UserInfo.getName()+ ' ' + expected_message_for_decline_feed, child_task.Subject, 'Task subject was created incorrectly');
                System.assertEquals(child_task.WhatId, setup_data.TestLoanApplication.Id, 'Should be linket to loan');
            }
            for (Task child_task : setup_data.CreatedCaseTasks) {
                if(!child_task.Subject.contains('case owner')){
                    System.assertEquals(UserInfo.getName() + ' ' + expected_message_for_decline_feed, child_task.Subject, 'Task subject was created incorrectly');
                    System.assertEquals(child_task.WhatId, setup_data.TestCase.Id, 'Should be linket to case');
                }
            }
            for (FeedItem child_feed : setup_data.CreatedCaseFeedItems) {
                System.assertEquals(expected_message_for_decline_feed, child_feed.Body, 'Task subject was created incorrectly');
                System.assertEquals(child_feed.ParentId, setup_data.TestCase.Id, 'Should be linket to case');
            }
        }
    }

    @isTest static void testRecordActionForBulkCasesQuickPay() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoansWithCases(5);
            setup_data.initClassUnderTest(AgentActionsRecorder.Action.MAKE_QUICK_PAY);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestCases);
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            String expected_message_for_decline_feed = 'made the loan application quick pay';
            for (Task child_task : setup_data.CreatedLoanTasks) {
                System.assertEquals(UserInfo.getName()+ ' ' + expected_message_for_decline_feed, child_task.Subject, 'Task subject was created incorrectly');
                System.assert(new Map<Id, SObject>(setup_data.TestLoanApplications).keySet().contains(child_task.WhatId), 'Should be linket to loan');
            }
            for (Task child_task : setup_data.CreatedCaseTasks) {
                if(!child_task.Subject.contains('case owner')){
                    System.assertEquals(UserInfo.getName() + ' ' + expected_message_for_decline_feed, child_task.Subject, 'Task subject was created incorrectly');
                    System.assert(new Map<Id, SObject>(setup_data.TestCases).keySet().contains(child_task.WhatId), 'Should be linket to case');
                }
            }
            for (FeedItem child_feed : setup_data.CreatedCaseFeedItems) {
                System.assertEquals(expected_message_for_decline_feed, child_feed.Body, 'Task subject was created incorrectly');
                System.assert(new Map<Id, SObject>(setup_data.TestCases).keySet().contains(child_feed.ParentId), 'Should be linket to case');
            }
        }
    }

    @isTest static void testRecordActionForCaseAutoCancelLoan() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithCase();
            setup_data.initClassUnderTest(AgentActionsRecorder.Action.AUTO_CANCEL);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestCase);
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            String expected_message_for_decline_feed = 'has automatically auto cancelled the loan application';
            for (Task child_task : setup_data.CreatedLoanTasks) {
                System.assertEquals('System ' + expected_message_for_decline_feed, child_task.Subject, 'Task subject was created incorrectly');
                System.assertEquals(child_task.WhatId, setup_data.TestLoanApplication.Id, 'Should be linket to loan');
            }
            for (Task child_task : setup_data.CreatedCaseTasks) {
                if(!child_task.Subject.contains('case owner')){
                    System.assertEquals('System ' + expected_message_for_decline_feed, child_task.Subject, 'Task subject was created incorrectly');
                    System.assertEquals(child_task.WhatId, setup_data.TestCase.Id, 'Should be linket to case');
                }
            }
            for (FeedItem child_feed : setup_data.CreatedCaseFeedItems) {
                System.assertEquals(expected_message_for_decline_feed, child_feed.Body, 'Task subject was created incorrectly');
                System.assertEquals(child_feed.ParentId, setup_data.TestCase.Id, 'Should be linket to case');
            }
        }
    }

    @isTest static void testRecordActionForCaseAutoCancelLoanDisableFS() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithCase();
            setup_data.initClassUnderTest(AgentActionsRecorder.Action.AUTO_CANCEL);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestCase);
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            System.assertEquals(0, setup_data.CreatedLoanTasks.size(), 'Should not create records');
            System.assertEquals(1, setup_data.CreatedCaseTasks.size(), 'Should create 1 records');
            System.assertEquals(0, setup_data.CreatedCaseFeedItems.size(), 'Should not create records');
        }
    }

    @isTest static void testRecordActionForBulkCasesQuickPayDisableFS() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoansWithCases(5);
            setup_data.initClassUnderTest(AgentActionsRecorder.Action.MAKE_QUICK_PAY);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestCases);
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            System.assertEquals(0, setup_data.CreatedLoanTasks.size(), 'Should not create records');
            System.assertEquals(5, setup_data.CreatedCaseTasks.size(), 'Should create 5 records');
            System.assertEquals(0, setup_data.CreatedCaseFeedItems.size(), 'Should not create records');
        }
    }

    @isTest static void testRecordActionForLoanDeclineLoanDisableFS() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-89');
        System.runAs(setup_data.TestUser) {
            setup_data.createLoanWithCase();
            setup_data.initClassUnderTest(AgentActionsRecorder.Action.DECLINE_LOAN);
            Test.startTest();
                setup_data.ClassUnderTest.record(setup_data.TestLoanApplication.Id);
            Test.stopTest();
            setup_data.queryTasksAndFeedItems();
            System.assertEquals(0, setup_data.CreatedLoanTasks.size(), 'Should not create records');
            System.assertEquals(1, setup_data.CreatedCaseTasks.size(), 'Should create 1 records');
            System.assertEquals(0, setup_data.CreatedCaseFeedItems.size(), 'Should not create records');
        }
    }

    private class SetupDataClass {
        public List<Case> TestCases;
        public Case TestCase;
        public List<Loan_Application__c> TestLoanApplications;
        public Loan_Application__c TestLoanApplication;
        public Account TestAccount;
        public User TestUser;
        public AgentActionsRecorder ClassUnderTest;
        public List<Task> CreatedLoanTasks;
        public List<Task> CreatedCaseTasks;
        public List<FeedItem> CreatedCaseFeedItems;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'AgentActionsRecorderTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
        }

        public void initClassUnderTest(AgentActionsRecorder.Action action_recording) {
            ClassUnderTest = AgentActionsRecorder.getInstance(action_recording);
        }

        public void createLoanWithCase() {
            FeatureSwitch.enable('ZOPA-4');
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus('RequiresManualUnderwriting').setTriggeredReferralCodes('test').save().getRecord();
            TestCase = [SELECT Id, Loan_Application__c FROM Case LIMIT 1];
        }

        public void createLoansWithCases(Integer records_number) {
            FeatureSwitch.enable('ZOPA-4');
            TestLoanApplications = LoanApplicationBuilder.getBuilder(TestAccount).setApplicationStatus('RequiresManualUnderwriting').setTriggeredReferralCodes('test').getRecordList(records_number);
            insert TestLoanApplications;
            queryCases();
        }

        public void queryCases() {
            TestCases = [SELECT Id, Loan_Application__c FROM Case];
        }

        public void queryTasksAndFeedItems() {
            if (TestLoanApplication != null) {
                CreatedLoanTasks = [SELECT Subject, WhatId,CompletedDateTime__c FROM Task WHERE TaskSubtype = 'Email' AND Status = 'Completed' AND WhatId = :TestLoanApplication.Id];
                CreatedCaseTasks = [SELECT Subject, WhatId,CompletedDateTime__c FROM Task WHERE TaskSubtype = 'Email' AND Status = 'Completed' AND WhatId = :Testcase.Id];
            } else {
                CreatedLoanTasks = [SELECT Subject, WhatId,CompletedDateTime__c FROM Task WHERE TaskSubtype = 'Email' AND Status = 'Completed' AND WhatId IN :new Map<Id, SObject>(TestLoanApplications).keySet()];
                CreatedCaseTasks = [SELECT Subject, WhatId,CompletedDateTime__c FROM Task WHERE TaskSubtype = 'Email' AND Status = 'Completed' AND WhatId IN :new Map<Id, SObject>(TestCases).keySet()];
            }
            CreatedCaseFeedItems = [SELECT ParentId, Body FROM FeedItem];
        }
    }

    @testSetup
    static void setupTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('AgentActionsRecorderTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            AccountBuilder.getBuilder('AgentActionsRecorderTest').save();
        }
    }
}