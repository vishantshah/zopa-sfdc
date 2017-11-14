public class ApiCommandLettersGetPreview extends ApiCommandsFactory.ApiCommandAbstractBuilder {

    public ApiCommandLettersGetPreview(String loan_id, String template_name) {
        super(ApiCommandsFactory.GET_LETTER_PREVIEW, loan_id);
        this.TemplateName = template_name;
    }

    public String getResponse() {
        return HttpApiResponse.getBody();
    }
}