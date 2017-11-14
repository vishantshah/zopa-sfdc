public class ApiCommandGetLoanBankDetails extends ApiCommandsFactory.ApiCommandAbstractBuilder{

    public ApiCommandGetLoanBankDetails(String uuid) {
        super(ApiCommandsFactory.GET_BANK_LOAN_DETAILS, uuid);
    }

    public BankDetails getResponse(){
        String response_body = HttpApiResponse.getBody();
        return (BankDetails) System.JSON.deserialize(response_body, BankDetails.class);
    }

    public class BankDetails {
        public String BankName {get; set;}
        public String AccountHolderName {get; set;}
        public String AccountNumber {get; set;}
        public String SortCode {get; set;}
        public String DirectDebitStatus {get; set;}
        public String Reference {get; set;}
    }
}