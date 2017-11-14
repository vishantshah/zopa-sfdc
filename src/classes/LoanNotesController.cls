public class LoanNotesController {
    @TestVisible private static final Integer QUANTUTY_RECORDS_FOR_DISPAY = 10;
    public Loan__c CurrentLoan {get; set;}
    public Id CurrentLoanId {get; set{
        CurrentLoanId = value;
        setLoanById(value);
        }}
    public List<CommentsWrapper> ListNotes {get; set;}
    public List<CommentsWrapper> ListLimitNotes {get; private set;}
    public String ErrorOnLoad {get; private set;}

    public LoanNotesController() {
        ListNotes = new List<CommentsWrapper>();
        ListLimitNotes  = new List<CommentsWrapper>();
    }

    private void setLoanById(Id loan_id){
        if(String.isBlank(loan_id)) {
            ErrorOnLoad = 'Loan Id is blank. Can\'t retrieve information.';
        } else {
            List<Loan__c> loans = [SELECT Id, Loan_Id__c FROM Loan__c WHERE Id = :loan_id];
            if(!loans.isEmpty()) {
                CurrentLoan = loans[0];
            }
        }
    }

    public void getLoanNotes() {
        if(CurrentLoan != null && ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(CurrentLoan.Loan_Id__c)){
            ApiCommandGetLoanNotes command = new ApiCommandGetLoanNotes(CurrentLoan.Loan_Id__c);
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(command);
            if(command.CommandSuccessful){
                fillingCommentsList(command.getResponse(response.getBody()));
            } else {
                MessageUtility.addErrorPageMessage(command.CommandError);
            }
        }
    }

    private void fillingCommentsList(List<ApiCommandGetLoanNotes.LoanComments> list_comments){
        for (ApiCommandGetLoanNotes.LoanComments current_comment: list_comments){
            ListNotes.add(new CommentsWrapper(current_comment));
        }
        fillingListLimitNotes();
    }

    private void fillingListLimitNotes(){
        if (ListNotes.size() > QUANTUTY_RECORDS_FOR_DISPAY){
            for (Integer i = 0; i < QUANTUTY_RECORDS_FOR_DISPAY; i++){
                ListLimitNotes.add(ListNotes[i]);
            }
        } else {
            overwriteLoanLimitNotes();
        }
    }

    public Boolean getIsZCP122IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-122').isFeatureEnabled();
    }

    public Boolean getIsNoNotesMessageVisible(){
        return getIsZCP122IsEnabled() && ListLimitNotes.isEmpty();
    }

    public Boolean getIsShowMoreVisible(){
        return ListLimitNotes.size() == QUANTUTY_RECORDS_FOR_DISPAY && ListNotes.size() > QUANTUTY_RECORDS_FOR_DISPAY;
    }

    public void overwriteLoanLimitNotes(){
        ListLimitNotes = ListNotes;
    }

    public Boolean getLoanNotesHasAnyRecords(){
        return !ListLimitNotes.isEmpty();
    }

    public class CommentsWrapper{
        public String CreatedDate {get; set;}
        public String CreatedBy {get; set;}
        public String Text {get; set;}

        public CommentsWrapper(ApiCommandGetLoanNotes.LoanComments the_comment){
            this.CreatedDate = ApiCommandParserDateTime.parseDateTimeWithoutLocalPart(the_comment.CreatedDate);
            this.CreatedBy = the_comment.CreatedBy;
            this.Text = the_comment.Text;
        }
    }
}