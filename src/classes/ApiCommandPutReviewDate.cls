public with sharing class ApiCommandPutReviewDate extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    private ReviewDateResource ReviewDate;

    public ApiCommandPutReviewDate(String uuid, DateTime review_date) {
        super(ApiCommandsFactory.PUT_REVIEW_DATE, uuid);
        ReviewDate = new ApiCommandPutReviewDate.ReviewDateResource(review_date);
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(ReviewDate);
    }

    public class ReviewDateResource {
        public DateTime ReviewDate {get;set;}

        public ReviewDateResource(DateTime review_date){
            ReviewDate = review_date;
        }
    }
}