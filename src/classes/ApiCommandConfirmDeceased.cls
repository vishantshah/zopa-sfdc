public with sharing class ApiCommandConfirmDeceased  extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    public ApiCommandConfirmDeceased(String uuid) {
        super(ApiCommandsFactory.PUT_CONFIRM_DECEASED, uuid);
    }
}