public class ApiCommandLettersGetAll extends ApiCommandsFactory.ApiCommandAbstractBuilder {

    public ApiCommandLettersGetAll(String loan_id) {
        super(ApiCommandsFactory.GET_ALL_LETTERS, loan_id);
    }

    public List<Letter> getResponse() {
        String response_body = HttpApiResponse.getBody();
        return (List<Letter>) JSON.deserialize(response_body, List<Letter>.class);
    }

    public class Letter {
        public Integer Id { get; set; }
        public String LoanId { get; set; }
        public String Name { get; set; }
        public String CreatedBy { get; set; }
        public String CreatedDate {
            get;
            set {
                if (value.contains('+')) {
                    CreatedDate = ApiCommandParserDateTime.parseDateTime(value);
                } else {
                    CreatedDate = ApiCommandParserDateTime.parseDateTimeWithoutLocalPart(value);
                }
            }
        }
    }
}