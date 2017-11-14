public with sharing class MissedPlanPaymentHandler {
    @TestVisible private static MissedPlanPaymentHandler Instance;
    @TestVisible private List<Case> CasesWithMissedPayment;
    @TestVisible private Set<Id> LoansWithMissedPayment;
    @TestVisible private AgentActionsRecorderForCollections Recorder;
    @TestVisible private Database.DMLOptions CollectionsDmlOption;
    @TestVisible private Database.DMLOptions RecoveriesDmlOption;
    @TestVisible private Database.DMLOptions SensitiveDmlOption;

    public static MissedPlanPaymentHandler getInstance() {
        if (Instance == null) {
            Instance = new MissedPlanPaymentHandler();
        }
        return Instance;
    }

    private MissedPlanPaymentHandler() {
        LoansWithMissedPayment = new Set<Id>();
        CasesWithMissedPayment = new List<Case>();
        Recorder = AgentActionsRecorderForCollections.getInstance(AgentActionsRecorderForCollections.Action.MISSED_REPAYMENT_ARRANGEMENT, null, null, false);
        CollectionsDmlOption = new Database.DMLOptions();
        CollectionsDmlOption.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_COLLECTIONS);
        RecoveriesDmlOption = new Database.DMLOptions();
        RecoveriesDmlOption.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_RECOVERIES);
        SensitiveDmlOption = new Database.DMLOptions();
        SensitiveDmlOption.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_SENSITIVE);
    }

    public void checkIsChangedDateOfLastMissedPlanPayment(Loan__c old_loan, Loan__c new_loan) {
        if (old_loan.Date_Of_Last_Missed_Plan_Payment__c != new_loan.Date_Of_Last_Missed_Plan_Payment__c) {
            LoansWithMissedPayment.add(new_loan.Id);
        }
    }

    public void updateCasesWithMissedPayments() {
        if (!LoansWithMissedPayment.isEmpty()) {
            CasesWithMissedPayment = [
                    SELECT Id, Is_Sensitive__c, Loan__c, OwnerId, Process__c, Previous_Sub_Process__c, RecordTypeId, Sub_Process__c
                    FROM Case
                    WHERE IsClosed = false
                    AND Loan__c IN :LoansWithMissedPayment
                    AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
            ];
            if (!CasesWithMissedPayment.isEmpty()) {
                for (Case case_to_update : CasesWithMissedPayment) {
                    moveCaseToBrokenArrangement(case_to_update);
                    unlockForUpdatesNotSensitiveCase(case_to_update);
                    setDmlOptions(case_to_update);
                }
                updateAllCases();
            }
            prepareRecorderRecords();
            insertRecorderRecords();
        }
    }

    private void moveCaseToBrokenArrangement(Case case_to_update) {
        case_to_update.Sub_Process__c = 'Broken Repayment Arrangement';
    }

    private void unlockForUpdatesNotSensitiveCase(Case case_to_update) {
        if (!case_to_update.Is_Sensitive__c) {
            case_to_update.IsLockedFromUpdatesInProcess__c = false;
        }
    }

    private void setDmlOptions(Case case_to_update) {
        if (case_to_update.Process__c == CaseUtility.CASE_PROCESS_COLLECTIONS) {
            case_to_update.setOptions(CollectionsDmlOption);
        } else if (case_to_update.Process__c == CaseUtility.CASE_PROCESS_RECOVERIES) {
            case_to_update.setOptions(RecoveriesDmlOption);
        } else if (case_to_update.Process__c == CaseUtility.CASE_PROCESS_SENSITIVE_CUSTOMERS) {
            case_to_update.setOptions(SensitiveDmlOption);
        }
    }

    private void updateAllCases() {
        if (CasesWithMissedPayment.size() > 0) {
            update CasesWithMissedPayment;
        }
        CasesWithMissedPayment.clear();
    }

    private void prepareRecorderRecords() {
        for (Id loan_id : LoansWithMissedPayment) {
            recorder.record(loan_id);
        }
    }

    private void insertRecorderRecords() {
        recorder.insertNewTasks();
        recorder.insertNewFeedItems();
    }
}