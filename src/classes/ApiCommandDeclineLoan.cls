public class ApiCommandDeclineLoan extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    private String DeclineReason;
    public ApiCommandDeclineLoan(String uuid, String reason) {
        super(ApiCommandsFactory.DECLINE_LOAN_COMMAND, uuid);
        DeclineReason = reason;
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(new DeclineLoanResource(DeclineReason));
    }

    private class DeclineLoanResource {
        public String DeclineReason;

        public DeclineLoanResource(String reason) {
            DeclineReason = reason;
        }
    }


    @TestVisible private static final Map<String, String> DECLINE_REASONS_LABEL_TO_API_NAMES = new Map<String, String> {
        'Insufficient Info' => 'InsufficientInfo',
        'Insufficient disposable income' => 'InsufficientDisposableIncome',
        'Inappropriate loan amount or purpose' => 'InappropriateLoanAmountOrPurpose',
        'Over-indebted (DTI if not B or C)' => 'OverIndebtedDtiIfNotBOrC',
        'Current arrears/appears in difficulty' => 'CurrentArrearsOrAppearsInDifficulty',
        'Poor attitude – missed payments' => 'PoorAttitudeMissedPayments',
        'Recession Sensitive' => 'RecessionSensitive',
        'Too much recent credit/over heating' => 'TooMuchRecentCreditOrOverHeating',
        'Suspicious Information' => 'SuspiciousInformation',
        'Failed ID checks' => 'FailedIdChecks',
        'Any other reason' => 'AnyOtherReason',
        'Unskilled/probation' => 'UnskilledOrProbation',
        'Pay Day Loan or Home Credit' => 'PayDayLoanOrHomeCredit',
        'Cash advances on credit cards' => 'CashAdvancesOnCreditCards',
        'Suspicious information-impersonation confirmed' => 'SuspiciousInformationImpersonationConfirmed',
        'Suspicious information-impersonation suspected' => 'SuspiciousInformationImpersonationSuspected'
    };

    public static List<SelectOption> getDeclineLoanReasonOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for (String label : DECLINE_REASONS_LABEL_TO_API_NAMES.keySet()) {
            options.add(new SelectOption(DECLINE_REASONS_LABEL_TO_API_NAMES.get(label), label));
        }
        return options;
    }
    public static Map<String, String> getDeclineReasonsApiNamesToLabelMap(){
        Map<String, String> api_names_to_label = new Map<String, String>();
        for(String reason_label : DECLINE_REASONS_LABEL_TO_API_NAMES.keySet()){
            api_names_to_label.put(DECLINE_REASONS_LABEL_TO_API_NAMES.get(reason_label), reason_label);
        }
        return api_names_to_label;
    }
}