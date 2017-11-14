public class ApiCommandGetLoanNotes extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    public ApiCommandGetLoanNotes(String uuid) {
        super(ApiCommandsFactory.GET_LOAN_NOTES, uuid);
    }

    public List<ApiCommandGetLoanNotes.LoanComments> getResponse(String response_body){
        return (List<LoanComments>) System.JSON.deserialize(response_body, List<LoanComments>.class);
    }

    public class LoanComments {
        public String CreatedDate {get; set;}
        public String CreatedBy {get; set;}
        public String Text {get; set;}
    }
}