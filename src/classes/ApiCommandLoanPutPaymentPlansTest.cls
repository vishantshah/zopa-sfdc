@isTest
public class ApiCommandLoanPutPaymentPlansTest {
    private static final String UUID = 'sdgfqfyewtddfafs';

    static testMethod void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();

            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.LOAN_PUT_PAYMENT_PLANS, setup_data.ClassUnderTest.CommandName, 'Class under test must have another command name in it');
        }
    }

    static testMethod void testBuildJsonBody() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();

            Test.startTest();
                String body = setup_data.ClassUnderTest.buildJsonBody();
            Test.stopTest();

            String expected_body = JSON.serialize(setup_data.PaymentPlan);
            System.assertEquals(expected_body, body, 'The body isn\'t correct');
        }
    }

    private class SetupDataClass {
        public ApiCommandLoanPutPaymentPlans ClassUnderTest;
        public User TestUser;
        public ApiCommandLoanGetPaymentPlans.PaymentPlan PaymentPlan;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandLoanPutPaymentPlansTest' AND LastName = 'ApiCommandLoanPutPaymentPlansTest' LIMIT 1];
        }

        public void createPaymentPlan(){
            PaymentPlan = new ApiCommandLoanGetPaymentPlans.PaymentPlan('2a961acf-fe97-479d-8ed9-ab8d04966736', 'ThreeMonths', 'Zopa', Datetime.now(), 120.12, 'Monthly', '10', 'BACS', 'Mismanagement', 'Active', null);
        }

        public void initClassUnderTest() {
            createPaymentPlan();
            ClassUnderTest = new ApiCommandLoanPutPaymentPlans(UUID, PaymentPlan);
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandLoanPutPaymentPlansTest')
                                     .setLastName('ApiCommandLoanPutPaymentPlansTest')
                                     .save();
    }
}