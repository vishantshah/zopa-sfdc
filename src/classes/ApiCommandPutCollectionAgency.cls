public class ApiCommandPutCollectionAgency extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    @TestVisible private CollectionAgencyCaseResource CurrentCollectionAgencyCase;
    @TestVisible private String CollectionsAgencyCaseId;

    public ApiCommandPutCollectionAgency(String uuid, String collections_agency_id, Datetime defaulted_date, String collections_agency_case_id) {
        super(ApiCommandsFactory.PUT_COLLECTIONS_AGENCY, uuid);
        CurrentCollectionAgencyCase = new CollectionAgencyCaseResource(collections_agency_id, defaulted_date);
        CollectionsAgencyCaseId = collections_agency_case_id;
    }

    override protected ApiCommandAbstractBuilder setEndpoint(String endpoint) {
        HttpApiRequest.setEndpoint(endpoint.replace('{collectionAgencyCaseId}', CollectionsAgencyCaseId));
        return this;
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(CurrentCollectionAgencyCase);
    }

    public class CollectionAgencyCaseResource{
        public String CollectionsAgencyId;
        public String State;
        public String Comments;
        public Datetime CreatedDate;
        public Datetime DefaultedDate;
        public Boolean Referred;

        public CollectionAgencyCaseResource(String collections_agency_id, Datetime defaulted_date) {
            this.CollectionsAgencyId = collections_agency_id;
            this.State = 'Closed';
            this.Comments = '';
            this.CreatedDate = System.now();
            this.DefaultedDate = defaulted_date;
            this.Referred = false;
        }
    }
}