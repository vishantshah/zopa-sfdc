public class ApiCommandLoanPutPaymentPlans extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    private ApiCommandLoanGetPaymentPlans.PaymentPlan PaymentPlan;

    public ApiCommandLoanPutPaymentPlans(String uuid, ApiCommandLoanGetPaymentPlans.PaymentPlan payment_plan) {
        super(ApiCommandsFactory.LOAN_PUT_PAYMENT_PLANS, uuid);
        PaymentPlan = payment_plan;
    }

    override protected ApiCommandAbstractBuilder setEndpoint(String endpoint) {
        HttpApiRequest.setEndpoint(endpoint.replace('{paymentPlanId}', PaymentPlan.PaymentPlanId));
        return this;
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(PaymentPlan);
    }
}