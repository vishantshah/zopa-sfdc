public class LoanLettersController {
    public String LoanUuid { get; set; }
    public List<ApiCommandLettersGetAll.Letter> ExistingLetters { get; set; }
    public Integer LetterId { get; set; }
    public String LetterName { get; set; }
    public transient String LetterData { get; set; }

    public LoanLettersController() {
        ExistingLetters = new List<ApiCommandLettersGetAll.Letter>();
    }

    public void getAllLetters() {
        Boolean is_uuid_correct = ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(LoanUuid);
        if (is_uuid_correct) {
            ApiCommandLettersGetAll get_all_letters_command = new ApiCommandLettersGetAll(LoanUuid);
            HttpResponse http_response = ApiCommandsFactory.getInstance().performApiCommandCallout(get_all_letters_command);
            if (get_all_letters_command.CommandSuccessful) {
                ExistingLetters = get_all_letters_command.getResponse();
            } else {
                MessageUtility.addErrorPageMessage(get_all_letters_command.CommandError);
            }
        }
    }

    public PageReference getLetter() {
        ApiCommandLettersGet get_letters_command = new ApiCommandLettersGet(LoanUuid, String.valueOf(LetterId));
        HttpResponse api_command_response = ApiCommandsFactory.getInstance().performApiCommandCallout(get_letters_command);
        if (get_letters_command.CommandSuccessful) {
            MessageUtility.addConfirmPageMessage('Letter retrieved successfully.');
            LetterData = EncodingUtil.base64Encode(api_command_response.getBodyAsBlob());
        } else {
            MessageUtility.addErrorPageMessage(get_letters_command.CommandError);
        }
        return null;
    }
}