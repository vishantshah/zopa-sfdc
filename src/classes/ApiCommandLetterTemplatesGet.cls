public class ApiCommandLetterTemplatesGet extends ApiCommandsFactory.ApiCommandAbstractBuilder{

    public ApiCommandLetterTemplatesGet(String template_name) {
        super(ApiCommandsFactory.GET_LETTER_TEMPLATE);
        this.TemplateName = template_name;
    }

    public LetterTemplate getResponse(){
        String response_body = HttpApiResponse.getBody();
        return (LetterTemplate) System.JSON.deserialize(response_body, LetterTemplate.class);
    }

    public class LetterTemplate {
        public Integer Id;
        public String Name {get; set;}
        public String FriendlyName {get; set;}
        public Integer Version {get; set;}
        public String Html {get; set;}
        public String CreatedDate  {
            get;
            set{
                if(value.contains('+')){
                    CreatedDate = ApiCommandParserDateTime.parseDateTime(value);
                }else{
                    CreatedDate = ApiCommandParserDateTime.parseDateTimeWithoutLocalPart(value);
                }
            }
        }
    }
}