global with sharing class RecordTypeUtility {

    public static final String CASE_CUSTOMER = 'Case.Customer';
    public static final String CASE_MANUAL_UNDERWRITING = 'Case.Manual_Underwriting';
    public static final String CASE_TECH_SUPPORT = 'Case.Tech_Support';
    public static final String CASE_COLLECTIONS_RECOVERIES = 'Case.Collections_Recoveries';

    public static final String ACCOUNT_PERSON_ACCOUNT = 'Account.PersonAccount';
    public static final String ACCOUNT_BUSINESS_ACCOUNT = 'Account.Business_Account';
    public static final String ACCOUNT_DCA_ACCOUNT = 'Account.DCA';
    public static final String ACCOUNT_DMC_ACCOUNT = 'Account.DMC';

    public static final String TASK_DEFAULT = 'Task.Default';
    public static final String TASK_REFERRAL_CODE = 'Task.Referral_Code_Tasks';
    public static final String TASK_MANUAL_UNDERWRITER = 'Task.Manual_Underwriting_Tasks';
    public static final String TASK_COLLECTIONS_RECOVERIES = 'Task.Collections_Recoveries';
    public static final String TASK_COLLECTIONS_CALL = 'Task.Collections_Call';
    public static final String TASK_COLLECTIONS_LETTER = 'Task.Collections_Letter';
    public static final String TASK_SMS = 'Task.SMS';

    private static Map<String,String> MapRecordTypes;
    private static Map<String,String> MapRecordTypesReverse;
    static {
        String Key;
        Id RecTypeId;
        if (MapRecordTypes==null){
            List<RecordType>  rt_list=[SELECT Id,Name,DeveloperName,SObjectType FROM RecordType];
            MapRecordTypes = new Map<String,String>();
            MapRecordTypesReverse = new Map<String,String>();
            for (RecordType rt : rt_list){
                Key = rt.SObjectType + '.' + rt.DeveloperName;
                RecTypeId = rt.Id;
                MapRecordTypes.put(Key ,RecTypeId);
                MapRecordTypesReverse.put(RecTypeId, Key);
            }
        }
    }

    public static String getKeyById(Id RecordTypeId){
        if (MapRecordTypesReverse.get(RecordTypeId) != null)
           return MapRecordTypesReverse.get(RecordTypeId);
        return null;
    }

    public static String getIdByName(String RecordTypeName){
        if (MapRecordTypes.containsKey(RecordTypeName)) return MapRecordTypes.get(RecordTypeName);
        return null;
    }

    public static String getNameById(Id RecordTypeId){
        RecordType  rt = [SELECT Id,Name FROM RecordType WHERE Id=:RecordTypeId];
        if (rt!=null) return rt.Name;
        return null;
    }

    public static RecordType getRecordTypeById(Id record_type_id){
        RecordType record_type = [SELECT Id, DeveloperName, Name FROM RecordType WHERE Id=:record_type_id];
        if (record_type != null) return record_type;
        return null;
    }
}