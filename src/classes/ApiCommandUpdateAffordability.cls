public class ApiCommandUpdateAffordability extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    DocumentClassificationResource CommandParameters;

    public ApiCommandUpdateAffordability(String uuid, Decimal confirmed_annual_income, Decimal monthly_net_income, Decimal confirmed_rent_mortgage, List<AffordabilityDetailsController.RollingCreditLine> monthly_payments, List<AffordabilityDetailsController.UnsecuredDebt> unsecured_debts) {
        super(ApiCommandsFactory.UPDATE_AFFORDABILITY_COMMAND, uuid);
        CommandParameters = new DocumentClassificationResource();
        CommandParameters.ConfirmedAnnualIncome = confirmed_annual_income;
        CommandParameters.MonthlyNetIncome = monthly_net_income;
        CommandParameters.ConfirmedRentMortgage = confirmed_rent_mortgage;
        CommandParameters.RollingCreditLines = monthly_payments;
        CommandParameters.UnsecuredDebts = unsecured_debts;
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(CommandParameters);
    }

    private class DocumentClassificationResource {
        public Decimal ConfirmedAnnualIncome;
        public Decimal MonthlyNetIncome;
        public Decimal ConfirmedRentMortgage;
        public List<AffordabilityDetailsController.RollingCreditLine> RollingCreditLines;
        public List<AffordabilityDetailsController.UnsecuredDebt> UnsecuredDebts;
    }
}