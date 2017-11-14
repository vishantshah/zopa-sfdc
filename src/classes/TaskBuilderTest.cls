@isTest
private class TaskBuilderTest {

    static testMethod void testSaveAndCheckIfTheTaskIsCreated(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Id FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals(1, list_of_tasks_created.size(), 'The task was not created.');
        }
    }

    static testMethod void testSetSubjectAndCheckIfTheTaskHasCorrectSubject(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setSubject('Subject Test').save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Subject FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals('Subject Test', list_of_tasks_created[0].Subject, 'Subject has not been assigned correctly to the task.');
        }
    }

    static testMethod void testSetStatusAndCheckIfTheTaskHasCorrectStatus(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setStatus('Status Test').save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Status FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals('Status Test', list_of_tasks_created[0].Status, 'Status has not been assigned correctly to the task.');
        }
    }

    static testMethod void testSetCompletedDateTimeAndCheckIfTheTaskHasCorrectCompletedDateTime(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Datetime now = Datetime.now();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setCompletedDateTime(now).save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select CompletedDateTime__c FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals(now, list_of_tasks_created[0].CompletedDateTime__c, 'CompletedDateTime has not been assigned correctly to the task.');
        }
    }

    static testMethod void testSetReviewDueDateAndCheckIfTheTaskHasCorrectReviewDueDate(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Datetime now = Datetime.now();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setReviewDueDate(now).save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Review_Due_Date__c FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals(now, list_of_tasks_created[0].Review_Due_Date__c, 'ReviewDueDate has not been assigned correctly to the task.');
        }
    }

    static testMethod void testSetDueDateAndCheckIfTheTaskHasCorrectDueDate(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setDueDate(date.today()).save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select ActivityDate FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals(date.today(), list_of_tasks_created[0].ActivityDate, 'Due date has not been assigned correctly to the task.');
        }
    }

    static testMethod void testSetRecordTypeAndCheckIfTheTaskHasCorrectRecordType(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE).save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select RecordType.DeveloperName FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals('Referral_Code_Tasks', list_of_tasks_created[0].RecordType.DeveloperName, 'Record Type has not been assigned correctly to the task.');
        }
    }

    static testMethod void testSetPriorityAndCheckIfTheTaskHasCorrectPriority(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setPriority('High').save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Priority FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals('High', list_of_tasks_created[0].Priority, 'Record Type has not been assigned correctly to the task.');
        }
    }

    static testMethod void testSetCopyForCaseAndCheckIfTheTaskHasCorrectCopyForCase(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setCopyForCase(true).save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Copy_For_Case__c FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals(true, list_of_tasks_created[0].Copy_For_Case__c, 'Copy For Case must bee true');
        }
    }

    static testMethod void testSetCommentAndCheckIfTheTaskHasCorrectComment(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setComment('Comment').save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Description FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals('Comment', list_of_tasks_created[0].Description, 'Comment has not been assigned correctly to the task.');
        }
    }

    static testMethod void testSetTaskDescriptionAndCheckIfTheTaskHasCorrectDescription(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setTaskDescription('Comment').save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Task_description__c FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals('Comment', list_of_tasks_created[0].Task_description__c, 'Description has not been assigned correctly to the task.');
        }
    }


    static testMethod void testSetTypeAndCheckIfTheTaskHasCorrectType(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setType('SMS').save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Type FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals('SMS', list_of_tasks_created[0].Type, 'Type has not been assigned correctly to the task.');
        }
    }

    static testMethod void testSetTaskForAndCheckIfTheTaskHasCorrectType(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setTaskFor('Case-Prep').save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Task_For__c FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals('Case-Prep', list_of_tasks_created[0].Task_For__c, 'Task_For__c has not been assigned correctly to the task.');
        }
    }

    static testMethod void testSetMethodAndCheckIfTheTaskHasCorrectMethod(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setMethod('Manual').save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Method__c FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals('Manual', list_of_tasks_created[0].Method__c, 'Method__c has not been assigned correctly to the task.');
        }
    }

    static testMethod void testGetRecordList(){
        Integer no_of_records =123;
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                List<Task> task_list = TaskBuilder.getBuilder().getRecordList(no_of_records);
            Test.stopTest();
            System.assertEquals(no_of_records, task_list.size() , 'List of tasks has wrong size');
        }
    }

    static testMethod void testCopyTaskAndCheckTaskIsCopy(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                Task task_for_test = TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setType('SMS').getRecord();
                Task task_for_test_copy = TaskBuilder.getBuilder(task_for_test).cloneTask().getRecord();
            Test.stopTest();
            System.assertEquals(true, task_for_test == task_for_test_copy, 'Task must be equals');
        }
    }

    static testMethod void testSetReasonForFailDpa(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setReasonForFailDpa('Reason Test').save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Reason_for_failed_DPA__c FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals('Reason Test', list_of_tasks_created[0].Reason_for_failed_DPA__c, 'Reason for failed DPA has not been assigned correctly to the task.');
        }
    }

    static testMethod void testSetCouldNotContactReason(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            setup_data.createAccountAndCase();
            Test.startTest();
                TaskBuilder.getBuilder().setRelatedTo(setup_data.TestCase.Id).setCouldNotContactReason('Reason Test').save();
            Test.stopTest();
            List<Task> list_of_tasks_created = [Select Reason__c FROM Task WHERE WhatId =: setup_data.TestCase.Id];
            System.assertEquals('Reason Test', list_of_tasks_created[0].Reason__c, 'Could not contact reason has not been assigned correctly to the task.');
        }
    }

    private class SetupDataClass {
        public User TestUser;
        public Account TestAccount;
        public Case TestCase;
        public Case_Configuration__c TestCaseConfiguration;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE LastName = 'TaskBuilderTest' LIMIT 1];
        }

        public void createAccountAndCase(){
            FeatureSwitch.disable('ZOPA-18');
            TestAccount = AccountBuilder.getBuilder('Test')
                    .save()
                    .getRecord();
            TestCase = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)
                    .save()
                    .getRecord();
        }

        public void createTestCaseConfiguration(){
            TestCaseConfiguration = CaseConfigurationBuilder.getBuilder()
                    .setName('RC_05')
                    .save()
                    .getRecord();
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                .setLastName('TaskBuilderTest')
                .save();
    }
}