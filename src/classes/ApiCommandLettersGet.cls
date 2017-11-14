public class ApiCommandLettersGet extends ApiCommandsFactory.ApiCommandAbstractBuilder {

    public ApiCommandLettersGet(String loan_id, String letter_id) {
        super(ApiCommandsFactory.GET_LETTER, loan_id);
        this.LetterId = letter_id;
    }

    public String getResponse() {
        return HttpApiResponse.getBody();
    }
}