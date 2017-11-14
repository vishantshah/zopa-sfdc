public with sharing class CaseViewLoanDetailsExtenstion {
    public Case CurrentCase {get; private set;}
    public Boolean LazyLoadFinished {get; private set;}
    public String BankAccountNumber {get; private set;}
    public String SortCode {get; private set;}
    public String BankName {get; private set;}
    public String AccountHolder { get; private set;}
    public String EmployerName {get; private set;}


    public CaseViewLoanDetailsExtenstion(ApexPages.StandardController controller) {
        CurrentCase = (Case)controller.getRecord();
        LazyLoadFinished = false;
    }

    public PageReference getLoanDetailsInformation() {
        List<Loan_Application__c> loan_app = [SELECT Loan_ID__c FROM Loan_Application__c WHERE Id = :CurrentCase.Loan_Application__c];
        if(!loan_app.isEmpty()){
            String uuid = loan_app.get(0).Loan_ID__c;
            ApiResponseLoanCommonInformation api_response_loan_info = ApiLoanCommonDataProvider.getInstance(uuid).getData();
            if (api_response_loan_info == null) {
                String error_on_load = ApiLoanCommonDataProvider.getInstance(uuid).getError();
                MessageUtility.addErrorPageMessage('Can\'t load Bank Account Number, Sort Code, Bank Name and Employer Name. ' + error_on_load);
            } else {
                fillLoanetailsFromResponse(api_response_loan_info);
            }
        } else {
            MessageUtility.addErrorPageMessage('The case is not linked to a loan application');
        }
        LazyLoadFinished = true;
        return null;
    }

    private void fillLoanetailsFromResponse(ApiResponseLoanCommonInformation api_response_loan_info){
        BankAccountNumber = api_response_loan_info.BankDetails.AccountNumber;
        SortCode = api_response_loan_info.BankDetails.SortCode;
        BankName = api_response_loan_info.BankDetails.BankName;
        AccountHolder = api_response_loan_info.BankDetails.AccountHolderName;
        EmployerName = api_response_loan_info.Employment.CurrentEmployer.Name;
    }

    public Boolean getIsZopa73IsEnabled() {
        return FeatureSwitch.getSwitch('ZOPA-73').isFeatureEnabled();
    }

    public Boolean getFeatureSwitch80Enabled() {
        return  FeatureSwitch.getSwitch('ZOPA-80').isFeatureEnabled();
    }
}