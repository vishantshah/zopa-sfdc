public class ApiCommandLoanConsolidationCandidates extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    public ApiCommandLoanConsolidationCandidates(String uuid) {
        super(ApiCommandsFactory.LOAN_CONSOLIDATION_CANDIDATES, uuid);
    }

    public LoanConsolidationCandidates getResponse(){
        String response_body = HttpApiResponse.getBody();
        return (LoanConsolidationCandidates) System.JSON.deserialize(response_body, LoanConsolidationCandidates.class);
    }

    public class LoanConsolidationCandidates{
        public List<Candidate> ConfirmedConsolidationLoans {get; set;}
    }

    public class Candidate{
        public String BorrowingId {get; set;}
        public Decimal RequestedAmount {get; set;}
        public Decimal CapitalRemaining {get; set;}
        public Decimal SettlementAmount {get; set;}
        public Boolean IsRepaymentPending {get; set;}
    }

    public Boolean hasPaymentPending(){
        LoanConsolidationCandidates loan_consolidation_candidates = getResponse();
        if(loan_consolidation_candidates.ConfirmedConsolidationLoans != null){
            for(Candidate loan_consolidation_candidate : loan_consolidation_candidates.ConfirmedConsolidationLoans){
                if(loan_consolidation_candidate.IsRepaymentPending){
                    return true;
                }
            }
        }
        return false;
    }
}