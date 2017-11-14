@isTest
private class UpdateCaseAssignmentControllerTest {
    public static final Integer BULK_SIZE = 200;
    public static final String CASE_ASSIGNMENT_RULE = 'Move_To_Case_Prep';

    static testMethod void testUpdateCaseAssignmentControllerInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();

            System.assertNotEquals(null, setup_data.ClassUnderTest.OrganizationCaseAssignmentRules, 'Should initialize value.');
            System.assertNotEquals(null, setup_data.ClassUnderTest.SelectedAppLabel, 'Should initialize value.');
        }
    }

    static testMethod void testUpdateAssignmentRulesInUseUnsuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.populateWithNotExistingValuesToCustomSettings();

            Test.startTest();
                setup_data.ClassUnderTest.updateAssignmentRulesInUse();
            Test.stopTest();

            setup_data.assertPageMessage(setup_data.ClassUnderTest.ERROR_UPDATING_ASSIGNMENT_RULES + ': ' + setup_data.ClassUnderTest.ErrorString);
        }
    }

    static testMethod void testUpdateAssignmentRulesInUseSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.populateExistingValuesToCustomSettings();

            Test.startTest();
                setup_data.ClassUnderTest.updateAssignmentRulesInUse();
            Test.stopTest();

            System.assertEquals(CASE_ASSIGNMENT_RULE, TestCustomSettings.getAssignmentRulesCS().Creation_Manual_Underwriting__c);
            System.assertEquals(CASE_ASSIGNMENT_RULE, TestCustomSettings.getAssignmentRulesCS().Case_Prep__c);
            System.assertEquals(CASE_ASSIGNMENT_RULE, TestCustomSettings.getAssignmentRulesCS().Fraud__c);
            System.assertEquals(CASE_ASSIGNMENT_RULE, TestCustomSettings.getAssignmentRulesCS().Underwriter__c);
            setup_data.assertPageMessage(setup_data.ClassUnderTest.ASSIGNMENT_RULES_UPDATED_SUCCESSFULLY);
        }
    }

    static testMethod void testUpdateAssignmentsWithCasePrepQueueOwner() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setSelectedAppLabel('Underwriting App');
            setup_data.createManualUnderwritingCases(CaseUtility.QueueName.CASE_PREP_PRIORITY1);

            Test.startTest();
                setup_data.ClassUnderTest.updateAssignments();
            Test.stopTest();

            for (Case case_to_assert : setup_data.reQueryCases()) {
                System.assertNotEquals(setup_data.TestCases.get(case_to_assert.Id).OwnerId, case_to_assert.OwnerId, 'Should change owner.');
            }
            setup_data.assertPageMessage(setup_data.ClassUnderTest.CASES_UPDATE_STARTED);
        }
    }

    static testMethod void testUpdateAssignmentsUpdatesUnderwriterQueueOwner() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setSelectedAppLabel('Underwriting App');
            setup_data.createManualUnderwritingCases(CaseUtility.QueueName.UNDERWRITER_PRIORITY1);

            Test.startTest();
                setup_data.ClassUnderTest.updateAssignments();
            Test.stopTest();

            for (Case case_to_assert : setup_data.reQueryCases()) {
                System.assertNotEquals(setup_data.TestCases.get(case_to_assert.Id).OwnerId, case_to_assert.OwnerId, 'Should change owner.');
            }
            setup_data.assertPageMessage(setup_data.ClassUnderTest.CASES_UPDATE_STARTED);
        }
    }

    static testMethod void testGetIsManualUnderwritingAppSelectedWhenItIs() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setSelectedAppLabel('Underwriting App');

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsManualUnderwritingAppSelected();
            Test.stopTest();

            System.assertEquals(true, result, 'Should return true.');
        }
    }

    static testMethod void testGetIsManualUnderwritingAppSelectedWhenItIsNot() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setSelectedAppLabel('Collections');

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsManualUnderwritingAppSelected();
            Test.stopTest();

            System.assertEquals(false, result, 'Should return false.');
        }
    }

    static testMethod void testGetIsCollectionsAppSelectedWhenItIs() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setSelectedAppLabel('Collections');

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsCollectionsAndRecoveriesAppSelected();
            Test.stopTest();

            System.assertEquals(true, result, 'Should return true.');
        }
    }

    static testMethod void testGetIsCollectionsAppSelectedWhenItIsNot() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setSelectedAppLabel('Underwriting App');

            Test.startTest();
                Boolean result = setup_data.ClassUnderTest.getIsCollectionsAndRecoveriesAppSelected();
            Test.stopTest();

            System.assertEquals(false, result, 'Should return false.');
        }
    }

    private class SetupDataClass {
        public Map<Id,Case> TestCases;
        public User TestUser;
        public Account TestAccount;
        public UpdateCaseAssignmentController ClassUnderTest;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'TestLastName' LIMIT 1];
        }

        public void createTestAccount() {
            TestAccount = AccountBuilder.getBuilder('TestAccountName')
                    .save()
                    .getRecord();
        }

        public void initClassUnderTest() {
            ClassUnderTest = new UpdateCaseAssignmentController();
        }

        public void populateExistingValuesToCustomSettings() {
            ClassUnderTest.OrganizationCaseAssignmentRules.Case_Prep__c = CASE_ASSIGNMENT_RULE;
            ClassUnderTest.OrganizationCaseAssignmentRules.Fraud__c = CASE_ASSIGNMENT_RULE;
            ClassUnderTest.OrganizationCaseAssignmentRules.Underwriter__c = CASE_ASSIGNMENT_RULE;
            ClassUnderTest.OrganizationCaseAssignmentRules.Creation_Manual_Underwriting__c = CASE_ASSIGNMENT_RULE;
        }

        public void populateWithNotExistingValuesToCustomSettings() {
            ClassUnderTest.OrganizationCaseAssignmentRules.Case_Prep__c = 'nobody will call AR with UNDERSCORES!!!___';
        }

        public void createManualUnderwritingCases(CaseUtility.QueueName queue_name) {
            Id queue_id = CaseUtility.getInstance().getQueueIdFromName(queue_name);
            FeatureSwitch.disable('ZOPA-18');
            List<Case> cases = CaseBuilder.getBuilder(TestAccount)
                    .setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)
                    .setOwner(queue_id)
                    .setSubject('Manual Underwriting')
                    .getRecordList(BULK_SIZE);
            insert cases;
            TestCases = new Map<Id, Case>(cases);
        }

        private List<Case> reQueryCases() {
            return [SELECT RecordTypeId, Status, OwnerId FROM Case WHERE Id = :TestCases.keySet()];
        }

        public void assertPageMessage(String message) {
            for(Apexpages.Message page_message : ApexPages.getMessages()){
                if (page_message.getDetail().contains(message)) {
                    return;
                }
            }
            System.assert(false, 'No such message on page');
        }

        public void setSelectedAppLabel(String app_label) {
            ClassUnderTest.SelectedAppLabel = app_label;
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        User test_user = UserTestData.getUserForTest()
                .setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                .setLastName('TestLastName')
                .save()
                .getRecord();
    }
}