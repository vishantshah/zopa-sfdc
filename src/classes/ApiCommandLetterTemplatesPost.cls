public class ApiCommandLetterTemplatesPost extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    LetterTemplatePost Template;

    public ApiCommandLetterTemplatesPost(String template_name, String html) {
        super(ApiCommandsFactory.POST_LETTER_TEMPLATE);
        Template = new LetterTemplatePost();
        Template.Name = template_name;
        Template.Html = html;
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(Template);
    }

    public class LetterTemplatePost {
        public String Name;
        public String Html;
    }
}