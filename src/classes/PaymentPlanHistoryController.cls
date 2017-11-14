public with sharing class PaymentPlanHistoryController {
    public String LoanUuid {get; set;}
    public List<ApiCommandLoanGetPaymentPlans.PaymentPlan> ExistingPaymentPlans { get; set; }

    public PaymentPlanHistoryController() {
        ExistingPaymentPlans = new List<ApiCommandLoanGetPaymentPlans.PaymentPlan>();
    }

    public void getPaymentPlanHistory() {
        Boolean IsCorrectLoading = ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(LoanUuid);
        if (IsCorrectLoading) {
            ApiCommandLoanGetPaymentPlans get_payment_plans_command = new ApiCommandLoanGetPaymentPlans(LoanUuid);
            HttpResponse http_response = ApiCommandsFactory.getInstance().performApiCommandCallout(get_payment_plans_command);
            if (get_payment_plans_command.CommandSuccessful) {
                ExistingPaymentPlans = get_payment_plans_command.getResponse(http_response.getBody());
            } else {
                if (http_response.getStatusCode() == 404) {
                    MessageUtility.addInfoPageMessage('No Payment Plans were found for this loan.');
                } else {
                    MessageUtility.addErrorPageMessage(get_payment_plans_command.CommandError);
                }
            }
        }
    }
}