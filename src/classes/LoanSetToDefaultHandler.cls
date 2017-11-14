public class LoanSetToDefaultHandler {

    @InvocableMethod(label='Set Related Cases to Default' description='ZOPA BE accepted request to make Loans Default (State__c field updated to "Default" value).')
    public static void handleLoansSetToDefault(List<Loan__c> loans) {
        List<Case> related_cases = getRelatedCases(loans);
        createMissingCasesForLoans(loans, related_cases);
        setCasesAsDefault(related_cases);
        updateRelatedCases(related_cases);
        createTasksAndChatterPosts(related_cases);
    }

    private static List<Case> getRelatedCases(List<Loan__c> loans) {
        Id collections_recoveries_case_record_type_id = RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES);
        Set<Id> loan_ids = new Map<Id, Loan__c>(loans).keySet();
        return [
                SELECT Id, RecordTypeId, Loan__c
                FROM Case
                WHERE Loan__c IN :loan_ids
                AND RecordTypeId = :collections_recoveries_case_record_type_id
                AND IsClosed = false
        ];
    }

    private static void createMissingCasesForLoans(List<Loan__c> loans, List<Case> cases) {
        Set<Id> loan_ids_with_existing_cases = prepareSetOfLoanIdsWithExistingCases(cases);
        List<Case> new_cases = new List<Case>();
        for (Loan__c loan : loans) {
            if (!loan_ids_with_existing_cases.contains(loan.Id) && isArrearsRatioEqualZero(loan)) {
                new_cases.add(createMissingCaseForLoan(loan));
            }
        }
        if (!new_cases.isEmpty()) {
            insert new_cases;
            cases.addAll(new_cases);
        }
    }

    private static Set<Id> prepareSetOfLoanIdsWithExistingCases(List<Case> cases) {
        Set<Id> loan_ids_with_existing_cases = new Set<Id>();
        for (Case case_item : cases) {
            loan_ids_with_existing_cases.add(case_item.Loan__c);
        }
        return loan_ids_with_existing_cases;
    }

    private static Boolean isArrearsRatioEqualZero(Loan__c loan) {
        return loan.Arrears_Ratio__c == 0 || loan.Arrears_Ratio__c == null;
    }

    private static Case createMissingCaseForLoan(Loan__c loan) {
        return CaseBuilder.getBuilder()
                .setLoan(loan)
                .setStatus('Open')
                .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                .setOwner(UserInfo.getUserId())
                .setSubject('Collections & Recoveries')
                .getRecord();
    }

    private static void setCasesAsDefault(List<Case> cases) {
        Database.DMLOptions recoveries_dml_options = new Database.DMLOptions();
        recoveries_dml_options.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance()
                .getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_RECOVERIES);
        for (Case case_item : cases) {
            case_item.Process__c = CaseUtility.CASE_PROCESS_RECOVERIES;
            case_item.Sub_Process__c = 'Default';
            case_item.Status = 'Open - Need to Contact';
            case_item.setOptions(recoveries_dml_options);
        }
    }

    private static void updateRelatedCases(List<Case> cases) {
        if (!cases.isEmpty()) {
            update cases;
        }
    }

    private static void createTasksAndChatterPosts(List<Case> cases) {
        if(FeatureSwitch.getSwitch('ZCP-149').isFeatureEnabled()) {
            AgentActionsRecorderForCollections recorder = AgentActionsRecorderForCollections.getInstance(
                    AgentActionsRecorderForCollections.Action.CONFIRM_DEFAULT, '', '(Process Builder)'
            );
            for (Case case_item : cases) {
                recorder.record(case_item);
            }
            recorder.insertNewTasks();
            recorder.insertNewFeedItems();
        }
    }
}