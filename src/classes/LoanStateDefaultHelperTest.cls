@isTest
private class LoanStateDefaultHelperTest {
    private static final String UUID = 'test_uuid';
    private static final String DEFAULT_REASON = 'test_default_reason';

    static testMethod void testChangeLoanStatusToRialtoToDeceasedSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            Test.startTest();
                Boolean result_request = LoanStateDefaultHelper.changeLoanStatusToRialtoToDefault(UUID, DEFAULT_REASON);
            Test.stopTest();
            System.assertEquals(true, result_request, 'Should be true');
            String expected_message = 'Make Default request has been sent successfully!';
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact(expected_message),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    static testMethod void testChangeLoanStatusToRialtoToDeceasedUnsuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(false);
            Test.startTest();
                Boolean result_request = LoanStateDefaultHelper.changeLoanStatusToRialtoToDefault(UUID, DEFAULT_REASON);
            Test.stopTest();
            System.assertEquals(false, result_request, 'Should be false');
            System.assertEquals(
                    true,
                    MessageUtility.checkCurrentPageContainsExact('Request error: Internal issues.'),
                    'Didnt find the expected message on the page. Got: ' + MessageUtility.getAllPageMessagesDetailForCurrentPage()
            );
        }
    }

    private class SetupDataClass {
        public User TestUser;

        public SetupDataClass() {
            TestUser = [SELECT Id FROM User WHERE FirstName = 'LoanStateDefaultHelperTest' AND LastName = 'LoanStateDefaultHelperTest' LIMIT 1];
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('LoanStateDefaultHelperTest')
                                     .setLastName('LoanStateDefaultHelperTest')
                                     .save();
    }
}