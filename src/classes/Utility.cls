global with sharing class Utility {

    public static Map<String,String> reverseTwoStringMap(Map<String,String> original_map){
        Map<String, String> reverse_map = new Map<String,String>();
        Set<String> keys = new Set<String>();
        List<String> values = new List<String>();
        keys = original_map.keySet();
        for(String s: keys) reverse_map.put(original_map.get(s),s);
        return reverse_map;
    }

    public static integer getRandomInteger(){
        integer multiplier = (Math.round(Math.random()) == 1)?10 : 100;
        return Math.round(Math.random() * multiplier);
    }

    public static String getRandomString(Integer length) {
        String key = EncodingUtil.convertToHex(crypto.generateAesKey(128));
        return key.substring(0, length);
    }

    public static Boolean isAmountAValidDecimal(String amount){
        Boolean match_successful = true;
        try{
            Decimal decimal_amount = decimal.valueOf(amount);
        } catch(TypeException e){
            match_successful = false;
        } catch(NullPointerException e){
            match_successful = false;
        }
        return match_successful;
    }

    public static Boolean isAmountAValidNumber(String amount){
        Boolean match_successful = true;
        try{
            Integer int_amount = Integer.valueOf(amount);
        } catch(TypeException e){
            match_successful = false;
        } catch(NullPointerException e){
            match_successful = false;
        }
        return match_successful;
    }



    public static Boolean isValidId(String string_to_test){
        Id valid_id;
        try {
            valid_id = string_to_test;
            return true;
        } catch (Exception ex) {
            return false;
        }
    }

    public static String convertCamelCaseToSpace(String to_convert){
        String camelcase_regex = '([a-z])([A-Z])';
        Pattern camelcase_pattern = Pattern.compile(camelcase_regex);
        Matcher camelcase_matcher = camelcase_pattern.matcher(to_convert);
        return  camelcase_matcher.replaceAll('$1 $2');
    }

    public static Boolean isSandbox(){
        return [SELECT IsSandbox FROM Organization where id = :UserInfo.getOrganizationId()].IsSandbox;
    }
}