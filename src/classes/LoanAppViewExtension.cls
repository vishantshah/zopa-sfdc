public class LoanAppViewExtension {
    private Loan_Application__c CurrentLoan;
    public LoanAppViewExtension(ApexPages.StandardController controller) {
        CurrentLoan = (Loan_Application__c)controller.getRecord();
    }

    public Boolean getFeatureSwitch80Enabled() {
        return  FeatureSwitch.getSwitch('ZOPA-80').isFeatureEnabled();
    }

    public Boolean getShowCancelDeclineReasonField(){
        return String.isNotBlank(CurrentLoan.Cancel_Decline_Reason__c) && (CurrentLoan.Loan_Application_Status__c.containsIgnoreCase('cancel') || CurrentLoan.Loan_Application_Status__c.containsIgnoreCase('decline'));
    }

    public Id getIdLoanApplicationCase(){
        Id manual_underwriting_case_id = RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING);
        if(!FeatureSwitch.getSwitch('ZCP-212').isFeatureEnabled()){
            return [SELECT Id FROM Case WHERE Loan_Application__r.Id =: CurrentLoan.Id AND RecordTypeId =: manual_underwriting_case_id LIMIT 1].Id;
        } else {
            List<Case> list_cases = [SELECT Id FROM Case WHERE Loan_Application__r.Id =: CurrentLoan.Id AND RecordTypeId =: manual_underwriting_case_id LIMIT 1];
            if(list_cases.isEmpty()){
                return null;
            } else {
                return list_cases[0].Id;
            }
        }

    }
}