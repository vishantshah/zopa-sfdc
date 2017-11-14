public with sharing class ManualUnderwritingCaseHandler {
    private static ManualUnderwritingCaseHandler instance;
    private Id case_creation_assignment_rule_id;
    @TestVisible private List<Case> AllCasesToUpsert;
    @TestVisible private List<Id> PickedUpInAdminSystem;
    @TestVisible private Map<Id, Case> LoanIdToUnderwritingCaseToUpdate;
    @TestVisible private Map<Id, String> LoanIdToCurrentCustomerEmail;

    public static ManualUnderwritingCaseHandler getInstance() {
        if (instance == null) {
            instance = new ManualUnderwritingCaseHandler();
        }
        return instance;
    }

    public void upsertAllCases() {
        if (AllCasesToUpsert.size() > 0) {
            upsert AllCasesToUpsert;
            AllCasesToUpsert.clear();
        }
    }

    private ManualUnderwritingCaseHandler() {
        AllCasesToUpsert = new List<Case>();
        case_creation_assignment_rule_id = CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.CASE_CREATION);
        LoanIdToCurrentCustomerEmail = new Map<Id, String>();
        PickedUpInAdminSystem = new List<Id>();
    }

    public void queryAccountEmailForManualunderwritingCase(Map<Id, sObject> new_loan_map) {
        for (Loan_Application__c loan : [SELECT Customer_Account__r.PersonEmail
                                       FROM Loan_Application__c WHERE Id IN :new_loan_map.keyset()]) {
            LoanIdToCurrentCustomerEmail.put(loan.Id, loan.Customer_Account__r.PersonEmail);
        }
    }

    public void queryUnderwritingCasesForOldLoan(Map<Id, sObject> old_loan_map) {
        LoanIdToUnderwritingCaseToUpdate = new Map<Id, Case>();
        for (Case underwriting_case : [SELECT OwnerId, Status, Loan_Application__c, Loan_Application__r.Triggered_Referral_Codes__c,
                                    Loan_Application__r.Aborted_Referral_Codes__c, Loan_Application__r.Errored_Referral_Codes__c
                                    FROM Case WHERE Loan_Application__c in :old_loan_map.keyset()
                                    AND Is_Case_Currently_Locked__c = false
                                    AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)]) {
            if (!LoanIdToUnderwritingCaseToUpdate.containsKey(underwriting_case.Loan_Application__c)) {
                LoanIdToUnderwritingCaseToUpdate.put(underwriting_case.Loan_Application__c, underwriting_case);
            }
        }
    }

    public void createManualUnderwitingCaseForNewLoan(Loan_Application__c new_loan) {
        if(isLoanStatusRequiresManualUnderwriting(new_loan)){
            Case manual_underwriting_case = createManualUnderwritingCase(new_loan);
            addAssignmentRuleOption(manual_underwriting_case, case_creation_assignment_rule_id);
            AllCasesToUpsert.add(manual_underwriting_case);
        }
    }

    public void updateManualUnderwitingCaseForOldLoan(Loan_Application__c old_loan, Loan_Application__c new_loan) {
        Case manual_underwriting_case = LoanIdToUnderwritingCaseToUpdate.get(old_loan.Id);
        if (manual_underwriting_case != null && isReferralCodesUpdated(old_loan, new_loan) && String.valueOf(manual_underwriting_case.OwnerId).startsWith('00G')) {
            manual_underwriting_case = updateCaseWithReferralCodes(new_loan, manual_underwriting_case);
            addAssignmentRuleOption(manual_underwriting_case, case_creation_assignment_rule_id);
            AllCasesToUpsert.add(manual_underwriting_case);
        }
    }

    private Boolean isLoanStatusRequiresManualUnderwriting(Loan_Application__c new_loan){
        return new_loan.Loan_Application_Status__c == 'RequiresManualUnderwriting';
    }

    private Boolean isReferralCodesUpdated(Loan_Application__c old_loan, Loan_Application__c new_loan) {
        return old_loan.Triggered_Referral_Codes__c != new_loan.Triggered_Referral_Codes__c
            || old_loan.Aborted_Referral_Codes__c != new_loan.Aborted_Referral_Codes__c
            || old_loan.Errored_Referral_Codes__c != new_loan.Errored_Referral_Codes__c;
    }

    private Boolean statusNotUpdatedToAutoApproved(Case underwriting_case) {
        return underwriting_case.Status != 'Closed - Auto Approved';
    }

    private Case updateCaseWithReferralCodes(Loan_Application__c new_loan, Case old_case) {
        return CaseBuilder.getBuilder(old_case).setTriggeredReferralCodes(new_loan.Triggered_Referral_Codes__c)
                                               .setAbortedReferralCodes(new_loan.Aborted_Referral_Codes__c)
                                               .setErroredReferralCodes(new_loan.Errored_Referral_Codes__c)
                                               .setAllReferralCodes(concatenateAllRCCodesFromLoan(new_loan))
                                               .getRecord();
    }

    private Case createManualUnderwritingCase(Loan_Application__c new_loan) {
        return CaseBuilder.getBuilder().setAccountId(new_loan.Customer_Account__c)
                                       .setAccountEmail(LoanIdToCurrentCustomerEmail.get(new_loan.Id))
                                       .setSubject('Manual Underwriting')
                                       .setLoanApplication(new_loan)
                                       .setStatus('Open').setOrigin('Web')
                                       .setRecordType(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)
                                       .setTriggeredReferralCodes(new_loan.Triggered_Referral_Codes__c)
                                       .setAbortedReferralCodes(new_loan.Aborted_Referral_Codes__c)
                                       .setErroredReferralCodes(new_loan.Errored_Referral_Codes__c)
                                       .setAllReferralCodes(concatenateAllRCCodesFromLoan(new_loan))
                                       .getRecord();
    }

    private void addAssignmentRuleOption(Case new_case, Id assignment_rule_id) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.assignmentRuleId = assignment_rule_id;
        new_case.setOptions(dmo);
    }

    private String concatenateAllRCCodesFromLoan(Loan_Application__c loan) {
        String concatenated_codes = '';
        concatenated_codes += handleNullString(loan.Triggered_Referral_Codes__c);
        concatenated_codes += handleNullString(loan.Aborted_Referral_Codes__c);
        concatenated_codes += handleNullString(loan.Errored_Referral_Codes__c);
        return concatenated_codes;
    }

    private String handleNullString(String string_value) {
        if (string_value == null) {
            return '';
        } else if (string_value.endsWith(';')) {
            return string_value;
        } else {
            return string_value + ';';
        }
    }

    public void checkIfLoanApplicationIsPickedUpInAdminSystem(Loan_Application__c old_loan, Loan_Application__c new_loan){
        if(new_loan.Picked_Up_In_Underwriting_Web__c && !old_loan.Picked_Up_In_Underwriting_Web__c){
            PickedUpInAdminSystem.add(new_loan.Id);
        }
    }

    public void takeManualUnderwritingCasesOutOfTheQueues(){
        List<Case> manual_underwriting_cases = [SELECT Id, OwnerId FROM Case WHERE Loan_Application__c IN :PickedUpInAdminSystem];
        for(Case manual_underwriting_case : manual_underwriting_cases){
            manual_underwriting_case.OwnerId = UserInfo.getUserId();
        }
        update manual_underwriting_cases;
    }
}