public class CreateCollectionsRecoveriesCaseHandler {

    public static final String REASON_CREATE_COLLECTIONS_RECOVERIES_CASE = 'InArrears';
    @TestVisible private static final String COLLECTIONS_RECOVERIES_CASE_RECORD_TYPE = 'Collections & Recoveries';
    @TestVisible private static final String STATUS_FOR_NEW_CASE = 'New';
    @TestVisible private static final String PROCESS_FOR_NEW_CASE = 'Collections';
    @TestVisible private static final String SUB_PROCESS_FOR_NEW_CASE = 'On-Hold';
    @TestVisible private static final String SUBJECT_FOR_NEW_CASE = 'Collections & Recoveries';
    public static List<Case> ListCollectionsRecoveriesCase = new List<Case>();
    @TestVisible private static Map<Id,Case> MapCollectionsRecoveriesCase = new Map<Id,Case>();
    @TestVisible private static Set<Id> LoanIdsWithCasesNeedToBeClosed = new Set<Id>();
    @TestVisible private static Set<Id> LoanIdsWithCasesNeedToBePreDefault = new Set<Id>();
    @TestVisible private static Set<Id> LoansWithOpenCasesSetIds = new Set<Id>();
    @TestVisible private static Set<String> LoansUuidForSendApi = new Set<String>();

    public static void getOpenCasesFromExistingLoans(Set<Id> loans_id){
        List<Case> list_case = [SELECT Id, Sub_Process__c, Loan__c FROM Case WHERE Loan__c IN :loans_id AND IsClosed = false];
        for(Case the_case : list_case){
            LoansWithOpenCasesSetIds.add(the_case.Loan__c);
        }
    }

    public static void createCollectionsRecoveriesCases(Loan__c the_loan){
        Case new_case = new Case();
        new_case.RecordTypeId = RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES);
        new_case.Loan__c = the_loan.id;
        new_case.Status = STATUS_FOR_NEW_CASE;
        new_case.Process__c = PROCESS_FOR_NEW_CASE;
        new_case.Sub_Process__c = getSubProcessForNewCase(the_loan);
        new_case.Subject = SUBJECT_FOR_NEW_CASE;
        new_case.Next_Review_Date__c = Datetime.now().addDays(4);
        if(the_loan.Account__c != null){
            new_case.AccountId = the_loan.Account__c;
        }
        ListCollectionsRecoveriesCase.add(new_case);
    }

    public static void upsertCollectionsRecoveriesCases(){
        if (MapCollectionsRecoveriesCase.size() != 0){
            ListCollectionsRecoveriesCase.addAll(MapCollectionsRecoveriesCase.values());
        }
        if (ListCollectionsRecoveriesCase.size() != 0){
            upsert ListCollectionsRecoveriesCase;
        }
    }

    public static void changeCaseRelatedToLoan(Set<Id> loans_id){
        loans_id.addAll(LoanIdsWithCasesNeedToBeClosed);
        loans_id.addAll(LoanIdsWithCasesNeedToBePreDefault);
        List<Case> list_case = [SELECT OwnerId, Id, Status, Process__c, Sub_Process__c, Loan__c, IsClosed FROM Case WHERE Loan__c IN :loans_id];
        if (list_case.size() != 0) {
            for (Case the_case : list_case){
                Case current_case = getCaseFromMap(the_case);
                if (LoanStatusChecker.LoanIdWithClosedtStatus.contains(current_case.Loan__c)){
                    current_case.Status = 'Closed Paid';
                    if (!string.valueOf(current_case.OwnerId).startsWith('005')){
                        current_case.OwnerId = UserInfo.getUserId();
                    }
                }
                if(shouldCaseBeClosed(current_case)){
                    closeCase(the_case);
                }
                if(shouldCaseSubProcessBeChangedToPreDefault(current_case)){
                    changeCaseSubProcess(the_case, 'Collections', 'Pre-Default');
                    current_case.Status = 'Pending';
                    current_case.OwnerId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PRE_DEFAULT);
                }
                MapCollectionsRecoveriesCase.put(current_case.id, current_case);
            }
        }
        sendCommandToZopa();
    }

    public static Boolean isChanged(Object old_value, Object new_value){
        return old_value != new_value;
    }

    private static Boolean shouldCaseBeClosed(Case current_case) {
        return LoanIdsWithCasesNeedToBeClosed.contains(current_case.Loan__c)
                && !isSubProcessDefault(current_case.Sub_Process__c);
    }

    private static Boolean shouldCaseSubProcessBeChangedToPreDefault(Case current_case) {
        return LoanIdsWithCasesNeedToBePreDefault.contains(current_case.Loan__c)
                && !current_case.IsClosed
                && isCaseWithCollectionsProcess(current_case)
                && !isSubProcessDefault(current_case.Sub_Process__c);
    }

    private static void changeCaseSubProcess(Case the_case, String new_process, String new_sub_process){
        Case current_case = getCaseFromMap(the_case);
        current_case.Process__c = new_process;
        current_case.Sub_Process__c = new_sub_process;
    }

    private static String getSubProcessForNewCase(Loan__c the_loan){
        if(the_loan.Arrears_Ratio__c >= 4){
            return 'Pre-Default';
        }
        return SUB_PROCESS_FOR_NEW_CASE;
    }

    private static Case getCaseFromMap(Case the_case){
        if (MapCollectionsRecoveriesCase.containsKey(the_case.Id)){
            return MapCollectionsRecoveriesCase.get(the_case.Id);
        }
        return the_case;
    }

    public static void handleArrearsRatioOnChangeOnLoan(Loan__c loan){
        if(isArrearsRatioGreaterThanZero(loan.Arrears_Ratio__c) && isLoanWithoutOpenCases(loan)){
            createCollectionsRecoveriesCases(loan);
        } else if(isArrearsRatioIsNullOrZero(loan.Arrears_Ratio__c)){
            LoanIdsWithCasesNeedToBeClosed.add(loan.Id);
        } else if(isArrearsRatioGreaterThanFour(loan.Arrears_Ratio__c) && FeatureSwitch.getSwitch('ZCP-157').isFeatureEnabled()){
            LoanIdsWithCasesNeedToBePreDefault.add(loan.Id);
            LoansUuidForSendApi.add(loan.Loan_Id__c);
        }
    }

    private static void sendCommandToZopa(){
        for(String uuid: LoansUuidForSendApi){
            CollectionAgencyCommandHelper.sendCollectionsAgencyToZopaAsynchWithoutDcaId(uuid);
        }
    }

    private static void closeCase(Case case_to_close){
        case_to_close.Status = 'Closed';
    }

    private static Boolean isArrearsRatioGreaterThanZero(Decimal arrears_ratio){
        if(arrears_ratio != null){
            return arrears_ratio > 0;
        }
        return false;
    }

    private static Boolean isArrearsRatioGreaterThanFour(Decimal arrears_ratio){
        if(arrears_ratio != null){
            return arrears_ratio >= 4;
        }
        return false;
    }

    private static Boolean isArrearsRatioIsNullOrZero(Decimal arrears_ratio){
        if(arrears_ratio == null || arrears_ratio == 0){
            return true;
        }
        return false;
    }

    private static Boolean isSubProcessDefault(String current_sub_process){
        return current_sub_process == 'Default';
    }

    private static Boolean isLoanWithoutOpenCases(Loan__c loan){
        return !LoansWithOpenCasesSetIds.contains(loan.Id);
    }

    private static Boolean isCaseWithCollectionsProcess(Case case_item){
        return case_item.Process__c == CaseUtility.CASE_PROCESS_COLLECTIONS;
    }
}