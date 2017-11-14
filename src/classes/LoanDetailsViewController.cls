public with sharing class LoanDetailsViewController {
    public Boolean LazyLoadFinished {public get; private set;}
    public Id CurrentLoanId {get; set{
        CurrentLoanId = value;
        setLoanDetails(value);
        }}
    public Loan__c CurrentLoan {get; set;}
    public Loan_Application__c CurrentLoanApplication {public get; private set;}
    public ApiCommandGetLoanDetails.LoanDetails LoanDetails {public get; private set;}

    public LoanDetailsViewController() {
        LazyLoadFinished = false;
    }

    private void setLoanDetails(Id loan_id){
        CurrentLoan = [SELECT Id, Account__c,
                                Account__r.Name,
                                Loan_Id__c,
                                AccountDCA__c,
                                AccountDMC__c,
                                Arrears_Ratio__c,
                                Approval_State__c,
                                Broker__c,
                                CustomerType__c,
                                Disbursal_Date__c,
                                Insitution__c,
                                Loan_Servicing_Fee_Rate__c,
                                Loan_Usage__c,
                                Market__c,
                                Monthly_Safeguard_Fee_Rate__c,
                                Original_Apr__c,
                                Original_First_Month_Repayment_Amount__c,
                                Original_Monthly_Repayment_Amount__c,
                                Quick_Pay_Amount__c,
                                Rate__c,
                                Requested_Amount__c,
                                Default_Reason__c,
                                Rialto_Fee__c,
                                Start_Date__c,
                                State__c,
                                Term__c,
                                Total_Amount_Borrowed__c,
                                Total_Original_Repayable_Amount__c,
                                Date_Of_Last_Missed_Plan_Payment__c,
                                ArrearsStartDate__c
                                 FROM Loan__c WHERE Id =: loan_id];
        if(CurrentLoan.Account__c != null){
            List<Loan_Application__c> CurrentLoanApplications = [SELECT Id, Name FROM Loan_Application__c WHERE Customer_Account__c =: CurrentLoan.Account__c];
            if(CurrentLoanApplications.size() > 0){
                CurrentLoanApplication = CurrentLoanApplications[0];
            }
        }
    }

    public PageReference getLoanDetailsInformation() {
        if(CurrentLoan.Loan_Id__c != null){
            ApiCommandGetLoanDetails get_loan_details_command = new ApiCommandGetLoanDetails(CurrentLoan.Loan_Id__c);
            ApiCommandsFactory.getInstance().performApiCommandCallout(get_loan_details_command);
            if(get_loan_details_command.CommandSuccessful){
                LoanDetails = get_loan_details_command.getResponse();
            } else {
                MessageUtility.addErrorPageMessage(get_loan_details_command.CommandError);
            }
        }else{
            MessageUtility.addErrorPageMessage('This Loan have no UUID. Cannot perform api call');
        }
        LazyLoadFinished = true;
        return null;
    }

    public Boolean getIsZCP55IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-55').isFeatureEnabled();
    }

    public Boolean getIsZCP104IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-104').isFeatureEnabled();
    }

    public Boolean getIsZCP169IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-169').isFeatureEnabled();
    }

    public Boolean getIsZCP71IsEnabled() {
        return FeatureSwitch.getSwitch('ZCP-71').isFeatureEnabled();
    }

    public Boolean getIsDefaultReason(){
        return CurrentLoan != null && String.isNotBlank(CurrentLoan.Default_Reason__c);
    }
}