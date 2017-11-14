public class ApiCommandParserDateTime {
    public static String parseDateTime(String datetime_string){
        if(String.isNotBlank(datetime_string)){
            String datetime_part = datetime_string.substringBefore('+');
            String local_part = datetime_string.substringAfter('+');
            String date_part = datetime_part.substringBefore('T');
            String time_part = datetime_part.substringAfter('T');
            List<String> parsed_date = date_part.split('-');
            List<String> parsed_time = time_part.split(':');
            Integer hour;
            if(!String.isEmpty(local_part)){
                hour = Integer.valueOf(parsed_time[0]) - Integer.valueOf(local_part.substringBefore(':'));
            }else{
                hour = Integer.valueOf(parsed_time[0]);
            }
            Datetime myDate = Datetime.newInstanceGmt(Integer.valueOf(parsed_date[0]), Integer.valueOf(parsed_date[1]), Integer.valueOf(parsed_date[2]), hour, Integer.valueOf(parsed_time[1]), 0);
            return myDate.format();
        }
        return '';
    }

    public static String parseDate(String date_string){
        if(date_string != null && date_string != ''){
            String date_part = date_string.substringBefore('T');
            List<String> parsed_date = date_part.split('-');
            Datetime myDate = Datetime.newInstanceGmt(Integer.valueOf(parsed_date[0]), Integer.valueOf(parsed_date[1]), Integer.valueOf(parsed_date[2]));
            return myDate.format('dd/MM/yyyy');
        }
        return '';
    }

    public static String parseDateTimeWithoutLocalPart(String datetime_string){
        if(!String.isBlank(datetime_string)){
            String date_part = datetime_string.substringBefore('T');
            String time_part = datetime_string.substringAfter('T');
            List<String> parsed_date = date_part.split('-');
            List<String> parsed_time = time_part.split(':');
            Integer hour = Integer.valueOf(parsed_time[0]);
            Datetime myDate = Datetime.newInstanceGmt(Integer.valueOf(parsed_date[0]), Integer.valueOf(parsed_date[1]), Integer.valueOf(parsed_date[2]), hour, Integer.valueOf(parsed_time[1]), 0);
            return myDate.format();
        }
        return '';
    }
}