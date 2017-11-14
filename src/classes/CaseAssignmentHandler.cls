public with sharing class CaseAssignmentHandler {

    private static CaseAssignmentHandler Instance;
    @TestVisible private List<Case> AllCasesToUpdate;
    @TestVisible private Map<Id, Case> LoanIdToUnderwritingCaseToUpdate;
    @TestVisible private Set<Id> CasePrepQueueIds;
    @TestVisible private Set<Id> FraudQueueIds;
    @TestVisible private Set<Id> UnderwriterQueueIds;

    public static CaseAssignmentHandler getInstance(){
        if (Instance == null) {
            Instance = new CaseAssignmentHandler();
        }
        return Instance;
    }

    private CaseAssignmentHandler() {
        AllCasesToUpdate = new List<Case>();
        LoanIdToUnderwritingCaseToUpdate = new Map<Id, Case>();
        setQueueIds();
    }

    @TestVisible
    private void setQueueIds(){
        CasePrepQueueIds = CaseUtility.getInstance().getQueueIdSetFromName(CaseUtility.QueueName.CASE_PREP_PRIORITY);
        FraudQueueIds = CaseUtility.getInstance().getQueueIdSetFromName(CaseUtility.QueueName.FRAUD_PRIORITY);
        UnderwriterQueueIds = CaseUtility.getInstance().getQueueIdSetFromName(CaseUtility.QueueName.UNDERWRITER_PRIORITY);
    }

    public void updateAllCases() {
        if (AllCasesToUpdate.size() > 0) {
            update AllCasesToUpdate;
            AllCasesToUpdate.clear();
        }
    }

    public void queryUnderwritingCasesForOldLoan(Map<Id, sObject> old_loan_map) {
        Set<Id> all_queue = new Set<Id>();
        all_queue.addAll(CasePrepQueueIds);
        all_queue.addAll(FraudQueueIds);
        all_queue.addAll(UnderwriterQueueIds);
        LoanIdToUnderwritingCaseToUpdate = new Map<Id, Case>();
        for (Case underwriting_case : [SELECT Status, Loan_Application__c, Owner.ProfileId, OwnerId, Owner.FirstName, Account.Name, CaseNumber, IsClosed
                                    FROM Case WHERE Loan_Application__c in :old_loan_map.keyset()
                                    AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING)
                                    AND IsClosed = false
                                    AND Is_Case_Currently_Locked__c = false
                                    AND OwnerId IN: all_queue FOR UPDATE]) {
            if (!LoanIdToUnderwritingCaseToUpdate.containsKey(underwriting_case.Loan_Application__c)) {
                LoanIdToUnderwritingCaseToUpdate.put(underwriting_case.Loan_Application__c, underwriting_case);
            }
        }
    }

    public void updateManualUnderwitingCaseForOldLoan(Loan_Application__c old_loan, Loan_Application__c new_loan) {
        if(LoanIdToUnderwritingCaseToUpdate.containsKey(old_loan.Id)){
            Case manual_underwriting_case = LoanIdToUnderwritingCaseToUpdate.get(old_loan.Id);
            if (manual_underwriting_case != null) {
                if (isOwnedByCasePrepQueue(manual_underwriting_case.OwnerId)) {
                    addAssignmentRuleOption(manual_underwriting_case, CaseUtility.AssignmentRuleName.MOVE_TO_CASE_PREP);
                    AllCasesToUpdate.add(manual_underwriting_case);
                } else if (isOwnedByFraudQueue(manual_underwriting_case.OwnerId)) {
                    addAssignmentRuleOption(manual_underwriting_case, CaseUtility.AssignmentRuleName.MOVE_TO_FRAUD);
                    AllCasesToUpdate.add(manual_underwriting_case);
                } else if (isOwnedByUnderwriterQueue(manual_underwriting_case.OwnerId)) {
                    addAssignmentRuleOption(manual_underwriting_case, CaseUtility.AssignmentRuleName.MOVE_TO_UNDERWRITER);
                    AllCasesToUpdate.add(manual_underwriting_case);
                }
            }
        }
    }

    private void addAssignmentRuleOption(Case parent_case, CaseUtility.AssignmentRuleName rule_name) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(rule_name);
        parent_case.setOptions(dmo);
    }

    private Boolean isOwnedByCasePrepQueue(Id owner_id) {
        return CasePrepQueueIds.contains(owner_id);
    }

    private Boolean isOwnedByFraudQueue(Id owner_id) {
        return FraudQueueIds.contains(owner_id);
    }

    private Boolean isOwnedByUnderwriterQueue(Id owner_id) {
        return UnderwriterQueueIds.contains(owner_id);
    }
}