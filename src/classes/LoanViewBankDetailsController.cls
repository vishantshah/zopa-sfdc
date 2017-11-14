public class LoanViewBankDetailsController {

    public Boolean LazyLoadFinished {public get; private set;}
    public Id CurrentLoanId {get; set{
        CurrentLoanId = value;
        setLoanBankDetails(value);
        }}
    public Loan__c CurrentLoan {get; set;}
    public ApiCommandGetLoanBankDetails.BankDetails BankDetails {public get; private set;}

    public LoanViewBankDetailsController() {
        LazyLoadFinished = false;
    }

    private void setLoanBankDetails(Id loan_id){
        CurrentLoan = [SELECT Id, Loan_Id__c FROM Loan__c WHERE Id =: loan_id];
    }

    public PageReference getLoanBankDetailsInformation() {
        if(CurrentLoan.Loan_Id__c != null){
            ApiCommandGetLoanBankDetails get_loan_bank_details_command = new ApiCommandGetLoanBankDetails(CurrentLoan.Loan_Id__c);
            ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_bank_details_command);
            if(get_loan_bank_details_command.CommandSuccessful){
                BankDetails = get_loan_bank_details_command.getResponse();
            } else {
                MessageUtility.addErrorPageMessage(get_loan_bank_details_command.CommandError);
            }
        }else{
            MessageUtility.addErrorPageMessage('This Loan have no UUID. Cannot perform api call');
        }
        LazyLoadFinished = true;
        return null;
    }

    public Boolean getIsZCP56IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-56').isFeatureEnabled();
    }
}