public class ApiCommandLoanEquifax extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    public ApiCommandLoanEquifax(String uuid) {
        super(ApiCommandsFactory.LOAN_EQUIFAX, uuid);
    }

    public EquifaxDetails getResponse(){
        String response_body = HttpApiResponse.getBody();
        return (EquifaxDetails) System.JSON.deserialize(response_body, EquifaxDetails.class);
    }

    public class EquifaxDetails{
        public List<EquifaxAddressCheck> ApplicantCreditChecks {get; set;}
        public List<EquifaxAddressCheck> AssociatedCreditChecks {get; set;}
        public List<EquifaxAddressCheck> FamilyCreditChecks {get; set;}
        public List<EquifaxAddressCheck> OtherCreditChecks {get; set;}
    }
}