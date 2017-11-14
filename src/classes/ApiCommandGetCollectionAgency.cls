public class ApiCommandGetCollectionAgency extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    public ApiCommandGetCollectionAgency(String uuid) {
        super(ApiCommandsFactory.GET_COLLECTIONS_AGENCY, uuid);
    }

    public List<ApiCommandGetCollectionAgency.CollectionAgencyCases> getResponse(String response_body){
        return (List<CollectionAgencyCases>) System.JSON.deserialize(response_body, List<CollectionAgencyCases>.class);
    }

    public class CollectionAgencyCases {
        public String CollectionsAgencyCaseId {get; set;}
        public String CollectionsAgencyId {get; set;}
        public String State {get; set;}
        public Decimal CurrentCollectionsAmount {get; set;}
        public Decimal PreviousCollectionsAmount {get; set;}
        public String Comments {get; set;}
        public Datetime CreatedDate {get; set;}
        public Datetime CurrentCollectionsAmountUpdateTime {get; set;}
        public Datetime PrevCollectionsAmountUpdateTime {get; set;}
        public Datetime DefaultedDate {get; set;}
        public Boolean Referred {get; set;}
    }
}