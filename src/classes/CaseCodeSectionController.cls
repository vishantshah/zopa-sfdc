public with sharing class CaseCodeSectionController {
    private static final String TRIGGERED_REASON = 'Triggered';
    private static final String ABORTED_REASON = 'Aborted';
    private static final String ERRORED_REASON = 'Errored';
    public String IncomingTriggeredReferralCodes {get;set;}
    public String IncomingAbortedReferralCodes {get;set;}
    public String IncomingErroredReferralCodes {get;set;}
    public List<CaseCodeWrapper> CaseCodesWithCaseConfigurationDescription {
        get {
            if (CaseCodesWithCaseConfigurationDescription == null) {
                CaseCodesWithCaseConfigurationDescription = getCaseCodesWithCaseConfigurationDescription(IncomingTriggeredReferralCodes, TRIGGERED_REASON);
                CaseCodesWithCaseConfigurationDescription.addAll(getCaseCodesWithCaseConfigurationDescription(IncomingAbortedReferralCodes, ABORTED_REASON));
                CaseCodesWithCaseConfigurationDescription.addAll(getCaseCodesWithCaseConfigurationDescription(IncomingErroredReferralCodes, ERRORED_REASON));
            }
            return CaseCodesWithCaseConfigurationDescription;
        }
        set;
    }

    private List<CaseCodeWrapper> getCaseCodesWithCaseConfigurationDescription(String incoming_referral_codes, String reason) {
        List<CaseCodeWrapper> case_codes_with_case_configuration_description = new List<CaseCodeWrapper>();
        if(incoming_referral_codes!=null) {
            for(Case_Configuration__c case_configuration : [SELECT Id, Name,Code_Description__c FROM Case_Configuration__c WHERE Name IN: incoming_referral_codes.split(';')]) {
                case_codes_with_case_configuration_description.add(new CaseCodeWrapper(case_configuration.Name, reason, case_configuration.Code_Description__c));
            }
        }
        return case_codes_with_case_configuration_description;
    }

    public class CaseCodeWrapper {
        public String CodeName {get;private set;}
        public String CodeReason{get;private set;}
        public String CodeDescription{get;private set;}

        private CaseCodeWrapper(String rc_code, String rc_code_reason, String rc_code_description) {
            this.CodeName = rc_code;
            this.CodeReason = rc_code_reason;
            this.CodeDescription = rc_code_description;
        }
    }
}