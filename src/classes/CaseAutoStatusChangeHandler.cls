public class CaseAutoStatusChangeHandler{
    private static CaseAutoStatusChangeHandler Instance;
    private static User DataImporter;

    public static CaseAutoStatusChangeHandler getInstance(){
        if(Instance == null) {
            Instance = new CaseAutoStatusChangeHandler();
        }
        return Instance;
    }

    private CaseAutoStatusChangeHandler(){
        DataImporter = [SELECT Id FROM USER WHERE Alias = 'Importer' AND LastName = 'Importer' AND FirstName = 'Data'];
    }

    public void assignDataImporterOwnerIfStatusChanged(Case old_case, Case new_case){
        if((isManualUnderwritingCase(new_case) || isCollectionsRecoveriesCase(new_case))
                && isStatusChanged(old_case, new_case)
                && isNewStatusClosedDeclinedCancelledOrApproved(new_case)
        ){
            assignDataImporterOwner(new_case);
        }
    }

    private Boolean isManualUnderwritingCase(Case new_case){
        return RecordTypeUtility.getKeyById(new_case.RecordTypeId) == RecordTypeUtility.CASE_MANUAL_UNDERWRITING;
    }

    private Boolean isCollectionsRecoveriesCase(Case new_case){
        return RecordTypeUtility.getKeyById(new_case.RecordTypeId) == RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES;
    }

    private Boolean isStatusChanged(Case old_case, Case new_case){
        return old_case.Status != new_case.Status;
    }

    private Boolean isNewStatusClosedDeclinedCancelledOrApproved(Case new_case){
        return new_case.Status.contains('Closed');
    }

    private void assignDataImporterOwner(Case new_case){
        new_case.OwnerId = DataImporter.Id;
    }
}