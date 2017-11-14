@isTest
private class RecordTypeUtilityTest {

    static testMethod void testRecordTypeId() {
        RecordType rt = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType='Account' LIMIT 1];
        test.startTest();
            string lookupName = 'Account.'+rt.DeveloperName;
            string getRecordTypeId = RecordTypeUtility.getIdByName(lookupName);
        test.stopTest();
        System.assertEquals(string.valueOf(rt.Id),getRecordTypeId);
    }

    static testMethod void testGetRecordId(){
        Id recordTypeId = [select id, DeveloperName from RecordType where (DeveloperName='Manual_Underwriting') AND isActive = true AND SobjectType='Case'].Id;
        test.startTest();
            Id returnedRecortTypeId = RecordTypeUtility.getIdByName('Case.Manual_Underwriting');
        test.stopTest();
        System.assertEquals(recordTypeId,returnedRecortTypeId);
    }

    static testMethod void testGetKeyById(){
        Id recordTypeId = [select id, DeveloperName from RecordType where (DeveloperName='Manual_Underwriting') AND isActive = true AND SobjectType='Case'].Id;
        test.startTest();
            String returnedRecordTypeKey = RecordTypeUtility.getKeyById(recordTypeId);
        test.stopTest();
        System.assertEquals('Case.Manual_Underwriting',returnedRecordTypeKey);
    }

    static testMethod void testGetNameById(){
        Id recordTypeId = [select id, DeveloperName from RecordType where (DeveloperName='Manual_Underwriting') AND isActive = true AND SobjectType='Case'].Id;
        test.startTest();
            String returnedRecordTypeName = RecordTypeUtility.getNameById(recordTypeId);
        test.stopTest();
        System.assertEquals('Manual Underwriting',returnedRecordTypeName);
    }

    static testMethod void testRecordTypeById(){
        User test_user = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.STANDARD_USER).save().getRecord();
        System.runAs(test_user){
            Id record_type_id = [SELECT Id, DeveloperName FROM RecordType WHERE (DeveloperName='Manual_Underwriting') AND isActive = true AND SobjectType='Case'].Id;
            Test.startTest();
                RecordType returned_record_type = RecordTypeUtility.getRecordTypeById(record_type_id);
            Test.stopTest();
            RecordType expected_record_type = [SELECT Id, DeveloperName, Name FROM RecordType WHERE Id=:record_type_id];
            System.assertEquals(expected_record_type,returned_record_type, 'Returned record type is wrong');
        }
    }
}