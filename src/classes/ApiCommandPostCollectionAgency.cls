public class ApiCommandPostCollectionAgency extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    @TestVisible private CollectionAgencyCaseResource CurrentCollectionAgencyCase;

    public ApiCommandPostCollectionAgency(String uuid, String collections_agency_id, Datetime defaulted_date) {
        super(ApiCommandsFactory.POST_COLLECTIONS_AGENCY, uuid);
        CurrentCollectionAgencyCase = new CollectionAgencyCaseResource(collections_agency_id, defaulted_date);
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
            this.State = 'Open';
            this.Comments = '';
            this.CreatedDate = System.now();
            this.DefaultedDate = defaulted_date;
            this.Referred = false;
        }
    }
}