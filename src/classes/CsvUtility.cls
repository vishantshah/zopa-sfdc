global with sharing class CsvUtility {

    public static List<Map<String,String>> getDataFromCsvStaticResource(String resource_name){
        String data_content;
        if(Test.isRunningTest()){
            StaticResource static_resource_mock = StaticResourceMocks.getInstance().getStaticResourceMock(resource_name);
            data_content = static_resource_mock.Body.toString();
        } else{
            List<StaticResource> static_resources = [SELECT Body, BodyLength FROM StaticResource WHERE Name = :resource_name];
            if (static_resources.size() == 0){
                return new List<Map<String,String>>();
            } else {
                data_content = static_resources.get(0).Body.toString();
            }
        }
        return decodeCsvString(data_content);
    }

    private static List<Map<String, String>> decodeCsvString(String csv_string){
        csv_string = csv_string.trim().unescapeCsv();
        String[] csv_lines = csv_string.split('\n');
        List<Map<String,String>> csv_values = new List<Map<String,String>>{};
        if (csv_lines.size() > 0){
            String[] keys = csv_lines[0].trim().split(',');
            Integer lines_count = csv_lines.size();
            for (Integer lineIndex = 1; lineIndex < lines_count; lineIndex++){
                Map<String, String> csv_map = getMapFromCsvLine(csv_lines.get(lineIndex).trim(), keys);
                csv_values.add(csv_map);
            }
        }
        return csv_values;
    }

    private static Map<String, String> getMapFromCsvLine(String Line, String[] keys){
        String[] line_values = line.split(',');
        Map<String,String> csv_map = new Map<String,String>{};
        Integer keysNumber = keys.size();
        for (Integer keyIndex = 0; keyIndex < keysNumber; keyIndex++) {
            if (line_values.size() > keyIndex)
                csv_map.put(keys[keyIndex],  line_values[keyIndex].trim());
            else
                csv_map.put(keys[keyIndex], null);
        }
        return csv_map;
    }
}