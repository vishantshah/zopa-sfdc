@isTest
private class ReferralCodeTasksCreationDeletionTest {
    private static final String CASE_CONFIGURATION_CODE_NAME = 'RC_01';
    private static final String CASE_CONFIGURATION_STATUS = 'Triggered';
    private static final String CASE_CONFIGURATION_DESCRIPTION = 'Description';
    private static final String CASE_CONFIGURATION_TASK_SUBJECT = 'Task Subject';
    private static final String CASE_CONFIGURATION_TASK_DESCRIPTION = 'Task Description';
    private static final String CASE_CONFIGURATION_TASK_TASK_FOR = 'Underwriter';

    static testMethod void testCreateTasksIfNecessaryOpenCaseWithCodes() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createRCCodesWithTasks();
            setup_data.createManualUnderwritingCases();
            setup_data.updateCaseWithCaseCodes(CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME);
            setup_data.upsertTestCase();
            Test.startTest();
                setup_data.ClassUnderTest.createTasksIfNecessary(setup_data.TestCase);
            Test.stopTest();
            setup_data.queryTasks();
            System.assertEquals(1, setup_data.ClassUnderTest.AllTaskToUpsert.size(), 'Should add tasks to AllTaskToUpsert');
        }
    }

    static testMethod void testCreateTasksIfNecessaryOpenCaseWithoutCodes() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createRCCodesWithTasks();
            setup_data.createManualUnderwritingCases();
            setup_data.upsertTestCase();
            Test.startTest();
                setup_data.ClassUnderTest.createTasksIfNecessary(setup_data.TestCase);
            Test.stopTest();
            setup_data.queryTasks();
            System.assertEquals(0, setup_data.ClassUnderTest.AllTaskToUpsert.size(), 'Should not add tasks to AllTaskToUpsert');
        }
    }

    static testMethod void testCreateTasksIfNecessaryPendingCaseWithCodes() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createRCCodesWithTasks();
            setup_data.createManualUnderwritingCases();
            setup_data.updateCaseToPending();
            setup_data.updateCaseWithCaseCodes(CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME);
            setup_data.upsertTestCase();
            Test.startTest();
                setup_data.ClassUnderTest.createTasksIfNecessary(setup_data.TestCase);
            Test.stopTest();
            setup_data.queryTasks();
            System.assertEquals(0, setup_data.ClassUnderTest.AllTaskToUpsert.size(), 'Should not add tasks to AllTaskToUpsert');
        }
    }

    static testMethod void testCreateUpdateDeleteTasksIfNecessaryUpdateToNewcaseCodes() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createRCCodesWithTasks();
            setup_data.createManualUnderwritingCases();
            setup_data.updateCaseWithCaseCodes(CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME);
            setup_data.upsertTestCase();
            Test.startTest();
                setup_data.ClassUnderTest.createUpdateDeleteTasksIfNecessary(setup_data.TestOldCase, setup_data.TestCase);
            Test.stopTest();
            setup_data.queryTasks();
            System.assertEquals(1, setup_data.ClassUnderTest.AllTaskToUpsert.size(), 'Should not add tasks to AllTaskToUpsert');
        }
    }

    static testMethod void testCreateUpdateDeleteTasksIfNecessaryClearCaseCodesAddTaskToDeleting() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createRCCodesWithTasks();
            setup_data.createManualUnderwritingCases();
            setup_data.updateCaseWithCaseCodes(CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME);
            setup_data.updateCaseWithCaseCodes(null,null,null);
            setup_data.upsertTestCase();
            setup_data.createNewTaskFromConfiguration();
            Test.startTest();
                setup_data.ClassUnderTest.queryExistingRCTasks(new Map<Id, Case>{setup_data.TestCase.Id => setup_data.TestCase});
                setup_data.ClassUnderTest.createUpdateDeleteTasksIfNecessary(setup_data.TestOldCase, setup_data.TestCase);
            Test.stopTest();
            setup_data.queryTasks();
            System.assertEquals(0, setup_data.ClassUnderTest.AllTaskToUpsert.size(), 'Should not add tasks to AllTaskToUpsert');
            System.assertEquals(1, ReferralCodeTasksCreationDeletionHandler.UniqueTaskKeyToExistingTask.values().size(), 'Should add task to deleting');
        }
    }

    private class SetupDataClass {
        public List<Task> TestTasks;
        public Case TestCase;
        public Case TestOldCase;
        public User TestUser;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;
        public ReferralCodeTasksCreationDeletionHandler ClassUnderTest;
        private Case_Configuration_Task__c CaseConfigurationTask;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'ReferralCodeTasksCreationDeletionTest' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplication = [SELECT Id FROM Loan_Application__c LIMIT 1];
            ClassUnderTest = ReferralCodeTasksCreationDeletionHandler.getInstance();
        }

        public void createManualUnderwritingCases() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).getRecord();
        }

        public void updateCaseToPending() {
            TestOldCase = TestCase.clone();
            CaseBuilder.getBuilder(TestCase).setStatus('Pending');
        }

        public void updateCaseWithCaseCodes(String triggered_code, String aborted_code, String errored_code) {
            TestOldCase = TestCase.clone();
            CaseBuilder.getBuilder(TestCase).setTriggeredReferralCodes(triggered_code)
                                            .setAbortedReferralCodes(aborted_code)
                                            .setErroredReferralCodes(errored_code);
        }

        public void createRCCodesWithTasks() {
            Case_Configuration__c rc_code = CaseConfigurationBuilder.getBuilder().setName(CASE_CONFIGURATION_CODE_NAME).setCodeDescription(CASE_CONFIGURATION_DESCRIPTION).save().getRecord();
            CaseConfigurationTask = CaseConfigurationTaskBuilder.getBuilder(rc_code).setStatuses(CASE_CONFIGURATION_STATUS).setTaskSubject(CASE_CONFIGURATION_TASK_SUBJECT).setTaskDescription(CASE_CONFIGURATION_TASK_DESCRIPTION).setTaskFor(CASE_CONFIGURATION_TASK_TASK_FOR).save().getRecord();
        }

        public void createNewTaskFromConfiguration() {
            TaskBuilder.getBuilder()
                        .setTaskFor(CaseConfigurationTask.Task_for__c)
                        .setSubject(CaseConfigurationTask.Task_Subject__c)
                        .setComment(CaseConfigurationTask.Task_Description__c)
                        .setTaskDescription(CaseConfigurationTask.Task_Description__c)
                        .setCaseConfigurationTask(CaseConfigurationTask.Id)
                        .setRCCodeStatus('Triggered')
                        .setRecordType(RecordTypeUtility.TASK_REFERRAL_CODE)
                        .setRelatedTo(TestCase.Id).save();
        }

        public void upsertTestCase() {
            upsert TestCase;
            queryCase();
        }

        private void queryCase() {
            TestCase = [SELECT RecordTypeId, Status, Triggered_Referral_Codes__c, Aborted_Referral_Codes__c, Errored_Referral_Codes__c
                        FROM Case WHERE Id = :TestCase.Id];
        }

        private void queryTasks() {
            TestTasks = [SELECT Subject, Description, Task_For__c FROM Task WHERE WhatId = :TestCase.Id];
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setLastName('ReferralCodeTasksCreationDeletionTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('ReferralCodeTasksCreationDeletionTest').save().getRecord();
            FeatureSwitch.disable('ZOPA-4');
            LoanApplicationBuilder.getBuilder(test_account).save();
        }
    }
}