public class ApiCommandTakeCaseOwnership extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    public ApiCommandTakeCaseOwnership(String uuid) {
        super(ApiCommandsFactory.TAKE_CASE_OWNERSHIP, uuid);
    }

    public class LoanDocumentsResponse {
        public Boolean Success;
    }

    public Boolean getResponse(){
        String response_body = HttpApiResponse.getBody();
        LoanDocumentsResponse response = (LoanDocumentsResponse) System.JSON.deserialize(response_body, LoanDocumentsResponse.class);
        return response.Success;
    }
}