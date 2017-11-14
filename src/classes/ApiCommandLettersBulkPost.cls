public class ApiCommandLettersBulkPost extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    public List<ApiSendLetterRequest> Requests = new List<ApiSendLetterRequest>();

    public ApiCommandLettersBulkPost() {
        super(ApiCommandsFactory.BULK_POST_LETTER);
    }

    public void addSendLetterRequest(String loan_id, String template_name, String send_method) {
        Requests.add(new ApiSendLetterRequest(loan_id, template_name, send_method));
    }

    @TestVisible
    protected override String buildJsonBody(){
        Map<String, Object> json_body = new Map<String, Object>();
        json_body.put('generateLetterItems', Requests);
        return JSON.serialize(json_body);
    }

    public String getResponse() {
        return HttpApiResponse.getBody();
    }

    public class ApiSendLetterRequest {
        public String LoanId;
        public String Template;
        public String SendMethod;

        public ApiSendLetterRequest(String loan_id, String template_name, String send_method) {
            LoanId = loan_id;
            Template = template_name;
            SendMethod = send_method;
        }
    }
}