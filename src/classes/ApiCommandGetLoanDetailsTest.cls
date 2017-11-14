@IsTest
public class ApiCommandGetLoanDetailsTest {
    private static final String UUID = 'sdgfqewtddfafs';

    @IsTest
    static void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();
            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.GET_LOAN_DETAILS, setup_data.ClassUnderTest.CommandName, 'Uuid should be initialized');
        }
    }

    @IsTest
    static void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true, 200);
            ApiCommandGetLoanDetails.LoanDetails loan_details;
            Test.startTest();
                ApiCommandGetLoanDetails get_loan_details_command = new ApiCommandGetLoanDetails(UUID);
                ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_details_command);
                loan_details = get_loan_details_command.getResponse();
            Test.stopTest();

            System.assertEquals(0.0, loan_details.ArrearsBalance , 'ArrearsBalance was setted incorrect.');
            System.assertEquals(0.0, loan_details.ArrearsRatio , 'ArrearsRatio was setted incorrect.');
            System.assertEquals(12345.0, loan_details.EarlyRepaymentAmount , 'EarlyRepaymentAmount was setted incorrect.');
            System.assertEquals(0.0, loan_details.HoldingAccountBalance , 'HoldingAccountBalance was setted incorrect.');
            System.assertEquals(166.64750352, loan_details.MonthlyRepaymentAmount , 'MonthlyRepaymentAmount was setted incorrect.');
            System.assertEquals(0.0, loan_details.NextRepaymentAdjustment , 'NextRepaymentAdjustment was setted incorrect.');
            System.assertEquals(7665.78516896, loan_details.RemainingBalance , 'RemainingBalance was setted incorrect.');
            System.assertEquals(0.0, loan_details.ReplacementAmount , 'ReplacementAmount was setted incorrect.');
            System.assertEquals('Withdrawn', loan_details.State , 'State was setted incorrect.');
            System.assertEquals(7999.08016896, loan_details.TotalActualRepayableAmount , 'TotalActualRepayableAmount was setted incorrect.');
            System.assertEquals('22/02/2021', loan_details.LastRepaymentDate , 'LoanStartDate was setted incorrect.');
            System.assertEquals(22, loan_details.RepaymentDayofMonth , 'RepaymentDayofMonth was setted incorrect.');
            System.assertEquals(166.64750352, loan_details.FirstMonthRepaymentAmount , 'FirstMonthRepaymentAmount was setted incorrect.');
            System.assertEquals(0, loan_details.FirstMonthExtraDays , 'FirstMonthExtraDays was setted incorrect.');
        }
    }

    private class SetupDataClass {
        public ApiCommandGetLoanDetails ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandLoanDocumentsTest' AND LastName = 'ApiCommandLoanDocumentsTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandGetLoanDetails(UUID);
        }

        public void setMockForResponse(Boolean is_success, Integer code) {
            Test.setMock(HttpCalloutMock.class, new LoanDetailsViewMock(is_success, code));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandLoanDocumentsTest')
                                     .setLastName('ApiCommandLoanDocumentsTest')
                                     .save();
    }
}