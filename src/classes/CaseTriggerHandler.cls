public with sharing class CaseTriggerHandler extends TriggerHandler implements CaseTriggerHandler.ITrigger{
    public CaseTriggerHandler(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, List<SObject> oldList, List<SObject> newList){
        super(oldMap, newMap, oldList, newList);
    }

    public void bulkBefore(){
        if (FeatureSwitch.getSwitch('ZCP-80').isFeatureEnabled() && Trigger.isUpdate) {
            CaseOnChangeNextChaseScheduler.handleCasesWithChangedNextReviewDate((List<Case>)oldList, (List<Case>)newList);
        }
        if (FeatureSwitch.getSwitch('ZCP-189').isFeatureEnabled() && Trigger.isUpdate){
            CaseOnChangeStopCommunicationHandler.changeNextReviewDateIfStopCommunicationUntilChanged((List<Case>)oldList, (List<Case>)newList);
        }
    }

    public void bulkAfter(){
        if (FeatureSwitch.getSwitch('ZOPA-18').isFeatureEnabled() && Trigger.isUpdate) {
            ReferralCodeTasksCreationDeletionHandler.getInstance().queryExistingRCTasks((Map<Id, Case>)Trigger.oldMap);
        }
        if(Trigger.isInsert) {
            CaseOnChangeNextChaseScheduler.handleCasesWithNextReviewDateAfterInsert((List<Case>)newList);
        }
        if (Trigger.isUpdate) {
            CaseOnChangeNextChaseScheduler.handleCasesWithChangedNextReviewDateAfterUpdate((List<Case>)oldList, (List<Case>)newList);
        }
    }

    public void beforeInsert(SObject so){}

    public void beforeUpdate(SObject oldSo, SObject so){
        if (FeatureSwitch.getSwitch('ZOPA-23').isFeatureEnabled()) {
            CaseInitialUnderwriterPopulationHelper.getInstance((Map<Id, Case>)newMap).populateInitialUnderwriter((Case)oldSo, (Case)so);
        }
        if(FeatureSwitch.getSwitch('ZS-34').isFeatureEnabled()){
            CaseAutoStatusChangeHandler.getInstance().assignDataImporterOwnerIfStatusChanged((Case)oldSo, (Case)so);
        }
    }

    public void beforeDelete(SObject so){}

    public void afterInsert(SObject so){
        if (FeatureSwitch.getSwitch('ZOPA-18').isFeatureEnabled()) {
            ReferralCodeTasksCreationDeletionHandler.getInstance().createTasksIfNecessary((Case)so);
        }
    }

    public void afterUpdate(SObject oldSo, SObject so){
        if (FeatureSwitch.getSwitch('ZOPA-18').isFeatureEnabled()) {
            ReferralCodeTasksCreationDeletionHandler.getInstance().createUpdateDeleteTasksIfNecessary((Case)oldSo, (Case)so);
        }
        if (FeatureSwitch.getSwitch('ZOPA-48').isFeatureEnabled()) {
            AutoCancelLoanJob.checkLoanForAutoCancelCriteria((Case)oldSo, (Case)so);
        }
        if (FeatureSwitch.getSwitch('ZOPA-59').isFeatureEnabled()) {
            NotifyZopaCaseIsPickedHandler.getInstance().checkIfCaseIsPickedUpForTheFirstTime((Case)so);
        }
        if (FeatureSwitch.getSwitch('ZOPA-166').isFeatureEnabled()) {
            LogTasksOnCaseUpdates.getInstance().checkIfNeedToCreateTasks((Case)oldSo, (Case)so);
        }
        if (FeatureSwitch.getSwitch('ZOPA-135').isFeatureEnabled()){
            DcaAccountLinkingHandler.getInstance().checkIsChangedDCA(oldSo, so);
        }
    }

    public void afterDelete(SObject so){}


    public void postProcessing(){
        if (FeatureSwitch.getSwitch('ZOPA-18').isFeatureEnabled()) {
            ReferralCodeTasksCreationDeletionHandler.getInstance().upsertAndDeleteReferralTasks();
        }
        if (FeatureSwitch.getSwitch('ZOPA-59').isFeatureEnabled()) {
            NotifyZopaCaseIsPickedHandler.getInstance().markCasesAsFirstTimePickedAndSendCallouts();
        }
        if (FeatureSwitch.getSwitch('ZOPA-166').isFeatureEnabled()) {
            LogTasksOnCaseUpdates.getInstance().insertNewCaseUpdateTasks(oldMap);
        }
        if (FeatureSwitch.getSwitch('ZOPA-135').isFeatureEnabled() && Trigger.isUpdate){
            DcaAccountLinkingHandler.getInstance().updateRelatedRecordDCALookup();
        }
    }
}