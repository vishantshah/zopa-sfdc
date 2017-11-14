@isTest
private class LoanStateDeceasedHelperTest {

    static testMethod void testChangeLoanStatusToRialtoToDeceasedSuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(true);
            Test.startTest();
                Boolean result_request = LoanStateDeceasedHelper.changeLoanStatusToRialtoToDeceased('test');
            Test.stopTest();
            System.assertEquals(true,result_request,'Should be true');
            System.assertEquals(new ApexPages.Message(ApexPages.Severity.INFO, 'Loan State was updated successfully'), ApexPages.getMessages()[0]);
        }
    }

    static testMethod void testChangeLoanStatusToRialtoToDeceasedUnsuccess() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.setMockForResponse(false);
            Test.startTest();
                Boolean result_request = LoanStateDeceasedHelper.changeLoanStatusToRialtoToDeceased('test');
            Test.stopTest();
            System.assertEquals(false,result_request,'Should be false');
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
            TestUser = [SELECT Id FROM User WHERE FirstName = 'LoanStateDeceasedHelperTest' AND LastName = 'LoanStateDeceasedHelperTest' LIMIT 1];
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandTestMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('LoanStateDeceasedHelperTest')
                                     .setLastName('LoanStateDeceasedHelperTest')
                                     .save();
    }
}