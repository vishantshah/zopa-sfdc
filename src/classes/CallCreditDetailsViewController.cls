public with sharing class CallCreditDetailsViewController {
    public String LoanAppId {get; set;}
    @TestVisible private String LoanRecordId;
    public ApiCommandLoanCallCredit.CallCreditDetails CallCredit {get; private set;}
    public Boolean LazyLoadFinished {get; private set;}

    public CallCreditDetailsViewController(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<string>{'Loan_ID__c'});
        }
        LoanRecordId = controller.getId();
        LoanAppId = (String)controller.getRecord().get('Loan_ID__c');
        LazyLoadFinished = false;
    }

    public void getCallCreditDetails() {
        ApiCommandLoanCallCredit call_credit_details_command = new ApiCommandLoanCallCredit(LoanAppId);
        HttpResponse http_response = ApiCommandsFactory.getInstance().performApiCommandCallout(call_credit_details_command);
        if(call_credit_details_command.CommandSuccessful){
            CallCredit = call_credit_details_command.getResponse();
            LazyLoadFinished = true;
        } else {
            if(http_response.getStatusCode() == 404){
                MessageUtility.addInfoPageMessage('No CallCredit details found for this loan application');
            } else {
                MessageUtility.addErrorPageMessage(call_credit_details_command.CommandError);
            }
        }
    }

     public PageReference goToLoanApplication() {
        Loan_Application__c loan_record = [SELECT Id FROM Loan_Application__c WHERE Id = :LoanRecordId];
        ApexPages.StandardController loan_std_controller = new ApexPages.StandardController(loan_record);
        PageReference loan_page = loan_std_controller.view();
        return loan_page.setRedirect(true);
    }
}