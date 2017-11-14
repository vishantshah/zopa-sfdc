public with sharing class ApiCommandLoanPostPaymentPlans extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    private ApiCommandLoanGetPaymentPlans.PaymentPlan PaymentPlan;

    public ApiCommandLoanPostPaymentPlans(String uuid, ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan) {
        super(ApiCommandsFactory.LOAN_POST_PAYMENT_PLANS, uuid);
        PaymentPlan = payment_plan;
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(PaymentPlan);
    }
}