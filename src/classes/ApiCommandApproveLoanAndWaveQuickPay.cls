public class ApiCommandApproveLoanAndWaveQuickPay extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    public ApiCommandApproveLoanAndWaveQuickPay(String uuid) {
        super(ApiCommandsFactory.APPROVE_AND_WAVE_QUICK_PAY_COMMAND, uuid);
    }

    @TestVisible
    protected override String buildJsonBody() {
        return JSON.serialize(new List<String>{RecordUuid});
    }
}