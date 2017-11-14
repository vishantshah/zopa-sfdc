@isTest
private class OmniChannelHandlerTest {

    static testMethod void testChangeStatusToInProgressDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            FeatureSwitch.disable(new Set<String>{'ZOPA-16', 'ZCP-74'});
            setup_data.createManualUnderwritingCaseForUnderwriter();
            Test.startTest();
                OmniChannelHandler.changeStatusToInProgress(setup_data.TestCase, setup_data.UnderwriterProfileId);
            Test.stopTest();
            System.assertNotEquals('In Progress', setup_data.TestCase.Status, 'Should be same value');
        }
    }

    static testMethod void testChangeStatusToInProgress() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            FeatureSwitch.enable(new Set<String>{'ZOPA-16', 'ZCP-74'});
            setup_data.createManualUnderwritingCaseForUnderwriter();
            Test.startTest();
                OmniChannelHandler.changeStatusToInProgress(setup_data.TestCase, setup_data.UnderwriterProfileId);
            Test.stopTest();
            System.assertEquals('In Progress', setup_data.TestCase.Status, 'Should be same value');
        }
    }

    static testMethod void testFillInitialUnderwriterField() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            FeatureSwitch.enable('ZOPA-23');
            setup_data.createManualUnderwritingCaseForUnderwriter();
            Test.startTest();
                OmniChannelHandler.fillInitialUnderwriterField(setup_data.TestCase);
            Test.stopTest();
            System.assertEquals(setup_data.TestUser.Id, setup_data.TestCase.Initial_Underwriter__c, 'Should be same value');
        }
    }

    static testMethod void testFillInitialUnderwriterFieldDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            FeatureSwitch.disable('ZOPA-23');
            setup_data.createManualUnderwritingCaseForUnderwriter();
            Test.startTest();
                OmniChannelHandler.fillInitialUnderwriterField(setup_data.TestCase);
            Test.stopTest();
            System.assertEquals(setup_data.TestUser.Id, setup_data.TestCase.Initial_Underwriter__c, 'Should be same value');
        }
    }

    static testMethod void testChangeStatusToInProgressForCollectionsRecoveriesCase() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            FeatureSwitch.enable(new Set<String>{'ZOPA-16', 'ZCP-74'});
            setup_data.createCollectionsRecoveriesCase();
            setup_data.TestCase.Status = 'New';
            Test.startTest();
                OmniChannelHandler.changeStatusToInProgress(setup_data.TestCase, setup_data.UnderwriterProfileId);
            Test.stopTest();
            System.assertEquals('In Progress', setup_data.TestCase.Status, 'Should be same value');
        }
    }

    static testMethod void testPopulateInitialUnderwriterWithUnderwriterPrifile() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            FeatureSwitch.enable('ZOPA-23');
            setup_data.createManualUnderwritingCaseForUnderwriter();
            Test.startTest();
                OmniChannelHandler.populateInitialUnderwriter(setup_data.TestCase, setup_data.UnderwriterProfileId);
            Test.stopTest();
            System.assertEquals(setup_data.TestUser.Id, setup_data.TestCase.Initial_Underwriter__c, 'Should equals Id');
        }
    }

    static testMethod void testPopulateInitialUnderwriterWithFraundPrifile() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            FeatureSwitch.enable('ZOPA-23');
            setup_data.createManualUnderwritingCaseForUnderwriter();
            Test.startTest();
                OmniChannelHandler.populateInitialUnderwriter(setup_data.TestCase, setup_data.FraudProfileId);
            Test.stopTest();
            System.assertEquals(setup_data.TestUser.Id, setup_data.TestCase.Initial_Underwriter__c, 'Should equals Id');
        }
    }

    static testMethod void testPopulateInitialUnderwriterWithStandartUserPrifile() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            FeatureSwitch.enable('ZOPA-23');
            setup_data.createManualUnderwritingCaseForUnderwriter();
            Test.startTest();
                OmniChannelHandler.populateInitialUnderwriter(setup_data.TestCase, setup_data.StandartUserProfileId);
            Test.stopTest();
            System.assertEquals(null, setup_data.TestCase.Initial_Underwriter__c, 'Should equals Id');
        }
    }

    private class SetupDataClass {
        public Case TestCase;
        public User TestUser;
        public Id UnderwriterProfileId;
        public Id FraudProfileId;
        public Id StandartUserProfileId;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE LastName = 'OmniChannelUnderwriting' LIMIT 1];
            UnderwriterProfileId = ProfileUtilities.getInstance().getProfileIdForType(ProfileUtilities.ProfileType.UNDERWRITER);
            FraudProfileId = ProfileUtilities.getInstance().getProfileIdForType(ProfileUtilities.ProfileType.FRAUD);
            StandartUserProfileId = ProfileUtilities.getInstance().getProfileIdForType(ProfileUtilities.ProfileType.STANDARD_USER);
        }

        public void createManualUnderwritingCaseForUnderwriter() {
            Account test_account = AccountBuilder.getBuilder('OmniChannelUnderwriting').save().getRecord();
            TestCase = CaseBuilder.getBuilder(test_account).setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)
                                                          .setOwner(TestUser.Id).save().getRecord();
            queryCase();
        }

        public void createCollectionsRecoveriesCase() {
            Account test_account = AccountBuilder.getBuilder('OmniChannelUnderwriting').save().getRecord();
            TestCase = CaseBuilder.getBuilder(test_account).setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                                                          .setOwner(TestUser.Id).save().getRecord();
            queryCase();
        }

        private void queryCase() {
            TestCase = [SELECT Initial_Underwriter__c, RecordTypeId, Status, Owner.Profile.Name
                        FROM Case WHERE Id = :TestCase.Id];
        }
    }

    @testSetup
    static void setupTestUser() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.UNDERWRITER)
                                     .setFirstName('OmniChannelUnderwriting'+Utility.getRandomInteger())
                                     .setLastName('OmniChannelUnderwriting')
                                     .save();
    }
}