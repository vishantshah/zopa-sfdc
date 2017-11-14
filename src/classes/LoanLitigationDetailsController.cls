public virtual class LoanLitigationDetailsController {
    public String LoanId {get; set;}
    public String LoanStatus {get; set;}
    public String LoanUuid {get; set;}
    public LoanLitigationDetailsWrapper CurrentLoanLitigationDetails {get; set;}
    public Boolean IsCorrectLoading {get; set;}
    public Case RelatedCase {get; set;}

    public LoanLitigationDetailsController() {}

    public void getLitigationDetails() {
        IsCorrectLoading = ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(LoanUuid);
        if (IsCorrectLoading) {
            ApiCommandLoanLitigationDetails call_credit_details_command = new ApiCommandLoanLitigationDetails(LoanUuid);
            HttpResponse http_response = ApiCommandsFactory.getInstance().performApiCommandCallout(call_credit_details_command);
            if(call_credit_details_command.CommandSuccessful){
                if (CurrentLoanLitigationDetails == null){
                   CurrentLoanLitigationDetails = new LoanLitigationDetailsWrapper(call_credit_details_command.getResponse());
                }
            } else {
                if(http_response.getStatusCode() == 404){
                    MessageUtility.addInfoPageMessage('No Litigation details found for this loan');
                } else {
                    MessageUtility.addErrorPageMessage(call_credit_details_command.CommandError);
                }
            }
        }
    }

    public Boolean getIsZcp60IsEnabled(){
        return FeatureSwitch.getSwitch('ZCP-60').isFeatureEnabled();
    }

    public Boolean getIsRecoveriesCaseProcess(){
        queryRelatedCase();
        return RelatedCase != null && RelatedCase.Process__c == 'Recoveries';
    }

    public Boolean getIsAccessToLitigationDetailsBlock(){
        return getIsRecoveriesCaseProcess() && getIsZcp60IsEnabled();
    }

    private void queryRelatedCase(){
        if (RelatedCase == null) {
            List<Case> list_case = [SELECT id, Process__c FROM Case WHERE Loan__c = :LoanId AND IsClosed = false LIMIT 1];
            if (list_case.size() != 0){
                RelatedCase = list_case.get(0);
            }
        }
    }

    public class LoanLitigationDetailsWrapper{
        public String DefaultNotice {get; set;}
        public String ClaimIssued {get; set;}
        public String DateOfDefault {get; set;}
        public String DefendantDeadline {get; set;}
        public String Assignment {get; set;}
        public String JudgmentRequested {get; set;}
        public String LbaSent {get; set;}
        public String JudgmentObtained {get; set;}
        public String ClaimSentToCourt {get; set;}
        public String EnforcementCommenced {get; set;}
        public Decimal OriginalCourtFees {get; set;}
        public String WarrantIssued {get; set;}
        public Decimal OutstandingCourtFees {get; set;}
        public String FinalReturn {get; set;}
        public String CountyCourtClaimNumber {get; set;}

        public LoanLitigationDetailsWrapper (ApiCommandLoanLitigationDetails.LoanLitigationDetails loan_litigation_details){
            this.DefaultNotice = ApiCommandParserDateTime.parseDate(loan_litigation_details.DefaultNotice);
            this.ClaimIssued = ApiCommandParserDateTime.parseDate(loan_litigation_details.ClaimIssued);
            this.DateOfDefault = ApiCommandParserDateTime.parseDate(loan_litigation_details.DateOfDefault);
            this.DefendantDeadline = ApiCommandParserDateTime.parseDate(loan_litigation_details.DefendantDeadline);
            this.Assignment = ApiCommandParserDateTime.parseDate(loan_litigation_details.Assignment);
            this.JudgmentRequested = ApiCommandParserDateTime.parseDate(loan_litigation_details.JudgmentRequested);
            this.LbaSent = ApiCommandParserDateTime.parseDate(loan_litigation_details.LbaSent);
            this.JudgmentObtained = ApiCommandParserDateTime.parseDate(loan_litigation_details.JudgmentObtained);
            this.ClaimSentToCourt = ApiCommandParserDateTime.parseDate(loan_litigation_details.ClaimSentToCourt);
            this.EnforcementCommenced = ApiCommandParserDateTime.parseDate(loan_litigation_details.EnforcementCommenced);
            this.OriginalCourtFees = loan_litigation_details.OriginalCourtFees;
            this.WarrantIssued = ApiCommandParserDateTime.parseDate(loan_litigation_details.WarrantIssued);
            this.OutstandingCourtFees = loan_litigation_details.OutstandingCourtFees;
            this.FinalReturn = ApiCommandParserDateTime.parseDate(loan_litigation_details.FinalReturn);
            this.CountyCourtClaimNumber = loan_litigation_details.CountyCourtClaimNumber.deleteWhitespace();
        }
    }
}