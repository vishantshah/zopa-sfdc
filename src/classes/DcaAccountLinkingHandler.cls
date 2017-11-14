public with sharing class DcaAccountLinkingHandler {
    private static DcaAccountLinkingHandler Instance;

    @TestVisible private Map<Id, SObject> RecordsWithUpdatedDCA;
    @TestVisible private Boolean IsAlreadyUpdatedRecordsInTransaction;
    @TestVisible private Boolean IsLoanUpdateTransaction;
    @TestVisible private Map<Id, Id> LoanByCaseIdsMapping;

    public static DcaAccountLinkingHandler getInstance() {
        if (Instance == null) {
            Instance = new DcaAccountLinkingHandler();
        }
        return Instance;
    }

    private DcaAccountLinkingHandler() {
        RecordsWithUpdatedDCA = new Map<Id, SObject>();
        IsAlreadyUpdatedRecordsInTransaction = false;
    }

    public void checkIsChangedDCA(SObject old_record, SObject new_record){
        if(RecordsWithUpdatedDCA.isEmpty()){
            setTransactionType(new_record);
        }
        if(isChangedDCA(old_record, new_record) && !IsAlreadyUpdatedRecordsInTransaction){
            RecordsWithUpdatedDCA.put(new_record.id, new_record);
        }
    }

    private void setTransactionType(SObject new_record){
        IsLoanUpdateTransaction = new_record instanceOf Loan__c;
    }

    private Boolean isChangedDCA(SObject old_record, SObject new_record){
        return (String)old_record.get('AccountDCA__c') != (String)new_record.get('AccountDCA__c');
    }

    public void updateRelatedRecordDCALookup(){
        if(!IsAlreadyUpdatedRecordsInTransaction && !RecordsWithUpdatedDCA.isEmpty()){
            IsAlreadyUpdatedRecordsInTransaction = true;
            if(IsLoanUpdateTransaction){
                updateDCAFieldOnRelatedRecords(getCasesToUpdate());
            } else {
                updateDCAFieldOnRelatedRecords(getLoansToUpdate());
            }
            RecordsWithUpdatedDCA.clear();
        }
    }

    private List<Case> getCasesToUpdate(){
        return [SELECT Id, AccountDCA__c, Loan__c FROM Case WHERE Loan__c IN: RecordsWithUpdatedDCA.keySet() AND IsClosed = false];
    }

    private List<Loan__c> getLoansToUpdate(){
        LoanByCaseIdsMapping = new Map<Id, Id>();
        for(Case updated_case : (List<Case>)RecordsWithUpdatedDCA.values()){
            LoanByCaseIdsMapping.put(updated_case.Loan__c, updated_case.Id);
        }
        return [SELECT Id, AccountDCA__c FROM Loan__c WHERE Id IN: LoanByCaseIdsMapping.keySet()];
    }

    private void updateDCAFieldOnRelatedRecords(List<SObject> records_to_update){
        for(SObject record_to_update : records_to_update){
            if(IsLoanUpdateTransaction){
                record_to_update.put('AccountDCA__c', RecordsWithUpdatedDCA.get((Id)record_to_update.get('Loan__c')).get('AccountDCA__c'));
            } else {
                Id loan_id = (Id)LoanByCaseIdsMapping.get(record_to_update.Id);
                Id dca_id = (Id)RecordsWithUpdatedDCA.get(loan_id).get('AccountDCA__c');
                record_to_update.put('AccountDCA__c', dca_id);
            }
        }
        update records_to_update;
    }
}