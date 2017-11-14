public with sharing class AttachmentTriggerHandler extends TriggerHandler implements AttachmentTriggerHandler.ITrigger {
    public AttachmentTriggerHandler(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, List<SObject> oldList, List<SObject> newList){
        super(oldMap, newMap, oldList, newList);
    }

    public void bulkBefore(){}

    public void bulkAfter(){}

    public void beforeInsert(SObject so){}

    public void beforeUpdate(SObject oldSo, SObject so){}

    public void beforeDelete(SObject so){}

    public void afterInsert(SObject so){
        if(FeatureSwitch.getSwitch('ZS-44').isFeatureEnabled()){
            EmailAttachmentHandler.getInstance().checkIfItIsEmailAttachment((Attachment) so);
        }
    }

    public void afterUpdate(SObject oldSo, SObject so){}

    public void afterDelete(SObject so){}

    public void postProcessing(){
        if(FeatureSwitch.getSwitch('ZS-44').isFeatureEnabled()){
            EmailAttachmentHandler.getInstance().sendToBackend();
        }
    }
}