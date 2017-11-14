global with sharing class MessageUtility {
    public Boolean HasMessage {get; set;}
    public String Summary {get; set;}
    public String Title {get; set;}
    public String Detail {get; set;}
    public String Severity {get; set;}
    public Integer Strength {get; set;}
    public List<MessageUtility> Messages {get; set;}
    public static final String FATAL_SEVERITY = 'FATAL';

    public MessageUtility(){
        this.hasMessage = false;
        this.Summary = '';
        this.Title = '';
        this.Detail = '';
        this.Severity = 'info';
        this.Strength = 2;
        this.Messages = new List<MessageUtility>();
    }

    public void removeMessages(){
        this.Messages.clear();
    }

    public void removeInfoMessages(){
        for(Integer i = 0; i<this.Messages.size();i++)
            if(this.Messages.get(i).Severity == 'INFO')
                this.Messages.remove(i);
    }

    public void addError(string summary){
        MessageUtility new_message = new MessageUtility();
        this.HasMessage = true;
        new_message.Summary = summary;
        new_message.Severity = FATAL_SEVERITY;
        new_message.Title = 'Error:';
        this.Messages.add(new_message);
    }

    public void addInfo(string summary){
        MessageUtility new_message = new MessageUtility();
        this.HasMessage = true;
        new_message.Summary = summary;
        new_message.Severity = 'INFO';
        new_message.Title = 'Info:';
        this.Messages.add(new_message);
    }

    public void addConfirm(string summary){
        MessageUtility new_message = new MessageUtility();
        this.HasMessage = true;
        new_message.Summary = summary;
        new_message.Severity = 'CONFIRM';
        new_message.Title = 'Confirm:';
        this.Messages.add(new_message);
    }

    public void showError(string summary){
        this.HasMessage = true;
        this.Summary = summary;
        this.Severity = 'FATAL';
        this.Title = 'Error:';
    }

    public void showInfo(string summary){
        this.HasMessage = true;
        this.Summary = summary;
        this.Severity = 'INFO';
        this.Title = 'Info:';
    }

    public void showConfirm(string summary){
        this.HasMessage = true;
        this.Summary = summary;
        this.Severity = 'CONFIRM';
        this.Title = 'Confirm:';
    }

    public void showWarning(string summary){
        this.HasMessage = true;
        this.Summary = summary;
        this.Severity = 'WARNING';
        this.Title = 'Warning:';
    }

    public void hide(){
        this.hasMessage = false;
    }

    public static Boolean checkListContents(String StringToSearchFor, List<ApexPages.Message> Messages, Boolean ExactMatch) {
        Boolean found = false;
        System.debug(Logginglevel.ERROR, 'PageMessages: ' + Messages);
        for (ApexPages.Message message:Messages) {
            if (ExactMatch) {
                if (message.getDetail() == StringToSearchFor) {
                    found = true;
                    break;
                }
            } else {
                if (message.getDetail().contains(StringToSearchFor)) {
                    found = true;
                    break;
                }
            }
        }
        return found;
    }

    public static String getAllPageMessagesDetailForCurrentPage() {
        String all_page_messages_as_as_string = '';
        List<ApexPages.Message> all_page_msg = ApexPages.getMessages();
        for (ApexPages.Message each_msg : all_page_msg) {
            all_page_messages_as_as_string += each_msg.getDetail() + ' ';
        }
        return all_page_messages_as_as_string;
    }

    public static Boolean checkCurrentPageContainsExact(String string_to_search_for) {
        return checkListContents(string_to_search_for, ApexPages.getMessages(), true);
    }

    public static void addFatalPageMessage(String MessageText){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, MessageText));
    }

    public static void addErrorPageMessage(String MessageText){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MessageText));
    }

    public static void addWarningPageMessage(String MessageText){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, MessageText));
    }

    public static void addInfoPageMessage(String MessageText){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, MessageText));
    }

    public static void addConfirmPageMessage(String MessageText){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, MessageText));
    }

    public static void addFatalPageMessage(String summary_text, String detail_text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, summary_text, detail_text));
    }

    public static void addErrorPageMessage(String summary_text, String detail_text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, summary_text, detail_text));
    }

    public static void addWarningPageMessage(String summary_text, String detail_text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, summary_text, detail_text));
    }

    public static void addInfoPageMessage(String summary_text, String detail_text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, summary_text, detail_text));
    }

    public static void addConfirmPageMessage(String summary_text, String detail_text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, summary_text, detail_text));
    }
}