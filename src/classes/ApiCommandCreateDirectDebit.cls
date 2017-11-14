public with sharing class ApiCommandCreateDirectDebit extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    DirectDebit CommandParameters;
    public ApiCommandCreateDirectDebit(String uuid, String account_number, String sort_code, String account_holder_name) {
        super(ApiCommandsFactory.POST_CREATE_DIRECT_DEBIT, uuid);
        CommandParameters = new DirectDebit();
        CommandParameters.AccountNumber = account_number;
        CommandParameters.SortCode = sort_code;
        CommandParameters.AccountHolderName = account_holder_name;
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(CommandParameters);
    }

    private class DirectDebit {
        public String AccountNumber;
        public String SortCode;
        public String AccountHolderName;
    }
}