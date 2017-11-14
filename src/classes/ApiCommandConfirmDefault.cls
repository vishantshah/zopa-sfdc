public with sharing class ApiCommandConfirmDefault extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    @TestVisible private String DefaultReason;
    public ApiCommandConfirmDefault(String uuid, String current_default_reason) {
        super(ApiCommandsFactory.PUT_CONFIRM_DEFAULT, uuid);
        DefaultReason = current_default_reason;
    }

    @TestVisible protected override String buildJsonBody() {
        return '{"defaultReason":"' + DefaultReason +'"}';
    }
}