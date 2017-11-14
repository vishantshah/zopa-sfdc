@isTest
private class CaseTriggerHandlerTest {
    private static final Integer BULK_SIZE = 10;

    private static final String CASE_CONFIGURATION_CODE_NAME = 'RC_01';
    private static final String CASE_CONFIGURATION_STATUS = 'Triggered';
    private static final String CASE_CONFIGURATION_DESCRIPTION = 'Description';
    private static final String CASE_CONFIGURATION_TASK_SUBJECT = 'Task Subject';
    private static final String CASE_CONFIGURATION_TASK_DESCRIPTION = 'Task Description';
    private static final String CASE_CONFIGURATION_TASK_TASK_FOR = 'Underwriter';

    static testMethod void testPopulatesInitialUnderwriterFieldsBulk() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-23');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCases(BULK_SIZE);
            setup_data.upsertTestCases();

            Test.startTest();
                setup_data.assignToUnderwritingAndUpdate();
            Test.stopTest();

            System.assertEquals(BULK_SIZE, setup_data.TestCases.size());
            for (Case updated_case : setup_data.TestCases) {
                System.assertEquals(setup_data.TestUnderwriterUser.Id, updated_case.Initial_Underwriter__c, 'Should populate Intial Underiter with first Underwriter');
            }
        }
    }

    static testMethod void testNotPopulatesInitialUnderwriterFieldsIfItIsAlreadyPopulatedBulk() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-23');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCasesWithFilledInitialUnderwriter(BULK_SIZE);
            setup_data.upsertTestCases();

            Test.startTest();
                setup_data.assignToUnderwritingAndUpdate();
            Test.stopTest();

            System.assertEquals(BULK_SIZE, setup_data.TestCases.size());
            for (Case updated_case : setup_data.TestCases) {
                System.assertEquals(setup_data.TestUser.Id, updated_case.Initial_Underwriter__c, 'Should not populate Intial Underiter with second Underwriter');
            }
        }
    }

    static testMethod void testInsertCaseWithCodesCreatesTasks() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createRCCodesWithTasks();
            setup_data.createManualUnderwritingCasesWithOnwerWithoutLoanApp(BULK_SIZE);
            setup_data.updateCaseWithCaseCodes(CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME);

            Test.startTest();
                setup_data.upsertTestCases();
            Test.stopTest();

            setup_data.queryTasks();
            System.assertEquals(BULK_SIZE, setup_data.TestTasks.size());
            for (Task new_task : setup_data.TestTasks) {
                System.assertEquals(CASE_CONFIGURATION_TASK_SUBJECT, new_task.Subject, 'Should populate Task Subject');
                System.assertEquals(CASE_CONFIGURATION_TASK_DESCRIPTION, new_task.Task_Description__c, 'Should populate Task Description');
                System.assertEquals(CASE_CONFIGURATION_TASK_TASK_FOR, new_task.Task_For__c, 'Should populate Task Task_For__c');
            }
        }
    }

    static testMethod void testInsertCaseWithCodesNotCreateTasksDisabledZOPA18() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createRCCodesWithTasks();
            setup_data.createManualUnderwritingCases(BULK_SIZE);
            setup_data.updateCaseWithCaseCodes(CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME);

            Test.startTest();
                setup_data.upsertTestCases();
            Test.stopTest();

            setup_data.queryTasks();
            System.assertEquals(0, setup_data.TestTasks.size(), 'Should not create tasks');
        }
    }

    static testMethod void testUpdateCaseRemoveCodesDeleteTasks() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createRCCodesWithTasks();
            setup_data.createManualUnderwritingCases(BULK_SIZE);
            setup_data.updateCaseWithCaseCodes(CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME);
            setup_data.upsertTestCases();
            setup_data.updateCaseWithCaseCodes(null, null, null);
            Test.startTest();
                setup_data.upsertTestCases();
            Test.stopTest();
            setup_data.queryTasks();
            System.assertEquals(0, setup_data.TestTasks.size(), 'Should not create tasks');
        }
    }

    static testMethod void testUpdateCaseAddCodesAddTasks() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-18');
        System.runAs(setup_data.TestUser) {
            setup_data.createRCCodesWithTasks();
            setup_data.createManualUnderwritingCases(BULK_SIZE);
            setup_data.upsertTestCases();
            setup_data.updateCaseWithCaseCodes(CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME,CASE_CONFIGURATION_CODE_NAME);
            Test.startTest();
                setup_data.upsertTestCases();
            Test.stopTest();
            setup_data.queryTasks();
            System.assertEquals(BULK_SIZE, setup_data.TestTasks.size());
            for (Task new_task : setup_data.TestTasks) {
                System.assertEquals(CASE_CONFIGURATION_TASK_SUBJECT, new_task.Subject, 'Should populate Task Subject');
                System.assertEquals(CASE_CONFIGURATION_TASK_DESCRIPTION, new_task.Task_Description__c, 'Should populate Task Description');
                System.assertEquals(CASE_CONFIGURATION_TASK_TASK_FOR, new_task.Task_For__c, 'Should populate Task Task_For__c');
            }
        }
    }

    static testMethod void testNotifyZopaWithFeatureSwitchOn() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-59');
        setup_data.createManualUnderwritingCasesWithOnwer(50);
        setup_data.upsertTestCases();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                update setup_data.TestCases;
            Test.stopTest();
            setup_data.queryCases();
            for (Case uw_case : setup_data.TestCases) {
                System.assertEquals(true, uw_case.First_Time_Picked__c, 'Cases should be marked with First_Time_Picked');
            }
        }
    }

    static testMethod void testNotifyZopaWithFeatureSwitchOff() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-59');
        setup_data.createManualUnderwritingCasesWithOnwer(50);
        setup_data.upsertTestCases();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                update setup_data.TestCases;
            Test.stopTest();
            setup_data.queryCases();
            for (Case uw_case : setup_data.TestCases) {
                System.assertEquals(false, uw_case.First_Time_Picked__c, 'Cases should not be marked with First_Time_Picked');
            }
        }
    }

    static testMethod void testNoTasksCreatedIfStatusAndOwnerStayTheSame() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-166');
        setup_data.createManualUnderwritingCasesWithOnwer(50);
        setup_data.upsertTestCases();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.upsertTestCases();
            Test.stopTest();
            Integer tasks_number = [SELECT Count() FROM Task];
            System.assertEquals(0, tasks_number, 'Expected no tasks to be created');
        }
    }

    static testMethod void testTasksCreatedIfStatusAndOwnerChange() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-166');
        setup_data.createManualUnderwritingCasesWithOnwerWithoutLoanApp(50);
        insert setup_data.TestCases;
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                for(Case case_to_update : setup_data.TestCases){
                    case_to_update.OwnerId = setup_data.TestUnderwriterUser.Id;
                    case_to_update.Status = 'In Progress';
                }
                setup_data.upsertTestCases();
            Test.stopTest();
            Integer tasks_number = [SELECT Count() FROM Task];
            System.assertEquals(150, tasks_number, 'Expected tasks to be created');
        }
    }

    static testMethod void testTasksCreatedIfStatusChangePending() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-166');
        setup_data.createManualUnderwritingCasesWithStatusInProgres(20);
        insert setup_data.TestCases;
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                for(Case case_to_update : setup_data.TestCases){
                    case_to_update.Status = 'Pending';
                }
                setup_data.upsertTestCases();
            Test.stopTest();
            Integer tasks_number = [SELECT Count() FROM Task];
            System.assertEquals(20, tasks_number, 'Expected tasks to be created');
        }
    }

    static testMethod void testOwnerChangedToDataImporterWhenCaseAutoApproved(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZS-34');
        System.runAs(setup_data.TestUser){
            setup_data.createInitialUnderwriterCaseWithStatusOpenDocumentReceived();
            setup_data.setTestCaseStatus('Closed - Auto Approved');

            Test.startTest();
                update setup_data.TestCase;
                Case test_case = [SELECT OwnerId FROM CASE WHERE Id = :setup_data.TestCase.Id];
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, test_case.OwnerId, 'OwnerId is equal DataImporter id.');
        }
    }

    static testMethod void testOwnerChangedToDataImporterWhenCaseAutoDeclined(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZS-34');
        System.runAs(setup_data.TestUser){
            setup_data.createInitialUnderwriterCaseWithStatusOpenDocumentReceived();
            setup_data.setTestCaseStatus('Closed - Auto Declined');

            Test.startTest();
                update setup_data.TestCase;
                Case test_case = [SELECT OwnerId FROM CASE WHERE Id = :setup_data.TestCase.Id];
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, test_case.OwnerId, 'OwnerId is equal DataImporter id.');
        }
    }

    static testMethod void testOwnerChangedToDataImporterWhenCaseAutoCancelled(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZS-34');
        System.runAs(setup_data.TestUser){
            setup_data.createInitialUnderwriterCaseWithStatusOpenDocumentReceived();
            setup_data.setTestCaseStatus('Closed - Auto Cancelled');

            Test.startTest();
                update setup_data.TestCase;
                Case test_case = [SELECT OwnerId FROM CASE WHERE Id = :setup_data.TestCase.Id];
            Test.stopTest();

            System.assertEquals(setup_data.DataImporter.Id, test_case.OwnerId, 'OwnerId is equal DataImporter id.');
        }
    }

    static testMethod void testOwnerChangedToDataImporterNegative(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZS-34');
        System.runAs(setup_data.TestUser){
            setup_data.createInitialUnderwriterCaseWithStatusOpenDocumentReceived();
            setup_data.setTestCaseStatus('In Progress');

            Test.startTest();
                Id case_owner_id =  setup_data.TestCase.OwnerId;
                update setup_data.TestCase;
                Case test_case = [SELECT OwnerId FROM CASE WHERE Id = :setup_data.TestCase.Id];
            Test.stopTest();

            System.assertEquals(case_owner_id, test_case.OwnerId, 'OwnerId should not be changed.');
            System.assertNotEquals(setup_data.DataImporter.Id, test_case.OwnerId, 'OwnerId is not equal DataImporter id.');
        }
    }

    static testMethod void testOwnerChangedToDataImporterWhenCaseAutoCancelledZs34Disabled(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZS-34');
        System.runAs(setup_data.TestUser){
            setup_data.createInitialUnderwriterCaseWithStatusOpenDocumentReceived();
            setup_data.setTestCaseStatus('Closed - Auto Cancelled');

            Test.startTest();
                Id case_owner_id =  setup_data.TestCase.OwnerId;
                update setup_data.TestCase;
                Case test_case = [SELECT OwnerId FROM CASE WHERE Id = :setup_data.TestCase.Id];
            Test.stopTest();

            System.assertEquals(case_owner_id, test_case.OwnerId, 'OwnerId should not be changed.');
            System.assertNotEquals(setup_data.DataImporter.Id, test_case.OwnerId, 'OwnerId is not equal DataImporter id.');
        }
    }

    static testMethod void testUpdatingCaseDCALinks() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZCP-135');

        System.runAs(setup_data.TestUser) {
            List<Case> cases = setup_data.getCasesWithUpdatedDCAAccounts();
            DcaAccountLinkingHandler.getInstance().IsAlreadyUpdatedRecordsInTransaction = false;
            Test.startTest();
                update cases;
            Test.stopTest();

            List<Loan__c> updated_loans = [SELECT Id, AccountDCA__c FROM Loan__c];
            for(Loan__c updated_loan : updated_loans){
                System.assertEquals(setup_data.AccountDca.Id, updated_loan.AccountDCA__c , 'Loan__c was not linked to the DCA correctly');
            }
        }
    }

    static testMethod void testUpdatingCaseDCALinksWhenDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZCP-135');

        System.runAs(setup_data.TestUser) {
            List<Case> cases = setup_data.getCasesWithUpdatedDCAAccounts();
            DcaAccountLinkingHandler.getInstance().IsAlreadyUpdatedRecordsInTransaction = false;
            Test.startTest();
                update cases;
            Test.stopTest();

            List<Loan__c> updated_loans = [SELECT Id, AccountDCA__c FROM Loan__c];
            for(Loan__c updated_loan : updated_loans){
                System.assertEquals(null, updated_loan.AccountDCA__c , 'Loan__c should not be linked to the DCA, when FeatureSwitch is disabled');
            }
        }
    }

    private class SetupDataClass {
        public List<Task> TestTasks;
        public List<Case> TestCases;
        public Case TestCase;
        public User TestUser;
        public User TestUnderwriterUser;
        public User DataImporter;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;
        public Account AccountDca;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'CaseTriggerHandlerTest' AND FirstName = 'SYSADMIN' LIMIT 1];
            TestUnderwriterUser = [SELECT Id FROM User WHERE LastName = 'CaseTriggerHandlerTest' AND FirstName = 'UNDERWITER' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account WHERE Name = 'CaseTriggerHandlerTest' LIMIT 1];
            AccountDca = [SELECT Id, Name, PersonContactId FROM Account WHERE Name = 'DcaAccount' LIMIT 1];
            TestLoanApplication = [SELECT Id FROM Loan_Application__c LIMIT 1];
            DataImporter = [SELECT Id FROM User WHERE Alias = 'Importer' AND LastName = 'Importer' AND FirstName = 'Data'];
        }

        public void createManualUnderwritingCases(Integer size) {
            TestCases = CaseBuilder.getBuilder(TestAccount).setStatus('In Progress').setSubject('CaseTriggerHandlerTest').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).getRecordList(size);
        }

        public void createManualUnderwritingCasesWithFilledInitialUnderwriter(Integer size) {
            TestCases = CaseBuilder.getBuilder(TestAccount).setStatus('In Progress').setSubject('CaseTriggerHandlerTest').setInitialUnderwriter(TestUser.Id).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).getRecordList(size);
        }

        public void createManualUnderwritingCasesWithOnwer(Integer size) {
            TestCases = CaseBuilder.getBuilder(TestAccount).setStatus('In Progress').setSubject('CaseTriggerHandlerTest').setOwner(TestUser.Id).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).getRecordList(size);
        }

        public void createManualUnderwritingCasesWithOnwerWithoutLoanApp(Integer size) {
            TestCases = CaseBuilder.getBuilder(TestAccount).setSubject('CaseTriggerHandlerTest').setOwner(TestUser.Id).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).getRecordList(size);
        }

        public void createManualUnderwritingCasesWithStatusInProgres(Integer size) {
            TestCases = CaseBuilder.getBuilder(TestAccount).setStatus('In Progress').setSubject('CaseTriggerHandlerTest').setOwner(TestUser.Id).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).getRecordList(size);
        }

        public void createInitialUnderwriterCaseWithStatusOpenDocumentReceived(){
            TestCase = CaseBuilder.getBuilder(TestAccount).setStatus('Open - Document Received').setOwner(TestUser.Id).setSubject('CaseTriggerHandlerTest').setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).getRecord();
            insert TestCase;
        }

        public void updateCaseWithCaseCodes(String triggered_code, String aborted_code, String errored_code) {
            for (Case test_case : TestCases) {
                CaseBuilder.getBuilder(test_case).setTriggeredReferralCodes(triggered_code)
                                                 .setAbortedReferralCodes(aborted_code)
                                                 .setErroredReferralCodes(errored_code);
            }
        }

        public void setTestCaseStatus(String status) {
            TestCase.Status = status;
        }

        public void assignToUnderwritingAndUpdate() {
            for (Case case_to_update : TestCases) {
                case_to_update.OwnerId = TestUnderwriterUser.Id;
            }
            upsertTestCases();
        }

        public void createRCCodesWithTasks() {
            Case_Configuration__c rc_code = CaseConfigurationBuilder.getBuilder().setName(CASE_CONFIGURATION_CODE_NAME).setCodeDescription(CASE_CONFIGURATION_DESCRIPTION).save().getRecord();
            CaseConfigurationTaskBuilder.getBuilder(rc_code).setStatuses(CASE_CONFIGURATION_STATUS).setTaskSubject(CASE_CONFIGURATION_TASK_SUBJECT).setTaskDescription(CASE_CONFIGURATION_TASK_DESCRIPTION).setTaskFor(CASE_CONFIGURATION_TASK_TASK_FOR).save();
        }

        public void upsertTestCases() {
            upsert TestCases;
            queryCases();
        }

        private void queryCases() {
            TestCases = [SELECT OwnerId, Initial_Underwriter__c,First_Time_Picked__c FROM Case WHERE Subject = 'CaseTriggerHandlerTest'];
        }

        private void queryTasks() {
            Set<Id> case_ids = new Map<Id, sObject> (TestCases).keySet();
            TestTasks = [SELECT Subject, Description, Task_Description__c, Task_For__c, Status FROM Task WHERE WhatId IN :case_ids];
        }

        public void createLoans(){
            List<Loan__c> loan_list = LoanBuilder.getBuilder(TestAccount).setArrearsRatio(1).save().getRecordList(BULK_SIZE);
            insert loan_list;
        }

        public List<Case> getCasesWithUpdatedDCAAccounts(){
            List<Case> cases = [SELECT Id, AccountDCA__c FROM Case];
            for(Case case_to_update : cases){
                case_to_update.AccountDCA__c = AccountDca.Id;
            }
            return cases;
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                                     .setFirstName('UNDERWITER')
                                     .setLastName('CaseTriggerHandlerTest')
                                     .save().getRecord();
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('SYSADMIN')
                                     .setLastName('CaseTriggerHandlerTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('CaseTriggerHandlerTest').save().getRecord();
            Account dca = AccountBuilder.getBuilder('DcaAccount').save().getRecord();
            FeatureSwitch.disable('ZOPA-4');
            LoanApplicationBuilder.getBuilder(test_account).setExternalId('1234').save();
        }
    }
}