public with sharing class CasePopulateEmailFieldFromAccount {
    private static CasePopulateEmailFieldFromAccount Singleton;
    @TestVisible private List<Case> AllCasesToUpdate;
    @TestVisible private Map<Id, List<Case>> AccountIdToUnderwritingCasesToUpdate;

    public static CasePopulateEmailFieldFromAccount getInstance(){
        if (Singleton == null) {
            Singleton = new CasePopulateEmailFieldFromAccount();
        }
        return Singleton;
    }

    private CasePopulateEmailFieldFromAccount() {
        AllCasesToUpdate = new List<Case>();
        AccountIdToUnderwritingCasesToUpdate = new Map<Id, List<Case>>();
    }

    public void updateAllCases() {
        if (AllCasesToUpdate.size() > 0) {
            update AllCasesToUpdate;
            AllCasesToUpdate.clear();
        }
    }

    public void queryAllCasesForAccountInContext(Map<Id, sObject> old_account_map) {
        for (Account customer_account : [SELECT Id,
                                        (SELECT Workflow_Emailing_Person_Account__c
                                        FROM Cases WHERE RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING))
                                        FROM Account WHERE Id in :old_account_map.keySet()]) {
            AccountIdToUnderwritingCasesToUpdate.put(customer_account.Id, customer_account.Cases);
        }
    }

    public void populateEmailFieldOnManualUnderwitingCase(Account old_account, Account new_account) {
        if (isCustomerEmailFieldUpdated(old_account, new_account)) {
            for (Case manual_underwriting_case : AccountIdToUnderwritingCasesToUpdate.get(old_account.Id)) {
                updateCaseWithNewEmail(manual_underwriting_case, new_account);
            }
        }
    }

    private Boolean isCustomerEmailFieldUpdated(Account old_account, Account new_account) {
        return old_account.PersonEmail != new_account.PersonEmail;
    }

    private void updateCaseWithNewEmail(Case manual_underwriting_case, Account new_account) {
        manual_underwriting_case.Workflow_Emailing_Person_Account__c = new_account.PersonEmail;
        AllCasesToUpdate.add(manual_underwriting_case);
    }
}