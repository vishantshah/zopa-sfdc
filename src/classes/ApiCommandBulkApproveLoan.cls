public class ApiCommandBulkApproveLoan extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    @TestVisible private Set<String> LoanUuidSet;

    public ApiCommandBulkApproveLoan(Set<String> list_uuid) {
        super(ApiCommandsFactory.BULK_APPROVE_LOAN_COMMAND);
        LoanUuidSet = list_uuid;
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(LoanUuidSet);
    }

    public BulkApproveResponse getResponse(){
        String response_body = HttpApiResponse.getBody();
        if(response_body.contains('errored')){
            return (BulkApproveResponse) System.JSON.deserialize(response_body, BulkApproveResponse.class);
        }
        return null;
    }

    public class BulkApproveResponse {
        public List<String> Errored;
    }
}