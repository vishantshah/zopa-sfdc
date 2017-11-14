@isTest
public class SmartActivitiesSectionControllerTest {
    private static final String CASE_PREP_USER = 'SmartActivitiesCasePrep';
    private static final String FRAUD_USER = 'SmartActivitiesFraud';
    private static final String UNDERWRITER_USER = 'SmartActivitiesUnderwriting';
    private static final String TEAM_LEADER_USER = 'SmartActivitiesTeamLeader';
    private static final List<String> NEW_TASKS_SUBJECTS = new List<String>{'test', 'test2'};

    static testMethod void testSmartActivitiesSectionInitComponentAttribute() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.RelatedCase.Id, 'Should be initialized by appropriate case');
            System.assert(setup_data.ClassUnderTest.QueryOpenTasks.contains('FROM Task WHERE What.Id = \'' + setup_data.TestCase.Id + '\' AND isClosed = false AND (Task_For__c = \'Case-Prep\' OR Task_For__c = null)'),
                                                            'Should have clause for case and current profile and open tasks');
            System.assert(setup_data.ClassUnderTest.QueryClosedTasks.contains('FROM Task WHERE What.Id = \'' + setup_data.TestCase.Id + '\' AND isClosed = true AND (Task_For__c = \'Case-Prep\' OR Task_For__c = null)'),
                                                            'Should have clause for case and current profile and closed tasks');
            System.assert(setup_data.ClassUnderTest.QueryFututeEvents.contains('FROM Event WHERE What.Id = \'' + setup_data.TestCase.Id + '\' AND StartDateTime >= TODAY ORDER BY ActivityDate DESC'),
                                                            'Should have clause for start date and sort order');
            System.assert(setup_data.ClassUnderTest.QueryPastEvents.contains('FROM Event WHERE What.Id = \'' + setup_data.TestCase.Id + '\' AND StartDateTime < TODAY ORDER BY ActivityDate DESC'),
                                                            'Should have clause for start date and sort order');
            System.assert(setup_data.ClassUnderTest.ClosedTasks.size() == 0, 'ClosedTasks should be initialized by empty list without tasks');
            System.assert(setup_data.ClassUnderTest.OpenTasks.size() == 0, 'OpenTasks should be initialized by empty list without tasks');
        }
    }

    static testMethod void testSmartActivitiesSectionInitComponentAttributeCasePrepCanSeeTasksAndEvents() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.createDoneTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.createFutureEvents(3);
            setup_data.createPastEvents(3);
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assertEquals(6, setup_data.ClassUnderTest.ClosedTasks.size(), 'ClosedTasks should contain only Case-Prep tasks');
            System.assertEquals(6, setup_data.ClassUnderTest.OpenTasks.size(), 'OpenTasks should contain open tasks and future events');
        }
    }

    static testMethod void testSmartActivitiesSectionInitComponentAttributeCasePrepCanNotSeeUnderwriterTasks() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Underwriter');
            setup_data.createDoneTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.createDoneTasksWithSpecificTaskFor(3, 'Underwriter');
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assert(setup_data.ClassUnderTest.ClosedTasks.size() == 3, 'ClosedTasks should contain only Case-Prep tasks');
            System.assert(setup_data.ClassUnderTest.OpenTasks.size() == 3, 'OpenTasks should contain only Case-Prep tasks');
        }
    }

    static testMethod void testSmartActivitiesSectionInitComponentAttributeUnderwriterCanSeeUnderwriterAndCasePrepTasks() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Underwriter');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Fraud');
            setup_data.createDoneTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.createDoneTasksWithSpecificTaskFor(3, 'Underwriter');
            setup_data.createDoneTasksWithSpecificTaskFor(3, 'Fraud');
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assert(setup_data.ClassUnderTest.ClosedTasks.size() == 6, 'ClosedTasks should contain only Case-Prep and Underwriter tasks');
            System.assert(setup_data.ClassUnderTest.OpenTasks.size() == 6, 'OpenTasks should contain only Case-Prep and Underwriter tasks');
        }
    }

    static testMethod void testSmartActivitiesSectionInitComponentAttributeFraudCanSeeAllTasks() {
        SetupDataClass setup_data = new SetupDataClass(FRAUD_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Underwriter');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Fraud');
            setup_data.createDoneTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.createDoneTasksWithSpecificTaskFor(3, 'Underwriter');
            setup_data.createDoneTasksWithSpecificTaskFor(3, 'Fraud');
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assert(setup_data.ClassUnderTest.ClosedTasks.size() == 9, 'ClosedTasks should contain all tasks');
            System.assert(setup_data.ClassUnderTest.OpenTasks.size() == 9, 'OpenTasks should contain all tasks');
        }
    }

    static testMethod void testGetButtonsUpdatingStatusReturnFourStatuses() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initComponent();
            Test.startTest();
                List<String> mass_updating_for_statuses = setup_data.ClassUnderTest.getButtonsUpdatingStatus();
            Test.stopTest();
            System.assertEquals(new List<String> {'Completed', 'Rejected', 'Pending'}, mass_updating_for_statuses,
                                                                'Should return 3 statuses for buttons in correct order');
        }
    }

    static testMethod void testUpdateSelectedTasksComments(){
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.initComponent();
            List<Task> task_for_uptade = new List<Task>();
            for(SmartActivitiesSectionController.ActivityWrapper open_task : setup_data.updateCommentsInActivityWrappers('', setup_data.ClassUnderTest.OpenTasks)){
                task_for_uptade.add(open_task.TaskRecord);
            }

            Test.startTest();
                List<Task> updated_tasks = setup_data.ClassUnderTest.updateSelectedTasksComments(task_for_uptade);
            Test.stopTest();

            for(Task updated_task : updated_tasks){
                System.assertEquals('', updated_task.Description, 'Comment was not updated on case');
            }
        }
    }

    static testMethod void testUpdateSelectedTasksWithSpecificStatusMessageSuccess() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.initComponent();
            setup_data.markOpenTasksAsSelected(2);
            setup_data.setMassEditStatus('Completed');
            Test.startTest();
                setup_data.ClassUnderTest.updateSelectedTasksWithSpecificStatus();
            Test.stopTest();
            System.assertEquals(2, setup_data.getNumberOfTasksWithActivityDateTimeToday(), 'Should update ActivityDate to now if task was updated by test user');
            System.assertEquals(2, setup_data.getNumberOfTasksWithCurentUserAsOwnerByStatus('Completed'), 'Should update task assigned to test user');
            System.assertEquals(2, setup_data.getNumberOfTasksWithStatus('Completed'), 'Should update task to status Completed');
            setup_data.assertPageMessageOpen('Tasks were successfully updated');
        }
    }

    static testMethod void testUpdateSelectedTasksWithSpecificStatusMessageWarningNoSelectedTasks() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.initComponent();
            setup_data.setMassEditStatus('Completed');
            Test.startTest();
                setup_data.ClassUnderTest.updateSelectedTasksWithSpecificStatus();
            Test.stopTest();
            System.assertEquals(0, setup_data.getNumberOfTasksWithStatus('Completed'), 'Shouldn\'t be tasks with status Completed');
            setup_data.assertPageMessageOpen('No tasks are selected');
        }
    }

    static testMethod void testUpdateSelectedTasksWithSpecificStatusMessageSuccessDateNotUpdated() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.initComponent();
            setup_data.markOpenTasksAsSelected(2);
            setup_data.setMassEditStatus('Pending');
            Test.startTest();
                setup_data.ClassUnderTest.updateSelectedTasksWithSpecificStatus();
            Test.stopTest();
            System.assertEquals(0, setup_data.getNumberOfTasksWithActivityDateTimeToday(), 'Should NOT update ActivityDate to now if task was updated by test user to status Pending');
            System.assertEquals(2, setup_data.getNumberOfTasksWithCurentUserAsOwnerByStatus('Pending'), 'Should update task assigned to test user');
            System.assertEquals(2, setup_data.getNumberOfTasksWithStatus('Pending'), 'Should update task to status Pending');
            setup_data.assertPageMessageOpen('Tasks were successfully updated');
        }
    }

    static testMethod void testUndoneChosenTaskMessageSuccess() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createDoneTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.initComponent();
            setup_data.setIdTaskToUndoForFirstRecordInList();
            Test.startTest();
                setup_data.ClassUnderTest.undoneChosenTask();
            Test.stopTest();
            System.assertEquals(1, setup_data.getNumberOfTasksWithCurentUserAsOwnerByStatus('Open'), 'Should update task assigned to test user');
            System.assertEquals(1, setup_data.getNumberOfTasksWithStatus('Open'), 'Should be one task with status open');
            setup_data.assertPageMessageOpen('Tasks were successfully updated');
        }
    }

    static testMethod void testGetHasWorkWithTasksSectionPermissions() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.initComponent();
            Test.startTest();
                Boolean has_permissions = setup_data.ClassUnderTest.getHasWorkWithTasksSectionPermissions();
            Test.stopTest();
            System.assertEquals(true, has_permissions, 'Case prep should have this permissions');
        }
    }

    static testMethod void testNewTaskOpenPopup() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.initComponent();
            Test.startTest();
                PageReference page = setup_data.ClassUnderTest.newTask();
            Test.stopTest();
            System.assertEquals(null, page, 'No redirect');
            System.assertEquals(new Task(), setup_data.ClassUnderTest.NewMUTask, 'Open popup');
        }
    }

    static testMethod void testSaveMUTask() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.initComponent();
            setup_data.ClassUnderTest.newTask();
            setup_data.ClassUnderTest.NewMUTask.Subject = 'test';
            Test.startTest();
                setup_data.ClassUnderTest.saveMUTask();
            Test.stopTest();
            setup_data.queryTestTasks();
            System.assertEquals(1, setup_data.TestTasks.size(), 'Should create one task');
            System.assertEquals('test', setup_data.TestTasks.get(0).Subject, 'Should set subject');
            System.assertEquals('Open', setup_data.TestTasks.get(0).Status, 'Should set open status');
        }
    }

    static testMethod void testHideMUTaskPopup() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.initComponent();
            setup_data.ClassUnderTest.newTask();
            Test.startTest();
                setup_data.ClassUnderTest.hideNewTaskPopup();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.NewMUTask, 'Hidden popup');
        }
    }

    static testMethod void testGetMUTaskSubjects() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.initComponent();
            setup_data.createMUTasksSubjectsCS();
            Test.startTest();
                List<SelectOption> options = setup_data.ClassUnderTest.getMUTaskSubjects();
            Test.stopTest();
            System.assertEquals(setup_data.getExpectedMUTasksSubjects(), options, 'Should return expected options');
        }
    }

    static testMethod void testGetIsCaseNotBlockedOpenCase() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-17');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.reQueryTestCase();
            setup_data.initComponent();
            Test.startTest();
                Boolean is_not_blocked = setup_data.ClassUnderTest.getIsCaseNotClosed();
            Test.stopTest();
            System.assertEquals(true, is_not_blocked, 'Open case should not be blocked for Case Prep');
        }
    }

    static testMethod void testGetIsCaseNotBlockedClosedCase() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.enable('ZOPA-17');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Closed - Auto Approved');
            setup_data.reQueryTestCase();
            setup_data.initComponent();
            Test.startTest();
                Boolean is_not_blocked = setup_data.ClassUnderTest.getIsCaseNotClosed();
            Test.stopTest();
            System.assertEquals(false, is_not_blocked, 'Closed case should be blocked for Case Prep');
        }
    }

    static testMethod void testGetIsCaseNotBlockedClosedCaseDisabledZopa17() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        FeatureSwitch.disable('ZOPA-17');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Closed - Auto Approved');
            setup_data.reQueryTestCase();
            setup_data.initComponent();
            Test.startTest();
                Boolean is_not_blocked = setup_data.ClassUnderTest.getIsCaseNotClosed();
            Test.stopTest();
            System.assertEquals(true, is_not_blocked, 'Closed case should not be blocked if disable FeatureSwitch');
        }
    }

    static testMethod void testRefreshEmailCompletedDate() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Closed - Auto Approved');
            setup_data.createDoneTasksWithSubject(1, 'Email');
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assertEquals(false, String.isEmpty(setup_data.ClassUnderTest.ClosedTasks[0].DueDate), 'Should be false');
        }
    }

    static testMethod void testRefreshEmailCompletedDateNoSubject() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Closed - Auto Approved');
            setup_data.createDoneTasksNoSubject(1);
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assertEquals(true, String.isEmpty(setup_data.ClassUnderTest.ClosedTasks[0].DueDate), 'Should be true');
        }
    }

    static testMethod void testSavingCommentsOpenTasks() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.initComponent();
            setup_data.updateCommentsInActivityWrappers('teeeeest', setup_data.ClassUnderTest.OpenTasks);

            Test.startTest();
                setup_data.ClassUnderTest.saveCommentsOpenTasks();
            Test.stopTest();

            List<Task> updated_tasks = [SELECT Description FROM Task];
            for(Task updated_task : updated_tasks){
                System.assertEquals('teeeeest', updated_task.Description, 'Comment was not updated on case');
            }
        }
    }

    static testMethod void testSavingCommentsClosedTasks() {
        SetupDataClass setup_data = new SetupDataClass(UNDERWRITER_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createDoneTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.initComponent();
            setup_data.ClassUnderTest.ClosedTasks = setup_data.updateCommentsInActivityWrappers('teeeeest', setup_data.ClassUnderTest.ClosedTasks);

            Test.startTest();
                setup_data.ClassUnderTest.saveCommentsClosedTasks();
            Test.stopTest();

            List<Task> updated_tasks = [SELECT Description FROM Task];
            for(Task updated_task : updated_tasks){
                System.assertEquals('teeeeest', updated_task.Description, 'Comment was not updated on case');
            }
        }
    }

    static testMethod void testUpdateSelectedTasksWithSpecificStatusMessageSuccessWhenAreEvents() {
        SetupDataClass setup_data = new SetupDataClass(CASE_PREP_USER);
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase('Open');
            setup_data.createFutureEvents(2);
            setup_data.createOpenTasksWithSpecificTaskFor(3, 'Case-Prep');
            setup_data.initComponent();
            setup_data.markOpenTasksAsSelected(setup_data.ClassUnderTest.OpenTasks.size());
            setup_data.setMassEditStatus('Completed');
            Test.startTest();
                setup_data.ClassUnderTest.updateSelectedTasksWithSpecificStatus();
            Test.stopTest();
            setup_data.assertPageMessageOpen('Tasks were successfully updated');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Account TestAccount;
        public SmartActivitiesSectionController ClassUnderTest;
        public User TestUser;
        public List<Task> TestTasks;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        public void createManualUnderwritingCase(string status) {
            FeatureSwitch.disable('ZOPA-18');
            Account test_account = AccountBuilder.getBuilder('SmartActivitiesSectionController').save().getRecord();
            TestCase = CaseBuilder.getBuilder(test_account).setStatus(status).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createOpenTasksWithSpecificTaskFor(Integer num_of_tasks, String task_for) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setTaskFor(task_for).setStatus('Open').getRecordList(num_of_tasks);
        }

        public void createDoneTasksWithSubject(Integer num_of_tasks, String task_subject) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setSubject(task_subject).setStatus('Completed').getRecordList(num_of_tasks);
        }

        public void createDoneTasksNoSubject(Integer num_of_tasks) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setStatus('Completed').getRecordList(num_of_tasks);
        }

        public void createDoneTasksWithSpecificTaskFor(Integer num_of_tasks, String task_for) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                                    .setTaskFor(task_for).setStatus('Completed').getRecordList(num_of_tasks);
        }

        public List<SmartActivitiesSectionController.ActivityWrapper> updateCommentsInActivityWrappers(String comment, List<SmartActivitiesSectionController.ActivityWrapper> wrappers){
            for(SmartActivitiesSectionController.ActivityWrapper wrapper : wrappers){
                wrapper.Comment = comment;
                wrapper.IsTask = true;
                wrapper.ShowComment = true;
                wrapper.CanBeUndone = true;
            }
            return wrappers;
        }

        public void createFutureEvents(Integer num_of_events) {
            List<Event> events = new List<Event>();
            for (Integer i=0; i<num_of_events; i++) {
                events.add(new Event(Subject = 'test', WhatId = TestCase.Id, StartDateTime = Date.today().addDays(2), EndDateTime = Date.today().addDays(3)));
            }
            insert events;
        }

        public void createPastEvents(Integer num_of_events) {
            List<Event> events = new List<Event>();
            for (Integer i=0; i<num_of_events; i++) {
                events.add(new Event(Subject = 'test', WhatId = TestCase.Id, StartDateTime = Date.today().addDays(-3), EndDateTime = Date.today().addDays(-2)));
            }
            insert events;
        }

        public void initComponent() {
            ClassUnderTest = new SmartActivitiesSectionController();
            ClassUnderTest.RelatedCase = TestCase;
        }

        public void markOpenTasksAsSelected(Integer number_of_selected_tasks) {
            for (Integer i = 0; i<number_of_selected_tasks; i++) {
                if(ClassUnderTest.OpenTasks.get(i).IsTask){
                    ClassUnderTest.OpenTasks.get(i).IsSelected = true;
                }
            }
        }

        public void setMassEditStatus(String status) {
            ClassUnderTest.MassEditStatus = status;
        }

        public void setIdTaskToUndoForFirstRecordInList() {
            ClassUnderTest.IdTaskToUndo = ClassUnderTest.ClosedTasks.get(0).getRecord().Id;
        }

        public Integer getNumberOfTasksWithStatus(String status) {
            return [SELECT count() FROM Task WHERE Status = :status];
        }

        public Integer getNumberOfTasksWithCurentUserAsOwnerByStatus(String status) {
            return [SELECT count() FROM Task WHERE OwnerId = :UserInfo.getUserId() AND Status = :status];
        }

        public Integer getNumberOfTasksWithActivityDateTimeToday() {
            return [SELECT count() FROM Task WHERE OwnerId = :UserInfo.getUserId() AND CompletedDateTime__c = TODAY];
        }

        public void assertPageMessageOpen(String message) {
            System.assertEquals(message, ClassUnderTest.MessageHandlerOpenTasks.Summary, 'Page message assert failed');
        }

        public void assertPageMessageClosed(String message) {
            System.assertEquals(message, ClassUnderTest.MessageHandlerClosedTasks.Summary, 'Page message assert failed');
        }

        public void reQueryTestCase() {
            TestCase = [SELECT IsClosed, ContactId, Status FROM Case WHERE Id = : TestCase.Id];
        }

        public void queryTestTasks() {
            TestTasks = [SELECT Subject, Status FROM Task WHERE WhatId = :TestCase.Id];
        }

        public void createMUTasksSubjectsCS() {
            List<Manual_Underwriting_Task_Subjects__c> subject_settings = new List<Manual_Underwriting_Task_Subjects__c>();
            for (String subject : NEW_TASKS_SUBJECTS) {
                subject_settings.add(new Manual_Underwriting_Task_Subjects__c(Name = subject, Task_Subject__c = subject));
            }
            insert subject_settings;
        }

        public List<SelectOption> getExpectedMUTasksSubjects() {
            List<SelectOption> options = new List<SelectOption>();
            for (String subject : NEW_TASKS_SUBJECTS) {
                options.add(new SelectOption(subject, subject));
            }
            return options;
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('SmartActivitiesCasePrep'+Utility.getRandomInteger())
                                     .setLastName('SmartActivitiesCasePrep')
                                     .save();
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                                     .setFirstName('SmartActivitiesCasePrep'+Utility.getRandomInteger())
                                     .setLastName('SmartActivitiesUnderwriting')
                                     .save();
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.FRAUD)
                                     .setFirstName('SmartActivitiesCasePrep'+Utility.getRandomInteger())
                                     .setLastName('SmartActivitiesFraud')
                                     .save();
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.TEAM_LEADER)
                                     .setFirstName('SmartActivitiesCasePrep'+Utility.getRandomInteger())
                                     .setLastName('SmartActivitiesTeamLeader')
                                     .save();
    }
}