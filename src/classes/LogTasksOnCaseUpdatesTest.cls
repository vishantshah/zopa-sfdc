@isTest
private class LogTasksOnCaseUpdatesTest {

    static testMethod void testCheckIfNeedToCreateTasksAddsUpdatesCaseToLists() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingUpdatedCase();
            setup_data.initClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.checkIfNeedToCreateTasks(setup_data.TestOldCase, setup_data.TestNewCase);
            Test.stopTest();
            System.assert(setup_data.ClassUnderTest.ChangedOwnerCase.contains(setup_data.TestNewCase), 'Case should be added to set');
            System.assert(setup_data.ClassUnderTest.ChangedStatusCase.contains(setup_data.TestNewCase), 'Case should be added to set');
        }
    }

    static testMethod void testCheckIfNeedToCreateTasksAddsUpdatesCaseToListsWithIncorrectRecordType() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createIncorrectUpdatedCase();
            setup_data.initClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.checkIfNeedToCreateTasks(setup_data.TestOldCase, setup_data.TestNewCase);
            Test.stopTest();
            System.assert(setup_data.ClassUnderTest.ChangedOwnerCase.isEmpty(), 'Case with incorrect record type should not be added to set');
            System.assert(setup_data.ClassUnderTest.ChangedStatusCase.isEmpty(), 'Case with incorrect record type should not be added to set');
        }
    }

    static testMethod void testCheckIfNeedToCreateTasksAddsDoesntUpdatesCaseToLists() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingUpdatedCase();
            setup_data.initClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.checkIfNeedToCreateTasks(setup_data.TestNewCase, setup_data.TestNewCase);
            Test.stopTest();
            System.assert(setup_data.ClassUnderTest.ChangedOwnerCase.isEmpty(), 'Case should not be added to set');
            System.assert(setup_data.ClassUnderTest.ChangedStatusCase.isEmpty(), 'Case should not be added to set');
        }
    }

    static testMethod void testInsertOwnerChangedTasks() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCaseWithOtherOwnersr();
            setup_data.initClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.checkIfNeedToCreateTasks(setup_data.TestOldCase, setup_data.TestNewCase);
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.ChangedOwnerCase.isEmpty(), 'Case should be added to set');
        }
    }

    static testMethod void testInsertNewCaseUpdateTasks() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingUpdatedCase();
            setup_data.initClassUnderTest();
            setup_data.ClassUnderTest.checkIfNeedToCreateTasks(setup_data.TestOldCase, setup_data.TestNewCase);
            Test.startTest();
                Map<Id, sObject> old_trigger_map = setup_data.getOldTriggerMap();
                setup_data.ClassUnderTest.insertNewCaseUpdateTasks(old_trigger_map);
            Test.stopTest();
            String changed_owner_task_subject = 'Jon Smith changed the case owner from Case Prep Priority 1 to Jon Smith';
            Integer changed_owner_tasks = [SELECT Count() FROM Task WHERE WhatId = :setup_data.TestNewCase.Id AND Subject = :changed_owner_task_subject];
            System.assertEquals(1, changed_owner_tasks, 'Changed owner task isnt created');
            String changed_status_task_subject = 'Jon Smith changed the manual underwriting case status from Open to In Progress';
            Integer changed_status_tasks = [SELECT Count() FROM Task WHERE WhatId = :setup_data.TestNewCase.Id AND Subject = :changed_status_task_subject];
            System.assertEquals(1, changed_status_tasks, 'Changed status task isnt created');
            System.assert(setup_data.ClassUnderTest.ChangedOwnerCase.isEmpty(), 'Set should be cleared');
            System.assert(setup_data.ClassUnderTest.ChangedStatusCase.isEmpty(), 'Set should be cleared');
        }
    }

    private class SetupDataClass {
        public Case TestOldCase;
        public Case TestNewCase;
        public User TestUser;
        public LogTasksOnCaseUpdates ClassUnderTest;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;
        public Loan_Application__c TestOldLoanApplication;
        public Id CasePrepQueue;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'Smith' AND FirstName = 'Jon' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplication = [SELECT Id FROM Loan_Application__c LIMIT 1];
            CasePrepQueue = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.CASE_PREP_PRIORITY1);
        }

        public void initClassUnderTest() {
            ClassUnderTest = LogTasksOnCaseUpdates.getInstance();
        }

        public void createManualUnderwritingUpdatedCase() {
            TestOldCase = CaseBuilder.getBuilder(TestAccount).setStatus('Open').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).setOwner(CasePrepQueue).save().getRecord();
            TestNewCase = CaseBuilder.getBuilder(TestAccount).setStatus('In Progress').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
        }

        public void createIncorrectUpdatedCase() {
            TestOldCase = CaseBuilder.getBuilder(TestAccount).setStatus('Open').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_TECH_SUPPORT).setOwner(CasePrepQueue).save().getRecord();
            TestNewCase = CaseBuilder.getBuilder(TestAccount).setStatus('In Progress').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_TECH_SUPPORT).save().getRecord();
        }

        public void createManualUnderwritingCaseWithOtherOwnersr() {
            TestOldCase = CaseBuilder.getBuilder(TestAccount).setStatus('Open').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).setOwner(CasePrepQueue).save().getRecord();
            TestNewCase = CaseBuilder.getBuilder(TestAccount).setStatus('Open').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).setOwner(TestUser.Id).save().getRecord();
        }

        public Map<Id, sObject> getOldTriggerMap(){
            Map<Id, sObject> old_trigger_map = new Map<Id, sObject>();
            old_trigger_map.put(TestNewCase.Id, TestOldCase);
            return old_trigger_map;
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                                     .setFirstName('Jon')
                                     .setLastName('Smith')
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('DocumentReceivedFromIntegrationHandTest').save().getRecord();
            FeatureSwitch.disable('ZOPA-4');
            LoanApplicationBuilder.getBuilder(test_account).save();
        }
    }
}