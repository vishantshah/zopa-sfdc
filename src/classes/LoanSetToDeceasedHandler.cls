public class LoanSetToDeceasedHandler {

    @InvocableMethod(label='Set Related Cases to Deceased' description='ZOPA BE accepted request to make Loans Deceased (State__c field updated to "Deceased" value).')
    public static void handleLoansSetToDeceased(List<Loan__c> loans) {
        List<Case> related_cases = getRelatedCases(loans);
        createMissingCasesForLoans(loans, related_cases);
        setCasesAsDeceased(related_cases);
        updateRelatedCases(related_cases);
        createTasksAndChatterPosts(related_cases);
    }

    private static List<Case> getRelatedCases(List<Loan__c> loans) {
        return [
                SELECT Id, Loan__c, RecordTypeId
                FROM Case
                WHERE Loan__c IN :new Map<Id, Loan__c>(loans).keySet()
                AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                AND IsClosed = false
        ];
    }


    private static void createMissingCasesForLoans(List<Loan__c> loans, List<Case> cases) {
        Set<Id> loan_ids_with_existing_cases = prepareSetOfLoanIdsWithExistingCases(cases);
        List<Case> new_cases = new List<Case>();
        for (Loan__c loan : loans) {
            if (!loan_ids_with_existing_cases.contains(loan.Id)) {
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

    private static Case createMissingCaseForLoan(Loan__c loan) {
        return CaseBuilder.getBuilder()
                .setAccountId(loan.Account__c)
                .setLoan(loan)
                .setStatus('Open')
                .setRecordType(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
                .setSubject('Collections & Recoveries')
                .setProcess('Collections')
                .getRecord();
    }

    private static void setCasesAsDeceased(List<Case> cases) {
        for (Case case_item : cases) {
            case_item.Sub_Process__c = 'Deceased';
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
                    AgentActionsRecorderForCollections.Action.CONFIRM_DECEASED, '', '(Process Builder)'
            );
            for (Case case_item : cases) {
                recorder.record(case_item);
            }
            recorder.insertNewTasks();
            recorder.insertNewFeedItems();
        }
    }
}