public with sharing class ApiCommandLoanLitigationDetails extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    public ApiCommandLoanLitigationDetails(String uuid) {
        super(ApiCommandsFactory.LOAN_GET_LITIGATION_DETAILS, uuid);
    }

    public LoanLitigationDetails getResponse(){
        String response_body = HttpApiResponse.getBody();
        return (LoanLitigationDetails) System.JSON.deserialize(response_body, LoanLitigationDetails.class);
    }

    public class LoanLitigationDetails{
        public String DefaultNotice;
        public String ClaimIssued;
        public String DateOfDefault;
        public String DefendantDeadline;
        public String Assignment;
        public String JudgmentRequested;
        public String LbaSent;
        public String JudgmentObtained;
        public String ClaimSentToCourt;
        public String EnforcementCommenced;
        public Decimal OriginalCourtFees;
        public String WarrantIssued;
        public Decimal OutstandingCourtFees;
        public String FinalReturn;
        public String CountyCourtClaimNumber;
    }
}