public with sharing class ApiCommandPutStopCommunicationDate extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    private StopCommunicationResource StopCommunicationRes;

    public ApiCommandPutStopCommunicationDate(String uuid, DateTime stop_communication_until) {
        super(ApiCommandsFactory.PUT_STOP_COMMUNICATION_DATE, uuid);
        StopCommunicationRes = new StopCommunicationResource(stop_communication_until);
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(StopCommunicationRes);
    }

    public class StopCommunicationResource {
        public DateTime UntilDate {get;set;}

        public StopCommunicationResource(DateTime stop_communication_until){
            UntilDate = stop_communication_until;
        }
    }
}