@isTest
private class LoanActivityHistoryControllerTest {

    static testMethod void testShowAllClosedTasksCaseAndLoan() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createTeachSupportCase('Open');
            setup_data.createDoneTasksForManualUnderwritingCase(15);
            setup_data.createDoneTasksForTeachSupportCase(15);
            setup_data.createDoneTasksToLoan(10);
            setup_data.createOpenTasksForManualUnderwritingCase(5);
            setup_data.createOpenTasksForTeachSupportCase(5);
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assertEquals(40, setup_data.ClassUnderTest.ClosedTasks.size(), 'Should show only closed tasks');
        }
    }

    static testMethod void testShowAllClosedTasksAndEvent() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createDoneTasksForManualUnderwritingCase(15);
            setup_data.createDoneTasksForManualUnderwritingCaseWithCopyForCase(15);
            setup_data.createDoneTasksToLoan(10);
            setup_data.createFutureEvents(15);
            setup_data.createPastEvents(10);
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assertEquals(35, setup_data.ClassUnderTest.ClosedTasks.size(), 'Should show only closed tasks and post events');
        }
    }

    static testMethod void testGetHasWorkWithTasksSectionPermissions() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initComponent();
            Test.startTest();
                Boolean has_permissions = setup_data.ClassUnderTest.getHasWorkWithTasksSectionPermissions();
            Test.stopTest();
            System.assertEquals(true, has_permissions, 'Case prep should have this permissions');
        }
    }

    static testMethod void testShowMoreElements() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createDoneTasksForManualUnderwritingCase(23);
            setup_data.initComponent();
            Test.startTest();
                setup_data.ClassUnderTest.showMoreElements();
            Test.stopTest();
            System.assertEquals(10, setup_data.ClassUnderTest.ShowElementsInPage, 'Should show 10 tasks');
        }
    }

    static testMethod void testShowAllElements() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createDoneTasksForManualUnderwritingCase(23);
            setup_data.initComponent();
            Test.startTest();
                setup_data.ClassUnderTest.showAllElements();
            Test.stopTest();
            System.assertEquals(23, setup_data.ClassUnderTest.ShowElementsInPage, 'Should show all tasks');
        }
    }

    static testMethod void testRefreshEmailCompletedDate() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createDoneTasksWithSubjectForManualUnderwritingCase(1, 'Email');
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assertEquals(false, String.isEmpty(setup_data.ClassUnderTest.ClosedTasks[0].DueDate), 'Should be false');
        }
    }

    static testMethod void testDeleteTask() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createDoneTasksForManualUnderwritingCase(2);
            setup_data.initComponent();
            setup_data.ClassUnderTest.SelectedTaskId = setup_data.getAllTasksForCase(setup_data.TestManualUnderwritingCase)[0].Id;
            Test.startTest();
                setup_data.ClassUnderTest.deleteTask();
            Test.stopTest();
            System.assertEquals(1, setup_data.getAllTasksForCase(setup_data.TestManualUnderwritingCase).size(), 'Should delete one task');
        }
    }

    static testMethod void testRefreshEmailCompletedDateNoSubject() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createDoneTasksForManualUnderwritingCase(1);
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assertEquals(true, String.isEmpty(setup_data.ClassUnderTest.ClosedTasks[0].DueDate), 'Should be true');
        }
    }

    private class SetupDataClass {
        public Case TestManualUnderwritingCase;
        public Case TestTeachSupportCase;
        public LoanActivityHistoryController ClassUnderTest;
        public User TestUser;
        public Loan_Application__c TestLoanApplication;
        public Account TestAccount;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TeamLeader' LIMIT 1];
            TestAccount = AccountBuilder.getBuilder('TeamLeader').save().getRecord();
            TestLoanApplication = LoanApplicationBuilder.getBuilder(TestAccount).setExternalId('test').save().getRecord();
        }

        public void createManualUnderwritingCase(string status) {
            TestManualUnderwritingCase = CaseBuilder.getBuilder(TestAccount).setStatus(status).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createTeachSupportCase(string status) {
            TestTeachSupportCase = CaseBuilder.getBuilder(TestAccount).setLoanApplication(TestLoanApplication).setStatus(status).setRecordType(RecordTypeUtility.CASE_TECH_SUPPORT).save().getRecord();
        }

        public void createOpenTasksForManualUnderwritingCase(Integer num_of_tasks) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestManualUnderwritingCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setStatus('Open').getRecordList(num_of_tasks);
        }

        public void createDoneTasksForManualUnderwritingCase(Integer num_of_tasks) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestManualUnderwritingCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setStatus('Completed').getRecordList(num_of_tasks);
        }

        public void createDoneTasksForManualUnderwritingCaseWithCopyForCase(Integer num_of_tasks) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestManualUnderwritingCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setStatus('Completed').setCopyForCase(true).getRecordList(num_of_tasks);
        }

        public void createDoneTasksWithSubjectForManualUnderwritingCase(Integer num_of_tasks, String task_subject) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestManualUnderwritingCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setSubject(task_subject).setStatus('Completed').getRecordList(num_of_tasks);
        }

        public void createOpenTasksForTeachSupportCase(Integer num_of_tasks) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestTeachSupportCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setStatus('Open').getRecordList(num_of_tasks);
        }

        public void createDoneTasksForTeachSupportCase(Integer num_of_tasks) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestTeachSupportCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setStatus('Completed').getRecordList(num_of_tasks);
        }

        public void createDoneTasksToLoan(Integer num_of_tasks) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestLoanApplication.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setStatus('Completed').getRecordList(num_of_tasks);
        }

        public List<Task> getAllTasksForCase(Case task_case){
            return [SELECT Id FROM Task WHERE What.Id =:task_case.Id];
        }

        public void createFutureEvents(Integer num_of_events) {
            List<Event> events = new List<Event>();
            for (Integer i=0; i<num_of_events; i++) {
                events.add(new Event(Subject = 'test', WhatId = TestManualUnderwritingCase.Id, StartDateTime = Date.today().addDays(2), EndDateTime = Date.today().addDays(3)));
            }
            insert events;
        }

        public void createPastEvents(Integer num_of_events) {
            List<Event> events = new List<Event>();
            for (Integer i=0; i<num_of_events; i++) {
                events.add(new Event(Subject = 'test', WhatId = TestManualUnderwritingCase.Id, StartDateTime = Date.today().addDays(-3), EndDateTime = Date.today().addDays(-2)));
            }
            insert events;
        }

        public void initComponent() {
            ClassUnderTest = new LoanActivityHistoryController();
            ClassUnderTest.LoanApplicationId = TestLoanApplication.Id;
        }

    }

    @testSetup
    static void setupTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.TEAM_LEADER)
                                     .setFirstName('TeamLeader')
                                     .setLastName('TeamLeader')
                                     .save().getRecord();
    }
}