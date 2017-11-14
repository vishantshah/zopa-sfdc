public with sharing class ApiCommandParserTimeInWords {
    public static String getTimeInText(Integer total_months){
        if(total_months > 23){
            Integer years = total_months / 12;
            Integer months = Math.mod(total_months, 12);
            if(months == 0){
                return String.valueOf(years) + ' Years';
            } else {
                return String.valueOf(years) + ' Years, ' + getMonthsTimeInText(months);
            }
        } else if (total_months > 12) {
            return '1 Year, ' + getMonthsTimeInText(total_months - 12);
        } else if (total_months == 12) {
            return '1 Year';
        } else {
            return getMonthsTimeInText(total_months);
        }
    }

    private static String getMonthsTimeInText(Integer months){
        if(months == 1){
            return '1 Month';
        }
        return String.valueOf(months) + ' Months';
    }
}