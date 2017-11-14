@isTest
public class ApiCommandLoanGetPaymentPlansTest {
    private static final String UUID = 'sdgfqewtddfafs';

    @IsTest
    static void testInitClassUnderTest() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {

            Test.startTest();
                setup_data.initClassUnderTest();
            Test.stopTest();

            System.assertEquals(UUID, setup_data.ClassUnderTest.RecordUuid, 'Uuid should be initialized');
            System.assertEquals(ApiCommandsFactory.LOAN_GET_PAYMENT_PLANS, setup_data.ClassUnderTest.CommandName, 'Class under test must have another command name in it');
        }
    }

    @IsTest
    static void testBuildJsonBodyPositiveResponse() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            setup_data.initClassUnderTest();
            setup_data.setMockForResponse(true);
            List<ApiCommandLoanGetPaymentPlans.PaymentPlan> payment_plans;

            Test.startTest();
                ApiCommandLoanGetPaymentPlans get_payment_plans_command = new ApiCommandLoanGetPaymentPlans(UUID);
                HttpResponse http_response = ApiCommandsFactory.getInstance().performApiCommandCallout(get_payment_plans_command);
                payment_plans = get_payment_plans_command.getResponse(http_response.getBody());
            Test.stopTest();

            System.assertEquals(3, payment_plans.size(), 'If response is positive, list of payment plans must contain 3 payment plans (as in the mock)');
            for(ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan : payment_plans){
                System.assertEquals(false, String.isEmpty(payment_plan.PaymentPlanId), 'PaymentPlanId must not be null.');
                System.assertEquals(false, String.isEmpty(payment_plan.Duration), 'Duration must not be null.');
                System.assertEquals(false, String.isEmpty(payment_plan.Arrangement), 'Arrangement must not be null.');
                System.assertEquals(false, String.isEmpty(String.valueOf(payment_plan.CreatedDate)), 'CreatedDate must not be null.');
                System.assertEquals(false, String.isEmpty(String.valueOf(payment_plan.Amount)), 'Amount must not be null.');
                System.assertEquals(false, String.isEmpty(payment_plan.Frequency), 'Frequency must not be null.');
                System.assertEquals(false, String.isEmpty(String.valueOf(payment_plan.PaymentDay)), 'PaymentDay must not be null.');
                System.assertEquals(false, String.isEmpty(payment_plan.Method), 'Method must not be null.');
                System.assertEquals(false, String.isEmpty(payment_plan.ArrearsReason), 'ArrearsReason must not be null.');
                System.assertEquals(false, String.isEmpty(payment_plan.State), 'State must not be null.');
            }
        }
    }

    @IsTest
    static void testPaymentPlanEqualPositive() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan = new ApiCommandLoanGetPaymentPlans.PaymentPlan('payment_plan_id', 'duration', 'arrangement', Datetime.now(), 100.01, 'frequency', '10', 'method', 'arrears_reason', 'state', Datetime.now());
            ApiCommandLoanGetPaymentPlans.PaymentPlan equal_payment_plan = payment_plan.Clone();

            Test.startTest();
                Boolean result = payment_plan.equal(equal_payment_plan);
            Test.stopTest();

            System.assertEquals(true, result, 'This method must return true because two payment plans has all fields set to same values');
        }
    }

    @IsTest
    static void testPaymentPlanEqualNegative() {
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser) {
            ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan = new ApiCommandLoanGetPaymentPlans.PaymentPlan('payment_plan_id', 'duration', 'arrangement', Datetime.now(), 100.01, 'frequency', '10', 'method', 'arrears_reason', 'state', Datetime.now());
            ApiCommandLoanGetPaymentPlans.PaymentPlan not_equal_payment_plan = payment_plan.Clone();
            not_equal_payment_plan.PaymentPlanId = 'Some another value';

            Test.startTest();
                Boolean result = payment_plan.equal(not_equal_payment_plan);
            Test.stopTest();

            System.assertEquals(false, result, 'This method must return false because two payment plans has different payment plan ids');
        }
    }

    private class SetupDataClass {
        public ApiCommandLoanGetPaymentPlans ClassUnderTest;
        public User TestUser;

        public SetupDataClass(){
            TestUser = [SELECT Id FROM User WHERE FirstName = 'ApiCommandLoanGetPaymentPlansTest' AND LastName = 'ApiCommandLoanGetPaymentPlansTest' LIMIT 1];
        }

        public void initClassUnderTest() {
            ClassUnderTest = new ApiCommandLoanGetPaymentPlans(UUID);
        }

        public void setMockForResponse(Boolean is_success) {
            Test.setMock(HttpCalloutMock.class, new ApiCommandLoanPaymentPlansTestMock(is_success));
        }
    }

    @testSetup static void createAndInsertTestData() {
        UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.SYSADMIN)
                                     .setFirstName('ApiCommandLoanGetPaymentPlansTest')
                                     .setLastName('ApiCommandLoanGetPaymentPlansTest')
                                     .save();
    }
}