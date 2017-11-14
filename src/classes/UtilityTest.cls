@isTest
private class UtilityTest {
    static testMethod void testIsAmountAValidDecimalValid(){
        List<String> valid_decimals = new List<String>{'14.53','0','-231.231','42','123.21','532','21','31.11'};
        Test.StartTest();
        for(String valid_decimal : valid_decimals){
            Boolean is_decimal_string_valid = Utility.isAmountAValidDecimal(valid_decimal);
            System.assertEquals(true, is_decimal_string_valid);
        }
        Test.stopTest();
    }

    static testMethod void testIsAmountAValidDecimalInvalid(){
        List<String> invalid_decimals = new List<String>{'a','fsaa','-543.d432','432d32','54.54.54','5$','75.43%','42%','',null};
        Test.StartTest();
        for(String invalid_decimal : invalid_decimals){
            Boolean is_decimal_string_valid = Utility.isAmountAValidDecimal(invalid_decimal);
            System.assertEquals(false, is_decimal_string_valid);
        }
        Test.stopTest();
    }

    static testMethod void testIsAmountAValidNumberValid(){
        List<String> valid_integers = new List<String>{'14','0','-231','42','123','532','21','31'};
        Test.StartTest();
        for(String valid_integer : valid_integers){
            Boolean is_integer_string_valid = Utility.isAmountAValidNumber(valid_integer);
            System.assertEquals(true, is_integer_string_valid);
        }
        Test.stopTest();
    }

    static testMethod void testIsAmountAValidNumberInvalid(){
        List<String> invalid_integers = new List<String>{'31.11','123.21','-231.231','14.53','a','fsaa','-543.d432','432d32','54.54.54','5$','75.43%','42%','',null};
        Test.StartTest();
        for(String invalid_integer : invalid_integers){
            Boolean is_integer_string_valid = Utility.isAmountAValidNumber(invalid_integer);
            system.assertEquals(false, is_integer_string_valid);
        }
        Test.stopTest();
    }

    static testMethod void testIsValidIdReturnsTrueForValidId(){
        Boolean is_valid;
        Test.startTest();
            is_valid = Utility.isValidId('500M00000042d18IAA');
        Test.stopTest();
        System.assertEquals(true, is_valid);
    }

    static testMethod void testIsValidIdReturnsFalseForInvalidId(){
        Boolean is_valid;
        Test.startTest();
            is_valid = Utility.isValidId('I am id');
        Test.stopTest();
        System.assertEquals(false, is_valid);
    }

    static testMethod void testConvertCamelCaseToSpace(){
        SetupDataClass setup_data = new SetupDataClass();
        System.runAs(setup_data.TestUser){
            Test.startTest();
                testOneCaseOffConvertCamelCaseToSpace('camelcase' , 'camelcase');
                testOneCaseOffConvertCamelCaseToSpace('Camel Case', 'CamelCase');
                testOneCaseOffConvertCamelCaseToSpace('CAMELCase' , 'CAMELCase');
                testOneCaseOffConvertCamelCaseToSpace('CAMELCASE' , 'CAMELCASE');
            Test.stopTest();
        }
    }

    private static void testOneCaseOffConvertCamelCaseToSpace(String expected ,String tested ){
        String result = Utility.convertCamelCaseToSpace(tested);
        System.assertEquals(expected , result , 'We expected result to be:'+tested+' , instead we get :' +result);
    }

     public class SetupDataClass {
        public User TestUser;

        public SetupDataClass(){
            TestUser = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.STANDARD_USER).save().getRecord();
        }
    }
}