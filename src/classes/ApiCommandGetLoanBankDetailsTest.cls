@IsTest
public class ApiCommandGetLoanBankDetailsTest {
    private static final String UUID = 'sdgfqewtddfafs';

    @IsTest
    static void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.GET_BANK_LOAN_DETAILS, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }

    @IsTest
    static void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, 200);
            ApiCommandGetLoanBankDetails.BankDetails loan_details;
            Test.startTest();
                ApiCommandGetLoanBankDetails get_loan_details_command = new ApiCommandGetLoanBankDetails(UUID);
                ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_details_command);
                loan_details = get_loan_details_command.getResponse();
            Test.stopTest();
            System.assertEquals('test', loan_details.AccountNumber , 'AccountNumber was setted incorrect.');
            System.assertEquals('test', loan_details.SortCode , 'SortCode was setted incorrect.');
            System.assertEquals('test', loan_details.AccountHolderName , 'AccountHolderName was setted incorrect.');
            System.assertEquals('test', loan_details.Reference , 'Reference was setted incorrect.');
            System.assertEquals('test', loan_details.BankName , 'BankName was setted incorrect.');
            System.assertEquals('test', loan_details.DirectDebitStatus , 'DirectDebitStatus was setted incorrect.');
        }
    }

    private class SetupDataClass {
        public ApiCommandGetLoanBankDetails ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandLoanDocumentsTest' AND LastName = 'ApiCommandLoanDocumentsTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandGetLoanBankDetails(UUID);
        }

        public void setMockForResponse(Boolean is_success, Integer code) {
            Test.setMock(HttpCalloutMock.class, new LoanBankDetailsViewMock(is_success, code));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandLoanDocumentsTest')
                                     .setLastName('ApiCommandLoanDocumentsTest')
                                     .save();
    }
}