public class ApiCommandMakeQuickPay extends ApiCommandsFactory.ApiCommandAbstractBuilder {
    public ApiCommandMakeQuickPay(String uuid) {
        super(ApiCommandsFactory.MAKE_QUICK_PAY_COMMAND, uuid);
    }

    @TestVisible protected override String buildJsonBody() {
        return '{}';
    }
}