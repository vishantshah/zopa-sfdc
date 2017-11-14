public with sharing class LoanNotesPageController {
public static final List<String> ADDITIONAL_FIELDS_TO_QUERY = new List<string>{'Account__r.Name', 'Loan_id__c'};
    public Loan__c CurrentLoan {get; set;}
    public List<CommentsWrapper> ListNotes {get; set;}
    public LoanNotesPageController(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(ADDITIONAL_FIELDS_TO_QUERY);
        }
        CurrentLoan = (Loan__c) controller.getRecord();
        ListNotes = new List<CommentsWrapper>();
    }

    public void getLoanNotes() {
        if(ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(CurrentLoan.Loan_Id__c)){
            ApiCommandGetLoanNotes command = new ApiCommandGetLoanNotes(CurrentLoan.Loan_Id__c);
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(command);
            if(command.CommandSuccessful){
                fillingCommentsList(command.getResponse(response.getBody()));
            } else {
                MessageUtility.addErrorPageMessage(command.CommandError);
            }
        }
    }

    public PageReference redirectToLoanPage(){
        PageReference page_ref = Page.LoanView;
        page_ref.getParameters().put('id', CurrentLoan.Id);
        page_ref.setRedirect(true);
        return page_ref;
    }

    private void fillingCommentsList(List<ApiCommandGetLoanNotes.LoanComments> list_comments){
        for (ApiCommandGetLoanNotes.LoanComments current_comment: list_comments){
            ListNotes.add(new CommentsWrapper(current_comment));
        }
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