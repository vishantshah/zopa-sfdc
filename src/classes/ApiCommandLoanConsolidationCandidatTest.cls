@isTest
private class ApiCommandLoanConsolidationCandidatTest {
    private static final String UUID = 'sdgfqewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.LOAN_CONSOLIDATION_CANDIDATES, setup_data.ClassUnderTest.CommandName, 'CommandName should be initialized');
        }
    }

    static testMethod void testGetResponseSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, false);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                ApiCommandLoanConsolidationCandidates.LoanConsolidationCandidates loan_consolidation_candidates = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertNotEquals(null, loan_consolidation_candidates.ConfirmedConsolidationLoans, 'ConfirmedConsolidationLoans is not set correctly');
            System.assertEquals(3, loan_consolidation_candidates.ConfirmedConsolidationLoans.size(), 'ConfirmedConsolidationLoans is not set correctly');
            System.assertEquals('ec97ddab-435b-4c97-8392-4b4747ea22cf', loan_consolidation_candidates.ConfirmedConsolidationLoans.get(0).BorrowingId, 'BorrowingId is not set correctly');
            System.assertEquals(7000, loan_consolidation_candidates.ConfirmedConsolidationLoans.get(0).RequestedAmount, 'RequestedAmount is not set correctly');
            System.assertEquals(3000, loan_consolidation_candidates.ConfirmedConsolidationLoans.get(1).CapitalRemaining, 'CapitalRemaining is not set correctly');
            System.assertEquals(950, loan_consolidation_candidates.ConfirmedConsolidationLoans.get(2).SettlementAmount, 'SettlementAmount is not set correctly');
            System.assertEquals(false, loan_consolidation_candidates.ConfirmedConsolidationLoans.get(2).IsRepaymentPending, 'IsRepaymentPending is not set correctly');
        }
    }

    static testMethod void testGetResponseEmptyResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, true);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                ApiCommandLoanConsolidationCandidates.LoanConsolidationCandidates loan_consolidation_candidates = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertEquals(null, loan_consolidation_candidates.ConfirmedConsolidationLoans, 'ConfirmedConsolidationLoans is not set correctly');
        }
    }

    static testMethod void testHasPaymentPendingReturnTrue() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, false);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                ApiCommandLoanConsolidationCandidates.LoanConsolidationCandidates loan_consolidation_candidates = setup_data.ClassUnderTest.getResponse();
                Boolean has_payment_pending = setup_data.ClassUnderTest.hasPaymentPending();
            Test.stopTest();

            System.assertEquals(true, has_payment_pending, 'Candidates has pending payment');
        }
    }

    static testMethod void testHasPaymentPendingReturnFalse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, true);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                ApiCommandLoanConsolidationCandidates.LoanConsolidationCandidates loan_consolidation_candidates = setup_data.ClassUnderTest.getResponse();
                Boolean has_payment_pending = setup_data.ClassUnderTest.hasPaymentPending();
            Test.stopTest();

            System.assertEquals(false, has_payment_pending, 'Candidates doesnt have pending payment');
        }
    }

    static testMethod void testGetResponseNotSuccessResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(false, false);
            Test.startTest();
                ApiCommandsFactory.getInstance().performApiCommandCallout(setup_data.ClassUnderTest);
                ApiCommandLoanConsolidationCandidates.LoanConsolidationCandidates loan_consolidation_candidates = setup_data.ClassUnderTest.getResponse();
            Test.stopTest();

            System.assertEquals(false, setup_data.ClassUnderTest.CommandSuccessful, 'Command should have not been successful');
            System.assertEquals('Internal Server Error: Internal Error', setup_data.ClassUnderTest.CommandError, 'Got the wrong error');
        }
    }

    private class SetupDataClass {
        public ApiCommandLoanConsolidationCandidates ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandLoanConsolidationCandidatTest' AND LastName = 'ApiCommandLoanConsolidationCandidatTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandLoanConsolidationCandidates(UUID);
        }

        public void setMockForResponse(Boolean is_success, Boolean is_empty) {
            Test.setMock(HttpCalloutMock.class, new ApiLoanConsolidationCandidatesTestMock(is_success, is_empty));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.CASE_PREP)
                                     .setFirstName('ApiCommandLoanConsolidationCandidatTest')
                                     .setLastName('ApiCommandLoanConsolidationCandidatTest')
                                     .save();
    }
}