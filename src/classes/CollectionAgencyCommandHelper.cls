public class CollectionAgencyCommandHelper {

    @future(callout=true)
    public static void sendCollectionsAgencyToZopaAsynch(String uuid, String dca_id, Datetime defaulted_date, String collections_agency_case_id){
        if (!String.isBlank(uuid)) {
            ApiCommandPutCollectionAgency command = new ApiCommandPutCollectionAgency(uuid, dca_id, defaulted_date, collections_agency_case_id);
            ApiCommandsFactory.getInstance().performApiCommandCallout(command);
        }
    }

    @future(callout=true)
    public static void sendCollectionsAgencyToZopaAsynchWithoutDcaId(String uuid){
        if (!String.isBlank(uuid)) {
            ApiCommandGetCollectionAgency command = new ApiCommandGetCollectionAgency(uuid);
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(command);
            if(command.CommandSuccessful){
                sendCollectionsAgencyToZopa(uuid, command.getResponse(response.getBody()));
            }
        }
    }

    private static Boolean sendCollectionsAgencyToZopa(String uuid, List<ApiCommandGetCollectionAgency.CollectionAgencyCases> list_collection_agency_cases){
        for(ApiCommandGetCollectionAgency.CollectionAgencyCases current_collection_agency_case:list_collection_agency_cases){
            if(current_collection_agency_case.State == 'Open'){
                return sendCollectionsAgencyToZopa(uuid, current_collection_agency_case.CollectionsAgencyId, current_collection_agency_case.DefaultedDate, current_collection_agency_case.CollectionsAgencyCaseId);
            }
        }
        return false;
    }

    public static Boolean sendCollectionsAgencyToZopa(String uuid, String dca_id, Datetime defaulted_date, String collections_agency_case_id){
        Boolean result = false;
        if (!String.isBlank(uuid)) {
            ApiCommandPutCollectionAgency command = new ApiCommandPutCollectionAgency(uuid, dca_id, defaulted_date, collections_agency_case_id);
            ApiCommandsFactory.getInstance().performApiCommandCallout(command);
            if(command.CommandSuccessful){
                result = true;
            }
        }
        return result;
    }

    public static void sendPostCollectionsAgencyToZopa(String uuid, String dca_id, Datetime defaulted_date){
        if(System.isBatch() || System.isFuture()){
            sendPostCollectionsAgencyToZopaSync(uuid, dca_id, defaulted_date);
        }else{
            sendPostCollectionsAgencyToZopaAsync(uuid, dca_id, defaulted_date);
        }
    }

    private static void sendPostCollectionsAgencyToZopaSync(String uuid, String dca_id, Datetime defaulted_date){
        if (!String.isBlank(uuid)) {
            ApiCommandPostCollectionAgency command = new ApiCommandPostCollectionAgency(uuid, dca_id, defaulted_date);
            ApiCommandsFactory.getInstance().performApiCommandCallout(command);
        }
    }

    @future(callout=true)
    private static void sendPostCollectionsAgencyToZopaAsync(String uuid, String dca_id, Datetime defaulted_date){
        sendPostCollectionsAgencyToZopaSync(uuid, dca_id, defaulted_date);
    }

    public static ApiCommandPostCollectionAgency sendPostCollectionsAgencyToZopaAndReturnCommand(String uuid, String dca_id, Datetime defaulted_date){
        ApiCommandPostCollectionAgency command = new ApiCommandPostCollectionAgency(uuid, dca_id, defaulted_date);
        ApiCommandsFactory.getInstance().performApiCommandCallout(command);
        return command;
    }

    public static void sendBulkPostsCollectionsAgencyToZopa(String dca_id, Map<String, Datetime> map_loan_uuid_to_default_date) {
        if(System.isBatch() || System.isFuture()){
            sendBulkPostsCollectionsAgencyToZopaSync(dca_id, map_loan_uuid_to_default_date);
        }else{
            sendBulkPostsCollectionsAgencyToZopaAsync(dca_id, map_loan_uuid_to_default_date);
        }
    }

    private static void sendBulkPostsCollectionsAgencyToZopaSync(String dca_id, Map<String, Datetime> map_loan_uuid_to_default_date) {
        Integer list_size = map_loan_uuid_to_default_date.size();
        for(String uuid : map_loan_uuid_to_default_date.keySet()) {
            sendPostCollectionsAgencyToZopaSync(uuid, dca_id, map_loan_uuid_to_default_date.get(uuid));
        }
    }

    @future(callout=true)
    private static void sendBulkPostsCollectionsAgencyToZopaAsync(String dca_id, Map<String, Datetime> map_loan_uuid_to_default_date) {
        sendBulkPostsCollectionsAgencyToZopaSync(dca_id, map_loan_uuid_to_default_date);
    }
}