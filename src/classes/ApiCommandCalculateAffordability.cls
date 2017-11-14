public class ApiCommandCalculateAffordability extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    DocumentClassificationResource CommandParameters;

    public ApiCommandCalculateAffordability(String uuid, Decimal confirmed_annual_income, Decimal monthly_net_income, Decimal confirmed_rent_mortgage, List<AffordabilityDetailsController.RollingCreditLine> monthly_payments, List<AffordabilityDetailsController.UnsecuredDebt> unsecured_debts) {
        super(ApiCommandsFactory.CALCULATE_AFFORDABILITY_COMMAND, uuid);
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

    public AffordabilityCalculationResponse getResponse(){
        String response_body = HttpApiResponse.getBody();
        return (AffordabilityCalculationResponse) System.JSON.deserialize(response_body, AffordabilityCalculationResponse.class);
    }

    private class DocumentClassificationResource {
        public Decimal ConfirmedAnnualIncome;
        public Decimal MonthlyNetIncome;
        public Decimal ConfirmedRentMortgage;
        public List<AffordabilityDetailsController.RollingCreditLine> RollingCreditLines;
        public List<AffordabilityDetailsController.UnsecuredDebt> UnsecuredDebts;
    }

    public class AffordabilityCalculationResponse {
        public Decimal LDTI;
        public Decimal DTI;
        public Decimal DI;
    }
}