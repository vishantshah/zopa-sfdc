public class DirectDebitController {
    public DirectDebitWrapper TheDirectDebit {get; set;}
    public Loan__c CurrectLoan {get; set;}

    public DirectDebitController() {
        String loan_id = ApexPages.currentPage().getParameters().get('loanId');
        CurrectLoan = [SELECT id, Account__r.Name, Loan_id__c, Name FROM Loan__c WHERE id = :loan_id];
        if (!Test.isRunningTest()) {
            TheDirectDebit = new DirectDebitWrapper(CurrectLoan.Account__r.Name);
        }
    }

    public void createNewDirectDebit(){
        if(validateInput() && ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(CurrectLoan.Loan_Id__c) && validateBankAccount()){
            ApiCommandCreateDirectDebit command = new ApiCommandCreateDirectDebit(CurrectLoan.Loan_Id__c, TheDirectDebit.AccountNumber, TheDirectDebit.SortCode, TheDirectDebit.AccountHolderName);
            ApiCommandsFactory.getInstance().performApiCommandCallout(command);
            if(command.CommandSuccessful){
                MessageUtility.addConfirmPageMessage('Direct Debit created successfully');
                AgentActionsRecorderForCollections recorder = AgentActionsRecorderForCollections.getInstance(AgentActionsRecorderForCollections.Action.CREATE_DIRECT_DEBIT);
                recorder.record(CurrectLoan.Id);
                recorder.insertNewTasks();
            } else {
                MessageUtility.addErrorPageMessage(command.CommandError);
            }
        }
    }

    private Boolean validateBankAccount(){
        ApiCommandValidateBankAccount command = new ApiCommandValidateBankAccount(CurrectLoan.Loan_Id__c, TheDirectDebit.AccountNumber, TheDirectDebit.SortCode);
        HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(command);
        if(command.CommandSuccessful){
            Boolean is_valid_account = (Boolean)((Map<String, Object>)JSON.deserializeUntyped(response.getBody())).get('isAccountValid');
            if (is_valid_account){
                return is_valid_account;
            } else {
                MessageUtility.addErrorPageMessage(response.getBody());
            }
        } else {
            MessageUtility.addErrorPageMessage(command.CommandError);
        }
        return false;
    }

    public PageReference redirectToLoanPage(){
        PageReference page_ref = Page.LoanView;
        page_ref.getParameters().put('id', CurrectLoan.Id);
        page_ref.setRedirect(true);
        return page_ref;
    }

    @TestVisible
    private Boolean validateInput(){
        Boolean all_fields_are_valid = true;
        if(!validateNumberField(TheDirectDebit.AccountNumber, 8)){
            MessageUtility.addErrorPageMessage('You must enter valid Account Number. Account Number should have 8 digits');
            all_fields_are_valid = false;
        }
        if(!validateNumberField(TheDirectDebit.SortCode, 6)){
            MessageUtility.addErrorPageMessage('You must enter valid Sort Code. Sort Code should have 6 digits');
            all_fields_are_valid = false;
        }
        if(String.isBlank(TheDirectDebit.AccountHolderName)){
            MessageUtility.addErrorPageMessage('You must enter a Account Holder Name');
            all_fields_are_valid = false;
        }
        return all_fields_are_valid;
    }

    private Boolean validateNumberField (String value, Integer number_of_digits){
        if (String.isBlank(value)) {
            return false;
        }
        String regular_expression = '\\d{' + number_of_digits + '}';
        Pattern correct_integer_pattern = Pattern.compile(regular_expression);
        Boolean result = correct_integer_pattern.matcher(value).matches();
        return result;
    }

    public class DirectDebitWrapper{
        public String SortCode {get; set;}
        public String AccountNumber {get; set;}
        public String AccountHolderName {get; set;}

        public DirectDebitWrapper(String account_holder_name){
            this.AccountHolderName = account_holder_name;
        }
    }
}