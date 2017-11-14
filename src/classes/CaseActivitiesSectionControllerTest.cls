@isTest
public class CaseActivitiesSectionControllerTest {
    private static final String SYSADMIN = 'CaseViewSysAdmin';
    private static final List<String> NEW_TASKS_SUBJECTS = new List<String>{'test', 'test2'};

    static testMethod void testCaseActivitiesSectionInitComponentAttribute() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assertEquals(setup_data.TestCase.Id, setup_data.ClassUnderTest.RelatedCase.Id, 'Should be initialized by appropriate case');
            System.assert(setup_data.ClassUnderTest.QueryOpenTasks.contains('FROM Task WHERE What.Id = \'' + setup_data.TestCase.Id + '\' AND isClosed = false'),
                                                            'Should have clause for case and current profile and open tasks');
            System.assert(setup_data.ClassUnderTest.QueryClosedTasks.contains('FROM Task WHERE What.Id = \'' + setup_data.TestCase.Id + '\' AND isClosed = true'),
                                                            'Should have clause for case and current profile and closed tasks');
            System.assert(setup_data.ClassUnderTest.ClosedTasks.size() == 0, 'ClosedTasks should be initialized by empty list without tasks');
            System.assert(setup_data.ClassUnderTest.OpenTasks.size() == 0, 'OpenTasks should be initialized by empty list without tasks');
        }
    }

    static testMethod void testCaseActivitiesSectionInitComponentAttributeCasePrepCanSeeTasksAndEvents() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3);
            setup_data.createDoneTasksWithSpecificTaskFor(3);
            Test.startTest();
                setup_data.initComponent();
            Test.stopTest();
            System.assertEquals(3, setup_data.ClassUnderTest.ClosedTasks.size(), 'ClosedTasks should contain only Case-Prep tasks');
            System.assertEquals(3, setup_data.ClassUnderTest.OpenTasks.size(), 'OpenTasks should contain open tasks and future events');
        }
    }

    static testMethod void testNewTaskOpenPopup() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            setup_data.initComponent();
            Test.startTest();
                PageReference page = setup_data.ClassUnderTest.newTask();
            Test.stopTest();
            System.assertEquals(null, page, 'No redirect');
            System.assertEquals(new Task(), setup_data.ClassUnderTest.NewTask, 'Open popup');
        }
    }

    static testMethod void testSaveTask() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            setup_data.initComponent();
            setup_data.ClassUnderTest.newTask();
            setup_data.ClassUnderTest.NewTask.Subject = 'test';
            Test.startTest();
                setup_data.ClassUnderTest.saveTask();
            Test.stopTest();
            setup_data.queryTestTasks();
            System.assertEquals(1, setup_data.TestTasks.size(), 'Should create one task');
            System.assertEquals('test', setup_data.TestTasks.get(0).Subject, 'Should set subject');
            System.assertEquals('Open', setup_data.TestTasks.get(0).Status, 'Should set open status');
        }
    }

    static testMethod void testHideTaskPopup() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            setup_data.initComponent();
            setup_data.ClassUnderTest.newTask();
            Test.startTest();
                setup_data.ClassUnderTest.hideNewTaskPopup();
            Test.stopTest();
            System.assertEquals(null, setup_data.ClassUnderTest.NewTask, 'Hidden popup');
        }
    }

    static testMethod void testGetTaskSubjects() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            setup_data.initComponent();
            setup_data.createTasksSubjectsCS();
            Test.startTest();
                List<SelectOption> options = setup_data.ClassUnderTest.getTaskSubjects();
            Test.stopTest();
            System.assertEquals(setup_data.getExpectedTasksSubjects(), options, 'Should return expected options');
        }
    }

    static testMethod void testSavingCommentsOpenTasks() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3);
            setup_data.initComponent();
            setup_data.updateCommentsInActivityWrappers('teeeeest', setup_data.ClassUnderTest.OpenTasks);

            Test.startTest();
                setup_data.ClassUnderTest.saveCommentsOpenTasks();
            Test.stopTest();

            List<Task> updated_tasks = [SELECT Description, Subject FROM Task];
            for(Task updated_task : updated_tasks){
                if(!updated_task.Subject.contains('case owner')){
                    System.assertEquals('teeeeest', updated_task.Description, 'Comment was not updated on case');
                }
            }
        }
    }

    static testMethod void testSavingCommentsClosedTasks() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            setup_data.createDoneTasksWithSpecificTaskFor(3);
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

    static testMethod void testUpdateSelectedTasksWithSpecificStatusMessageSuccess() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3);
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
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3);
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
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            setup_data.createOpenTasksWithSpecificTaskFor(3);
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
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            setup_data.createDoneTasksWithSpecificTaskFor(3);
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

    static testMethod void testGetActivitiesByQuery() {
        SetupDataClass setup_data = new SetupDataClass(SYSADMIN);
        System.runAs(setup_data.TestUser) {
            setup_data.createCollectionsRecoveriesCase('Open');
            setup_data.createOpenTasksForTestWrapper(5);
            setup_data.initComponent();
            setup_data.changeRecordTypeForTaskByIndex(0, RecordTypeUtility.TASK_COLLECTIONS_CALL);
            Test.startTest();
                List<CaseActivitiesSectionController.ActivityWrapper> list_wrappers = setup_data.ClassUnderTest.getActivitiesByQuery(setup_data.ClassUnderTest.QueryOpenTasks);
            Test.stopTest();
            System.assertEquals(5, list_wrappers.size(), 'Should be equals size');
            for (Integer i = 0; i < list_wrappers.size(); i++){
                CaseActivitiesSectionController.ActivityWrapper current_task_wrapper = list_wrappers.get(i);
                System.assertEquals(current_task_wrapper.Status, 'Open', 'Should be equals');
                System.assertEquals(current_task_wrapper.Subject, 'Subject', 'Should be equals');
                System.assertEquals(current_task_wrapper.Description, 'Task_description__c', 'Should be equals');
                System.assertEquals(current_task_wrapper.Comment, 'Description', 'Should be equals');
                System.assertEquals(current_task_wrapper.ReasonFailForDpa, 'Reason_for_failed_DPA__c', 'Should be equals');
                System.assertEquals(current_task_wrapper.ReasonFailCouldNotContact, 'Reason__c', 'Should be equals');
                System.assertEquals(current_task_wrapper.CanBeUndone, i == 0 ? false : true, 'Should be equals');
            }
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public Account TestAccount;
        public CaseActivitiesSectionController ClassUnderTest;
        public User TestUser;
        public List<Task> TestTasks;

        public SetupDataClass(String last_name) {
            TestUser = [SELECT Id FROM User WHERE LastName = :last_name LIMIT 1];
        }

        public void createCollectionsRecoveriesCase(string status) {
            Account test_account = AccountBuilder.getBuilder('CaseActivitiesSectionController').save().getRecord();
            TestCase = CaseBuilder.getBuilder(test_account).setStatus(status).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES).save().getRecord();
        }

        public void createOpenTasksWithSpecificTaskFor(Integer num_of_tasks) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestCase.Id).setRecordType(RecordTypeUtility.TASK_COLLECTIONS_RECOVERIES)
                                    .setStatus('Open').getRecordList(num_of_tasks);
        }

        public void createOpenTasksForTestWrapper(Integer num_of_tasks) {
            insert TaskBuilder.getBuilder()
                              .setRelatedTo(TestCase.Id)
                              .setRecordType(RecordTypeUtility.TASK_COLLECTIONS_RECOVERIES)
                              .setStatus('Open')
                              .setSubject('Subject')
                              .setTaskDescription('Task_description__c')
                              .setComment('Description')
                              .setReasonForFailDpa('Reason_for_failed_DPA__c')
                              .setCouldNotContactReason('Reason__c')
                              .getRecordList(num_of_tasks);
        }

        public void changeRecordTypeForTaskByIndex(Integer task_index, String record_type_name) {
            queryTestTasks();
            TaskBuilder.getBuilder(TestTasks.get(task_index)).setRecordType(record_type_name).save();
        }

        public void setIdTaskToUndoForFirstRecordInList() {
            ClassUnderTest.IdTaskToUndo = ClassUnderTest.ClosedTasks.get(0).getRecord().Id;
        }

        public void createDoneTasksWithSpecificTaskFor(Integer num_of_tasks) {
            insert TaskBuilder.getBuilder().setRelatedTo(TestCase.Id).setRecordType(RecordTypeUtility.TASK_COLLECTIONS_RECOVERIES)
                                    .setStatus('Completed').getRecordList(num_of_tasks);
        }

        public void markOpenTasksAsSelected(Integer number_of_selected_tasks) {
            for (Integer i = 0; i<number_of_selected_tasks; i++) {
                ClassUnderTest.OpenTasks.get(i).IsSelected = true;
            }
        }

        public void setMassEditStatus(String status) {
            ClassUnderTest.MassEditStatus = status;
        }

        public Integer getNumberOfTasksWithStatus(String status) {
            return [SELECT count() FROM Task WHERE Status = :status];
        }

        public Integer getNumberOfTasksWithCurentUserAsOwnerByStatus(String status) {
            return [SELECT count() FROM Task WHERE OwnerId = :UserInfo.getUserId() AND Status = :status];
        }

        public Integer getNumberOfTasksWithActivityDateTimeToday() {
            return [SELECT count() FROM Task WHERE OwnerId = :UserInfo.getUserId() AND CompletedDateTime__c = TODAY AND (NOT Subject LIKE '%case owner%')];
        }

        public void assertPageMessageOpen(String message) {
            System.assertEquals(message, ClassUnderTest.MessageHandlerOpenTasks.Summary, 'Page message assert failed');
        }

        public List<CaseActivitiesSectionController.ActivityWrapper> updateCommentsInActivityWrappers(String comment, List<CaseActivitiesSectionController.ActivityWrapper> wrappers){
            for(CaseActivitiesSectionController.ActivityWrapper wrapper : wrappers){
                wrapper.Comment = comment;
                wrapper.IsTask = true;
            }
            return wrappers;
        }

        public void initComponent() {
            ClassUnderTest = new CaseActivitiesSectionController();
            ClassUnderTest.RelatedCase = TestCase;
        }

        public void queryTestTasks() {
            TestTasks = [SELECT Subject, Status FROM Task WHERE WhatId = :TestCase.Id];
        }

        public void createTasksSubjectsCS() {
            List<Collections_Recoveries_Task_Subjects__c> subject_settings = new List<Collections_Recoveries_Task_Subjects__c>();
            for (String subject : NEW_TASKS_SUBJECTS) {
                subject_settings.add(new Collections_Recoveries_Task_Subjects__c(Name = subject, Task_Subject__c = subject));
            }
            insert subject_settings;
        }

        public List<SelectOption> getExpectedTasksSubjects() {
            List<SelectOption> options = new List<SelectOption>();
            for (String subject : NEW_TASKS_SUBJECTS) {
                options.add(new SelectOption(subject, subject));
            }
            return options;
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName(SYSADMIN)
                                     .save();
    }
}