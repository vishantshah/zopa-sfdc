@isTest
private class ApiLoanDataProviderTest {
    private static final String TEST_LOAN_UUID = 'asdfa';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest(TEST_LOAN_UUID);
            Test.stopTest();
            System.assertEquals(TEST_LOAN_UUID, setup_data.ClassUnderTest.LoanUuid, 'Should be initialized');
            System.assertEquals(TEST_LOAN_UUID, ApiLoanDataProvider.Self.LoanUuid, 'Should init provider for this Id');
        }
    }

    static testMethod void testGetDataSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(TEST_LOAN_UUID);
            setup_data.setMockForResponse(true);
            Test.startTest();
                List<ApiResponseLoanInformation.ZopaLoanHistory> parsed_body = setup_data.ClassUnderTest.getData();
            Test.stopTest();
            System.assertEquals(JSON.serialize(setup_data.getExpectedResponse()), JSON.serialize(parsed_body), 'Should return initialized instance');
        }
    }

    static testMethod void testGetDataUnsuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest(TEST_LOAN_UUID);
            setup_data.setMockForResponse(false);
            Test.startTest();
                List<ApiResponseLoanInformation.ZopaLoanHistory> parsed_body = setup_data.ClassUnderTest.getData();
            Test.stopTest();
            System.assertEquals(null, parsed_body, 'Should return null');
            System.assertEquals('Bad request. Internal Error', setup_data.ClassUnderTest.ErrorOnExecution, 'Should fill error');
        }
    }

    private class SetupDataClass {
        public ApiLoanDataProvider ClassUnderTest;
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiLoanDataProviderTest' AND LastName = 'ApiLoanDataProviderTest' LIMIT 1];
        }

        public void initClassUnderTest(String loan_uuid) {
            ApiCommandsFactory.ApiCommandAbstractBuilder test_command = new ApiCommandLoanLitigationDetails(loan_uuid);
            ClassUnderTest = ApiLoanDataProvider.getInstance(loan_uuid, test_command);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new LoanRepaymentMock(is_success, 200));
        }

        public List<ApiResponseLoanInformation.ZopaLoanHistory> getExpectedResponse() {
            return ApiResponseLoanInformation.parse(LoanRepaymentMock.getMockResponceBody());
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiLoanDataProviderTest')
                                     .setLastName('ApiLoanDataProviderTest')
                                     .save();
    }
}