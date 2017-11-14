public with sharing class EmailMessageHandler extends TriggerHandler implements EmailMessageHandler.ITrigger{

    public EmailMessageHandler(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, List<SObject> oldList, List<SObject> newList){
        super(oldMap, newMap, oldList, newList);
    }

    public void bulkBefore(){}

    public void bulkAfter(){}

    public void beforeInsert(SObject so){}

    public void beforeUpdate(SObject oldSo, SObject so){}

    public void beforeDelete(SObject so){}

    public void afterInsert(SObject so){
        if (FeatureSwitch.getSwitch('ZOPA-14').isFeatureEnabled()) {
            EmailMessageReceivingDocuments.getInstance().checkIfEmailMeetTheCondition((EmailMessage)so);
        }
    }

    public void afterUpdate(SObject oldSo, SObject so){}

    public void afterDelete(SObject so){}

    public void postProcessing(){
        if (FeatureSwitch.getSwitch('ZOPA-14').isFeatureEnabled()) {
            EmailMessageReceivingDocuments.getInstance().updateAllCases();
        }
    }
}