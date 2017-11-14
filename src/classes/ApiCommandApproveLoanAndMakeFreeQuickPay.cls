public class ApiCommandApproveLoanAndMakeFreeQuickPay extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    public ApiCommandApproveLoanAndMakeFreeQuickPay(String uuid) {
        super(ApiCommandsFactory.APPROVE_AND_MAKE_FREE_QUICK_PAY_COMMAND, uuid);
    }

    @TestVisible
    protected override String buildJsonBody() {
        return JSON.serialize(new List<String>{RecordUuid});
    }
}