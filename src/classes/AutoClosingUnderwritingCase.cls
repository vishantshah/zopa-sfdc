public with sharing class AutoClosingUnderwritingCase {
    private static AutoClosingUnderwritingCase instance;
    @TestVisible private List<Case> CasesToUpdate;

    public static AutoClosingUnderwritingCase getInstance() {
        if (instance == null) {
            instance = new AutoClosingUnderwritingCase();
        }
        return instance;
    }

    private AutoClosingUnderwritingCase() {
        CasesToUpdate = new List<Case>();
    }

    public void handleOldLoanApplicationsAndPrepareCasesToUpdate(Map<Id,Loan_Application__c> old_loans_map, Map<Id,Loan_Application__c> new_loans_map) {
        Set<Id> handled_loans_ids = new Set<Id>();
        for(Id loan_id : old_loans_map.keySet()) {
            if (isStatusChanged(old_loans_map.get(loan_id), new_loans_map.get(loan_id)) && isLoanNotRequiresAnymoreManualUnderwriting(old_loans_map.get(loan_id), new_loans_map.get(loan_id))) {
                handled_loans_ids.add(loan_id);
            }
        }
        for (Case case_item : [SELECT Status, Loan_Application__c
                                    FROM Case WHERE Loan_Application__c in :handled_loans_ids
                                    AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)
                                    AND Is_Case_Currently_Locked__c = false
                                    AND isClosed = false FOR UPDATE]) {
            changeCaseStatusBasedOnLoanApplicationStatus(case_item, new_loans_map.get(case_item.Loan_Application__c));
        }
    }

    private Boolean isStatusChanged(Loan_Application__c old_loan, Loan_Application__c new_loan) {
        return old_loan.Loan_Application_Status__c != new_loan.Loan_Application_Status__c;
    }

    private Boolean isLoanNotRequiresAnymoreManualUnderwriting(Loan_Application__c old_loan, Loan_Application__c new_loan){
        return isRequiresManualUnderwriting(old_loan) && !isRequiresManualUnderwriting(new_loan);
    }

    private Boolean isRequiresManualUnderwriting(Loan_Application__c loan_application) {
        return loan_application.Loan_Application_Status__c == 'RequiresManualUnderwriting';
    }

    private void changeCaseStatusBasedOnLoanApplicationStatus(Case manual_underwriting_case, Loan_Application__c new_loan) {
        if (new_loan.Loan_Application_Status__c.equals('Declined')) {
            manual_underwriting_case.Status = 'Closed - Declined';
        } else if (new_loan.Loan_Application_Status__c.equals('Approved')) {
            manual_underwriting_case.Status = 'Closed - Approved';
        } else if (new_loan.Loan_Application_Status__c.equals('Cancelled')) {
            manual_underwriting_case.Status = 'Closed - Cancelled';
        } else if (new_loan.Loan_Application_Status__c.equals('AutoDeclined')) {
            manual_underwriting_case.Status = 'Closed - Auto Declined';
        } else if (new_loan.Loan_Application_Status__c.equals('AutoApproved')) {
            manual_underwriting_case.Status = 'Closed - Auto Approved';
        } else {
            manual_underwriting_case.Status = 'Closed';
        }
        CasesToUpdate.add(manual_underwriting_case);
    }

    public void updateCases() {
        if (CasesToUpdate.size() > 0) {
            update CasesToUpdate;
            CasesToUpdate.clear();
        }
    }
}