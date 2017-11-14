public with sharing class AccountTriggerHandler extends TriggerHandler implements AccountTriggerHandler.ITrigger{

    public AccountTriggerHandler(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, List<SObject> oldList, List<SObject> newList){
        super(oldMap, newMap, oldList, newList);
    }

    public void bulkBefore(){}

    public void bulkAfter(){
        if (Trigger.isUpdate) {
            CasePopulateEmailFieldFromAccount.getInstance().queryAllCasesForAccountInContext(Trigger.oldMap);
        }
    }

    public void beforeInsert(SObject so){}

    public void beforeUpdate(SObject oldSo, SObject so){}

    public void beforeDelete(SObject so){}

    public void afterInsert(SObject so){}

    public void afterUpdate(SObject oldSo, SObject so){
        CasePopulateEmailFieldFromAccount.getInstance().populateEmailFieldOnManualUnderwitingCase((Account)oldSo, (Account)so);
    }

    public void afterDelete(SObject so){}

    public void postProcessing(){
        CasePopulateEmailFieldFromAccount.getInstance().updateAllCases();
    }
}