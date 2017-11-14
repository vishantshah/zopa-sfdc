public class ApiCommandLettersPost extends ApiCommandsFactory.ApiCommandAbstractBuilder {

    public ApiCommandLettersPost(String loan_id, String template_name, String send_method) {
        super(ApiCommandsFactory.POST_LETTER, loan_id);
        this.TemplateName = template_name;
        this.SendMethod = send_method;
    }

    public static ApiCommandLettersPost getApiCommandLoanPostLettersAuto(String loan_id, String template_name) {
        return new ApiCommandLettersPost(loan_id, template_name, 'auto');
    }

    public static ApiCommandLettersPost getApiCommandLoanPostLettersManual(String loan_id, String template_name) {
        return new ApiCommandLettersPost(loan_id, template_name, 'manual');
    }

    public Object getResponse() {
        String body_response = HttpApiResponse.getBody();
        if(CommandSuccessful) {
            return (ApiCommandLettersGetAll.Letter) JSON.deserialize(body_response, ApiCommandLettersGetAll.Letter.class);
        } else {
            return body_response;
        }
    }
}