@isTest
private class ApiResponseLoanInformationTest {

    static testMethod void testParseJsonResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                List<ApiResponseLoanInformation.ZopaLoanHistory> correct_list = ApiResponseLoanInformation.parse(setup_data.getValidJsonResponse());
            Test.stopTest();
            System.assert(correct_list != null, 'Object should be exist');
            System.assertEquals(2, correct_list.size(), 'Should be equals size');
            System.assertEquals('2017-02-01T18:04:08.3873373+00:00', correct_list[0].RepaymentDate, 'Should be correct value');
            System.assertEquals('2017-02-03T18:04:08.3873373+00:00', correct_list[0].ReceivedDate, 'Should be correct value');
            System.assertEquals('Regular', correct_list[0].Type, 'Should be correct value');
            System.assertEquals(123.45, correct_list[0].Amount, 'Should be correct value');
            System.assertEquals('Paid', correct_list[0].Status, 'Should be correct value');
            System.assertEquals(true, correct_list[0].CountsAsNormalRepayment, 'Should be correct value');
            System.assertEquals(false, correct_list[0].ThirdPartyFlag, 'Should be correct value');
            System.assertEquals('2017-02-01T18:04:08.3873373+00:00', correct_list[1].RepaymentDate, 'Should be correct value');
            System.assertEquals('2017-02-03T18:04:08.3873373+00:00', correct_list[1].ReceivedDate, 'Should be correct value');
            System.assertEquals('Replacement', correct_list[1].Type, 'Should be correct value');
            System.assertEquals(136.45, correct_list[1].Amount, 'Should be correct value');
            System.assertEquals('FailDoneNoDD', correct_list[1].Status, 'Should be correct value');
            System.assertEquals(false, correct_list[1].CountsAsNormalRepayment, 'Should be correct value');
            System.assertEquals(true, correct_list[1].ThirdPartyFlag, 'Should be correct value');
        }
    }

    private class SetupDataClass {
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiResponseLoanInformationTest' AND LastName = 'ApiResponseLoanInformationTest' LIMIT 1];
        }

        public string getValidJsonResponse() {
            return LoanRepaymentMock.getMockResponceBody();
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiResponseLoanInformationTest')
                                     .setLastName('ApiResponseLoanInformationTest')
                                     .save();
    }
}