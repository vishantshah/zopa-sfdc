@isTest
private class ApiResponseLoanCommonInformationTest {

    static testMethod void testParseJsonResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                ApiResponseLoanCommonInformation obj = ApiResponseLoanCommonInformation.parse(setup_data.getValidJsonResponse());
            Test.stopTest();
            System.assert(obj != null);
        }
    }

    private class SetupDataClass {
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiResponseLoanCommonInformationTest' AND LastName = 'ApiResponseLoanCommonInformationTest' LIMIT 1];
        }

        public string getValidJsonResponse() {
            return ApiLoanInfoTestMock.getTestJsonBody();
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiResponseLoanCommonInformationTest')
                                     .setLastName('ApiResponseLoanCommonInformationTest')
                                     .save();
    }
}