public class ApiCommandValidateBankDetails extends ApiCommandsFactory.ApiCommandAbstractBuilder {

    public ApiCommandValidateBankDetails(String uuid) {
        super(ApiCommandsFactory.VALIDATE_BANK_DETAILS_COMMAND, uuid);
    }

    public ValidateBankDetails getResponse(){
        String response_body = HttpApiResponse.getBody();
        ValidateBankDetails validated_bank_details = new ValidateBankDetails();
        validated_bank_details.Result = response_body.remove('"');
        return validated_bank_details;
    }

    public class ValidateBankDetails{
        public String Result {get; set;}
    }
}