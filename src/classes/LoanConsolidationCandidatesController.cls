public with sharing class LoanConsolidationCandidatesController {

    public ApiCommandLoanConsolidationCandidates.LoanConsolidationCandidates LoanConsolidationCandidates {get; private set;}
    public String ErrorOnLoad {get; private set;}
    public String LoanAppId {get; set;}

    public LoanConsolidationCandidatesController() {}

    public PageReference getLoanConsolidationCandidates() {
        if(LoanAppId != null){
            ApiCommandLoanConsolidationCandidates loan_consolidation_candidates_command = new ApiCommandLoanConsolidationCandidates(LoanAppId);
            ApiCommandsFactory.getInstance().performApiCommandCallout(loan_consolidation_candidates_command);
            if (loan_consolidation_candidates_command.CommandSuccessful) {
                LoanConsolidationCandidates = loan_consolidation_candidates_command.getResponse();
            } else {
                ErrorOnLoad = loan_consolidation_candidates_command.CommandError;
            }
        }
        return null;
    }

    public Boolean getIsZopa81IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-81').isFeatureEnabled();
    }
}