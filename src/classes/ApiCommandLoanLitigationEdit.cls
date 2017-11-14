public class ApiCommandLoanLitigationEdit extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    private LoanLitigationDetailsEditController.LoanLitigationDetailsEditWrapper LoanLitigationChanges;
    public ApiCommandLoanLitigationEdit(String uuid, LoanLitigationDetailsEditController.LoanLitigationDetailsEditWrapper reason) {
        super(ApiCommandsFactory.LOAN_PUT_LITIGATION_DETAILS, uuid);
        LoanLitigationChanges = reason;
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(new LoanLitigationDetails(LoanLitigationChanges));
    }

    private class LoanLitigationDetails{
        public Datetime DefaultNotice;
        public Datetime ClaimIssued;
        public Datetime DateOfDefault;
        public Datetime DefendantDeadline;
        public Datetime Assignment;
        public Datetime JudgmentRequested;
        public Datetime LbaSent;
        public Datetime JudgmentObtained;
        public Datetime ClaimSentToCourt;
        public Datetime EnforcementCommenced;
        public Decimal OriginalCourtFees;
        public Datetime WarrantIssued;
        public Decimal OutstandingCourtFees;
        public Datetime FinalReturn;
        public String CountyCourtClaimNumber;

        public LoanLitigationDetails(LoanLitigationDetailsEditController.LoanLitigationDetailsEditWrapper loan_litigation_changes){
            DefaultNotice = loan_litigation_changes.ContainerForDefaultNotice.Start_Date__c;
            ClaimIssued = loan_litigation_changes.ContainerForClaimIssued.Start_Date__c;
            DateOfDefault = loan_litigation_changes.ContainerForDateOfDefault.Start_Date__c;
            DefendantDeadline = loan_litigation_changes.ContainerForDefendantDeadline.Start_Date__c;
            Assignment = loan_litigation_changes.ContainerForAssignment.Start_Date__c;
            JudgmentRequested = loan_litigation_changes.ContainerForJudgmentRequested.Start_Date__c;
            LbaSent = loan_litigation_changes.ContainerForLbaSent.Start_Date__c;
            JudgmentObtained = loan_litigation_changes.ContainerForJudgmentObtained.Start_Date__c;
            ClaimSentToCourt = loan_litigation_changes.ContainerForClaimSentToCourt.Start_Date__c;
            EnforcementCommenced = loan_litigation_changes.ContainerForEnforcementCommenced.Start_Date__c;
            OriginalCourtFees = loan_litigation_changes.OriginalCourtFees;
            WarrantIssued = loan_litigation_changes.ContainerForWarrantIssued.Start_Date__c;
            OutstandingCourtFees = loan_litigation_changes.OutstandingCourtFees;
            FinalReturn = loan_litigation_changes.ContainerForFinalReturn.Start_Date__c;
            CountyCourtClaimNumber = loan_litigation_changes.CountyCourtClaimNumber;
        }
    }
}