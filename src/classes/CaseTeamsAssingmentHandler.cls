public with sharing class CaseTeamsAssingmentHandler {
    static Database.DMLOptions CollectionsDmlOptions;
    static Database.DMLOptions RecoveriesDmlOptions;
    static Database.DMLOptions SensitiveDmlOptions;
    static AgentActionsRecorderForCollections Recorder;

    @InvocableMethod(label='Reassign Case on reach Next Review Date' description='Reassign Case on reach Next Review Date.')
    public static void assignCasesToTeamsOnNextReviewDate(List<Id> case_ids) {
        Recorder = AgentActionsRecorderForCollections.getInstance(AgentActionsRecorderForCollections.Action.MISSED_PAYMENT, null, null, false);
        List<Case> cases = getCases(case_ids);
        prepareDmlOptionsForAssignmentRules();
        unlockReassignAndChangeSubProcess(cases);
        updateCases(cases);
        insertRecorderItems();
    }

    private static List<Case> getCases(List<Id> case_ids) {
        return [
                SELECT Id, Is_Sensitive__c, Loan__c, Process__c, RecordTypeId, Sub_Process__c
                FROM Case
                WHERE Id IN :case_ids
        ];
    }

    private static void prepareDmlOptionsForAssignmentRules() {
        CollectionsDmlOptions = new Database.DMLOptions();
        CollectionsDmlOptions.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance()
                .getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_COLLECTIONS);
        RecoveriesDmlOptions = new Database.DMLOptions();
        RecoveriesDmlOptions.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance()
                .getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_RECOVERIES);
        SensitiveDmlOptions = new Database.DMLOptions();
        SensitiveDmlOptions.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance()
                .getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_SENSITIVE);
    }

    private static void unlockReassignAndChangeSubProcess(List<Case> cases) {
        for (Case case_item : cases) {
            unlockCase(case_item);
            setCaseAssignmentRules(case_item);
            changeCaseSubProcess(case_item);
        }
    }

    private static void unlockCase(Case case_item) {
        if (!isCaseSensitive(case_item)) {
            case_item.IsLockedFromUpdatesInProcess__c = false;
        }
    }

    private static Boolean isCaseSensitive(Case case_item) {
        return case_item.Is_Sensitive__c;
    }

    private static void setCaseAssignmentRules(Case case_item) {
        if (isCaseInCollectionsProcess(case_item)) {
            case_item.setOptions(CollectionsDmlOptions);
        } else if (isCaseInRecoveriesProcess(case_item)) {
            case_item.setOptions(RecoveriesDmlOptions);
        } else if (isCaseInSensitiveCustomersProcess(case_item)) {
            case_item.setOptions(SensitiveDmlOptions);
        }
    }

    private static Boolean isCaseInCollectionsProcess(Case case_item) {
        return isCaseInSpecificProcess(case_item, CaseUtility.CASE_PROCESS_COLLECTIONS);
    }

    private static Boolean isCaseInRecoveriesProcess(Case case_item) {
        return isCaseInSpecificProcess(case_item, CaseUtility.CASE_PROCESS_RECOVERIES);
    }

    private static Boolean isCaseInSensitiveCustomersProcess(Case case_item) {
        return isCaseInSpecificProcess(case_item, CaseUtility.CASE_PROCESS_SENSITIVE_CUSTOMERS);
    }

    private static Boolean isCaseInSpecificProcess(Case case_item, String process_name) {
        return case_item.Process__c == process_name;
    }

    private static void changeCaseSubProcess(Case case_item) {
        if (isSubProcessPromiseToPay(case_item)) {
            case_item.Sub_Process__c = 'Broken Promise to Pay';
            Recorder.record(case_item);
        }
    }

    private static Boolean isSubProcessPromiseToPay(Case case_item) {
        return case_item.Sub_Process__c == 'Promise to Pay';
    }

    private static void updateCases(List<Case> cases) {
        if (!cases.isEmpty()) {
            update cases;
        }
    }

    private static void insertRecorderItems() {
        Recorder.insertNewTasks();
        Recorder.insertNewFeedItems();
    }
}