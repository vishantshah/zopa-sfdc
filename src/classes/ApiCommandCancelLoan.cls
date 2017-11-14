public class ApiCommandCancelLoan extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    private String CancelReason;
    public ApiCommandCancelLoan(String uuid, String reason) {
        super(ApiCommandsFactory.CANCEL_LOAN_COMMAND, uuid);
        CancelReason = reason;
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(new CancelLoanResource(CancelReason, 'Test request'));
    }

    private class CancelLoanResource {
        public String CancellationReason;
        public String CancellationExplanation;

        public CancelLoanResource(String reason, String explanation) {
            CancellationReason = reason;
            CancellationExplanation = explanation;
        }
    }

    @TestVisible
    private static final Map<String, String> CANCEL_REASONS_LABEL_TO_API_NAMES = new Map<String, String> {
        'Cheaper deal elsewhere' => 'CHEAPER_LOAN',
        'Zopa took too long' => 'TOOK_TOO_LONG',
        'Used an alternative source for the funds' => 'ALT_SOURCE',
        'Couldn’t/wouldn’t/didn’t send supporting paperwork' => 'NO_PAPERWORK',
        'Changed their mind' => 'DIDNT_NEED_LOAN',
        'No contact from member' => 'NO_CONTACT',
        'Reason not given' => 'OTHER',
        'Other' => 'OTHER',
        'Applicant re-applying – new loan amount/term' => 'REAPPLY_AMT_CHANGED',
        'Applicant re-applying – duplicate username' => 'REAPPLY_DUPL_USERNAME',
        'applying – with correct address' => 'REAPPLY_CORRECT_ADDR',
        'Policy cancellation – on probation' => 'REAPPLY_ON_PROB',
        'Policy cancellation – on maternity leave' => 'REAPPLY_MATERNITY',
        'Policy cancellation – incorrect income entered' => 'REAPPLY_INCORRECT_INCOME',
        'Document not received – self-employed applicant' => 'DOC_NOT_RECVD_SELFEMP',
        'Document not recieved  – struggled with download/upload' => 'DOC_NOT_RECVD_UPLOAD',
        'Document not received – suspected fraud' => 'DOC_NOT_RECVD_FRAUD',
        'Document not received  – applicant didn’t want to provide document' => 'DOC_NOT_RECVD_NOT_PROVD',
        'Applicant refused DPA – Applicant didn’t want to go through DPA' => 'APPLCT_REFUSED_DPA',
        'Applicant refused UW question – Applicant wouldn’t answer underwriting questions' => 'APPLCT_REFUSED_UW_QUESTION'
    };

    public static List<SelectOption> getCancelLoanReasonOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for (String label : CANCEL_REASONS_LABEL_TO_API_NAMES.keySet()) {
            options.add(new SelectOption(CANCEL_REASONS_LABEL_TO_API_NAMES.get(label), label));
        }
        return options;
    }
    public static Map<String, String> getCancelReasonsApiNamesToLabelMap(){
        Map<String, String> api_names_to_label = new Map<String, String>();
        for(String reason_label : CANCEL_REASONS_LABEL_TO_API_NAMES.keySet()){
            api_names_to_label.put(CANCEL_REASONS_LABEL_TO_API_NAMES.get(reason_label), reason_label);
        }
        return api_names_to_label;
    }
}