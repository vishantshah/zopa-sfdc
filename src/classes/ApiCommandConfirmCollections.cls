public with sharing class ApiCommandConfirmCollections extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    public ApiCommandConfirmCollections(String uuid) {
        super(ApiCommandsFactory.PUT_CONFIRM_COLLECTIONS, uuid);
    }
}