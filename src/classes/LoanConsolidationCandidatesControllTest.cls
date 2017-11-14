@isTest
private class LoanConsolidationCandidatesControllTest {

    static testMethod void testGetLoanConsolidationCandidatesSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanConsolidationCandidates();
            Test.stopTest();

            System.assertEquals(null, setup_data.ClassUnderTest.ErrorOnLoad, 'ErrorOnLoad is not set correctly');
            System.assertNotEquals(null, setup_data.ClassUnderTest.LoanConsolidationCandidates.ConfirmedConsolidationLoans, 'ConfirmedConsolidationLoans is not set correctly');
            System.assertEquals(3, setup_data.ClassUnderTest.LoanConsolidationCandidates.ConfirmedConsolidationLoans.size(), 'ConfirmedConsolidationLoans is not set correctly');
            System.assertEquals('ec97ddab-435b-4c97-8392-4b4747ea22cf', setup_data.ClassUnderTest.LoanConsolidationCandidates.ConfirmedConsolidationLoans.get(0).BorrowingId, 'BorrowingId is not set correctly');
            System.assertEquals(7000, setup_data.ClassUnderTest.LoanConsolidationCandidates.ConfirmedConsolidationLoans.get(0).RequestedAmount, 'RequestedAmount is not set correctly');
            System.assertEquals(3000, setup_data.ClassUnderTest.LoanConsolidationCandidates.ConfirmedConsolidationLoans.get(1).CapitalRemaining, 'CapitalRemaining is not set correctly');
            System.assertEquals(950, setup_data.ClassUnderTest.LoanConsolidationCandidates.ConfirmedConsolidationLoans.get(2).SettlementAmount, 'SettlementAmount is not set correctly');
            System.assertEquals(false, setup_data.ClassUnderTest.LoanConsolidationCandidates.ConfirmedConsolidationLoans.get(2).IsRepaymentPending, 'IsRepaymentPending is not set correctly');
        }
    }

    static testMethod void testGetLoanConsolidationCandidatesNotSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false);
            Test.startTest();
                setup_data.ClassUnderTest.getLoanConsolidationCandidates();
            Test.stopTest();
            System.assertEquals('Internal Server Error: Internal Error', setup_data.ClassUnderTest.ErrorOnLoad, 'ErrorOnLoad is not set correctly');
            System.assertEquals(null, setup_data.ClassUnderTest.LoanConsolidationCandidates, 'LoanConsolidationCandidates is not set correctly');
        }
    }

    static testMethod void testGetIsZopa81IsEnabledIfDisabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.disable('ZOPA-81');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa81IsEnabled();
            Test.stopTest();
            System.assertEquals(false, is_enabled, 'Should be false');
        }
    }

    static testMethod void testGetIsZopa81IsEnabledIfEnabled() {
        SetupDataClass setup_data = new SetupDataClass();
        FeatureSwitch.enable('ZOPA-81');
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            Test.startTest();
                Boolean is_enabled = setup_data.ClassUnderTest.getIsZopa81IsEnabled();
            Test.stopTest();
            System.assertEquals(true, is_enabled, 'Should be true');
        }
    }

    private class SetupDataClass {
        public LoanConsolidationCandidatesController ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'LoanConsolidationCandidatesControllTest' AND LastName = 'LoanConsolidationCandidatesControllTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new LoanConsolidationCandidatesController();
            ClassUnderTest.LoanAppId = 'ExtLoanId';
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanConsolidationCandidatesTestMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.TEAM_LEADER)
                                     .setFirstName('LoanConsolidationCandidatesControllTest')
                                     .setLastName('LoanConsolidationCandidatesControllTest')
                                     .save().getRecord();
    }
}