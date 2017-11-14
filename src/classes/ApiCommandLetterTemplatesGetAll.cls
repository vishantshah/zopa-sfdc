public class ApiCommandLetterTemplatesGetAll extends ApiCommandsFactory.ApiCommandAbstractBuilder{

    public ApiCommandLetterTemplatesGetAll() {
        super(ApiCommandsFactory.GET_ALL_LETTER_TEMPLATES);
    }

    public List<ApiCommandLetterTemplatesGet.LetterTemplate> getResponse(){
        String response_body = HttpApiResponse.getBody();
        return (List<ApiCommandLetterTemplatesGet.LetterTemplate>) System.JSON.deserialize(response_body, List<ApiCommandLetterTemplatesGet.LetterTemplate>.class);
    }
}