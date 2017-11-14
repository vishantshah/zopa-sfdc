@isTest
private class CaseInitialUnderwriterPopulationHelpTest {

    static testMethod void testInitCaseInitialUnderwriterPopulationHelperPopulatesOwnersMap() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-23');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(1, setup_data.ClassUnderTest.OwnerIdToProfileId.size(), 'Should have one pair for TestUser');
            System.assertEquals(new Set<Id>{setup_data.TestUser.Id}, setup_data.ClassUnderTest.OwnerIdToProfileId.keySet(), 'Should have key - current ownerId');
            System.assertEquals(setup_data.TestUser.ProfileId, setup_data.ClassUnderTest.OwnerIdToProfileId.get(setup_data.TestUser.Id), 'Should have value - profile Id');
        }
    }

    static testMethod void testPopulateInitialUnderwriterForFirstUnderwriterOwner() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-23');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.assignToUserNewCase(setup_data.TestUnderwriterUser.Id);
            setup_data.initClassUnderTest();
            setup_data.setOwnerMapForClassUnderTest(setup_data.TestUnderwriterUser);
            Test.startTest();
                setup_data.ClassUnderTest.populateInitialUnderwriterForFirstUnderwriterOwner(setup_data.TestCase, setup_data.TestNewCase);
            Test.stopTest();
            System.assertEquals(setup_data.TestUnderwriterUser.Id, setup_data.TestNewCase.Initial_Underwriter__c, 'Should populate value from new owner id');
        }
    }

    static testMethod void testPopulateInitialUnderwriterForFirstFraudOwner() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-23');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.assignToUserNewCase(setup_data.TestFraudUser.Id);
            setup_data.initClassUnderTest();
            setup_data.setOwnerMapForClassUnderTest(setup_data.TestFraudUser);
            Test.startTest();
                setup_data.ClassUnderTest.populateInitialUnderwriterForFirstUnderwriterOwner(setup_data.TestCase, setup_data.TestNewCase);
            Test.stopTest();
            System.assertEquals(setup_data.TestFraudUser.Id, setup_data.TestNewCase.Initial_Underwriter__c, 'Should populate value from new owner id');
        }
    }

    static testMethod void testPopulateInitialUnderwriterForFirstUWTeamLeadOwner() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-23');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.assignToUserNewCase(setup_data.TestUWTeamLeaderUser.Id);
            setup_data.initClassUnderTest();
            setup_data.setOwnerMapForClassUnderTest(setup_data.TestUWTeamLeaderUser);
            Test.startTest();
                setup_data.ClassUnderTest.populateInitialUnderwriterForFirstUnderwriterOwner(setup_data.TestCase, setup_data.TestNewCase);
            Test.stopTest();
            System.assertEquals(setup_data.TestUWTeamLeaderUser.Id, setup_data.TestNewCase.Initial_Underwriter__c, 'Should populate value from new owner id');
        }
    }


    static testMethod void testUpdatePopulationDateIfInitialUnderwriterChanged(){
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-23');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.assignToUserNewCase(setup_data.TestFraudUser.Id);
            setup_data.initClassUnderTest();
            setup_data.setOwnerMapForClassUnderTest(setup_data.TestFraudUser);
            Test.startTest();
                setup_data.ClassUnderTest.populateInitialUnderwriterForFirstUnderwriterOwner(setup_data.TestCase, setup_data.TestNewCase);
                setup_data.ClassUnderTest.updatePopulationDateIfInitialUnderwriterChanged(setup_data.TestCase, setup_data.TestNewCase);
            Test.stopTest();
            System.assertEquals(setup_data.TestFraudUser.Id, setup_data.TestNewCase.Initial_Underwriter__c, 'Should populate value from new owner id');
            System.assertNotEquals(setup_data.TestCase.Initial_Underwriter_Date__c, setup_data.TestNewCase.Initial_Underwriter_Date__c,'Date in new_case(' + setup_data.TestNewCase.Initial_Underwriter_Date__c  + ') should not be to date in old_case' + setup_data.TestCase.Initial_Underwriter_Date__c);
        }
    }

    static testMethod void testIsManualUnderwritingCaseForManualUnderwritingCase() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-23');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_true = setup_data.ClassUnderTest.isManualUnderwritingCase(setup_data.TestNewCase);
            Test.stopTest();
            System.assertEquals(true, is_true, 'Should return true for Manual Underwriting Case');
        }
    }

    static testMethod void testIsPickedByUnderwriterOrFraudOrUWTeamLeaderForUnderwriter() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-23');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.assignToUserNewCase(setup_data.TestUnderwriterUser.Id);
            setup_data.initClassUnderTest();
            setup_data.setOwnerMapForClassUnderTest(setup_data.TestUnderwriterUser);
            Test.startTest();
                Boolean is_true = setup_data.ClassUnderTest.isPickedByUnderwriterOrFraudOrUWTeamLead(setup_data.TestUnderwriterUser.Id);
            Test.stopTest();
            System.assertEquals(true, is_true, 'Should return true for Underwriter User');
        }
    }

    static testMethod void testIsPickedByUnderwriterOrFraudOrUWTeamLeaderForFraud() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-23');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.assignToUserNewCase(setup_data.TestFraudUser.Id);
            setup_data.initClassUnderTest();
            setup_data.setOwnerMapForClassUnderTest(setup_data.TestFraudUser);
            Test.startTest();
                Boolean is_true = setup_data.ClassUnderTest.isPickedByUnderwriterOrFraudOrUWTeamLead(setup_data.TestFraudUser.Id);
            Test.stopTest();
            System.assertEquals(true, is_true, 'Should return true for Fraud User');
        }
    }

    static testMethod void testIsPickedByUnderwriterOrFraudOrUWTeamLeaderForUWTeamLead() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-23');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.assignToUserNewCase(setup_data.TestUWTeamLeaderUser.Id);
            setup_data.initClassUnderTest();
            setup_data.setOwnerMapForClassUnderTest(setup_data.TestUWTeamLeaderUser);
            Test.startTest();
                Boolean is_true = setup_data.ClassUnderTest.isPickedByUnderwriterOrFraudOrUWTeamLead(setup_data.TestUWTeamLeaderUser.Id);
            Test.stopTest();
            System.assertEquals(true, is_true, 'Should return true for Fraud User');
        }
    }

    static testMethod void testIsPickedByUnderwriterForAnotherUser() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-23');
        System.runAs(setup_data.TestUser) {
            setup_data.createManualUnderwritingCase();
            setup_data.assignToUserNewCase(setup_data.TestUnderwriterUser.Id);
            setup_data.initClassUnderTest();
            setup_data.setOwnerMapForClassUnderTest(setup_data.TestUser);
            Test.startTest();
                Boolean is_true = setup_data.ClassUnderTest.isPickedByUnderwriterOrFraudOrUWTeamLead(setup_data.TestUser.Id);
            Test.stopTest();
            System.assertEquals(false, is_true, 'Should return false for Non-Underwriter User');
        }
    }


    private class SetupDataClass {
        public Case TestCase;
        public Case TestNewCase;
        public User TestUser;
        public User TestUnderwriterUser;
        public User TestFraudUser;
        public User TestUWTeamLeaderUser;
        public CaseInitialUnderwriterPopulationHelper ClassUnderTest;
        public Account TestAccount;
        public Loan_Application__c TestLoanApplication;

        public SetupDataClass() {
            TestUser = [SELECT Id, ProfileId FROM User WHERE LastName = 'CaseInitialUnderwriterPopulationHelpTest' AND FirstName = 'SYSADMIN' LIMIT 1];
            TestUnderwriterUser = [SELECT Id, ProfileId FROM User WHERE LastName = 'CaseInitialUnderwriterPopulationHelpTest' AND FirstName = 'UNDERWITER' LIMIT 1];
            TestUWTeamLeaderUser = [SELECT Id, ProfileId FROM User WHERE LastName = 'CaseInitialUnderwriterPopulationHelpTest' AND FirstName = 'UW Team Lead' LIMIT 1];
            TestFraudUser = [SELECT Id, ProfileId FROM User WHERE LastName = 'CaseInitialUnderwriterPopulationHelpTest' AND FirstName = 'FRAUD' LIMIT 1];
            TestAccount = [SELECT Id, Name, PersonContactId FROM Account LIMIT 1];
            TestLoanApplication = [SELECT Id FROM Loan_Application__c LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = CaseInitialUnderwriterPopulationHelper.getInstance(new Map<Id, Case>(new List<Case>{TestNewCase}));
        }

        public void setOwnerMapForClassUnderTest(User user) {
            ClassUnderTest.OwnerIdToProfileId = new Map<Id, Id>{user.Id => user.ProfileId};
        }

        public void createManualUnderwritingCase() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setSubject('CaseInitialUnderwriterPopulationHelpTest').setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
            TestNewCase = TestCase.clone(true, true);
        }

         public void createManualUnderwritingCaseWithFilledInitialUnderwriter() {
            TestCase = CaseBuilder.getBuilder(TestAccount).setSubject('CaseInitialUnderwriterPopulationHelpTest').setInitialUnderwriter(TestUser.Id).setLoanApplication(TestLoanApplication).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING).save().getRecord();
            TestNewCase = TestCase.clone(true, true);
        }

        public void assignToUserNewCase(Id user_id) {
            TestNewCase.OwnerId = user_id;
        }
    }

    @testSetup
    static void createAndInsertTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                                     .setFirstName('UNDERWITER')
                                     .setLastName('CaseInitialUnderwriterPopulationHelpTest')
                                     .save();
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.FRAUD)
                                     .setFirstName('FRAUD')
                                     .setLastName('CaseInitialUnderwriterPopulationHelpTest')
                                     .save();
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.TEAM_LEADER)
                                     .setFirstName('UW Team Lead')
                                     .setLastName('CaseInitialUnderwriterPopulationHelpTest')
                                     .save().getRecord();
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('SYSADMIN')
                                     .setLastName('CaseInitialUnderwriterPopulationHelpTest')
                                     .save().getRecord();
        System.runAs(test_user) {
            Account test_account = AccountBuilder.getBuilder('CaseInitialUnderwriterPopulationHelpTest').save().getRecord();
            FeatureSwitch.disable('ZOPA-4');
            LoanApplicationBuilder.getBuilder(test_account).save();
        }
    }
}