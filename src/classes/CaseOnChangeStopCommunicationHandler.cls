public with sharing class CaseOnChangeStopCommunicationHandler{

    public static void changeNextReviewDateIfStopCommunicationUntilChanged(List<Case> old_case_list, List<Case> new_case_list){
        Integer list_size = new_case_list.size();
        for(Integer i = 0; i < list_size; ++i){
            if(isCaseCollectionsRecoveriesRecordType(new_case_list[i]) && isStopCommunicationUntilChanged(old_case_list[i], new_case_list[i])){
                changeNextReviewDate(new_case_list[i]);
            }
        }
    }

    private static Boolean isCaseCollectionsRecoveriesRecordType(Case new_case){
        Id collections_recoveries_id = RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES);
        return collections_recoveries_id == new_case.RecordTypeId;
    }

    private static Boolean isStopCommunicationUntilChanged(Case old_case, Case new_case){
        return old_case.Stop_Communication_Until__c != new_case.Stop_Communication_Until__c;
    }

    private static void changeNextReviewDate(Case case_item){
        case_item.Next_Review_Date__c = case_item.Stop_Communication_Until__c;
    }
}