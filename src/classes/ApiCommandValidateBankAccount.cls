public with sharing class ApiCommandValidateBankAccount extends ApiCommandsFactory.ApiCommandAbstractBuilder{
    DirectDebit CommandParameters;
    public ApiCommandValidateBankAccount(String uuid, String account_number, String sort_code) {
        super(ApiCommandsFactory.POST_VALIDATE_BANK_ACCOUNT, uuid);
        CommandParameters = new DirectDebit();
        CommandParameters.AccountNumber = account_number;
        CommandParameters.SortCode = sort_code;
    }

    @TestVisible protected override String buildJsonBody() {
        return JSON.serialize(CommandParameters);
    }

    private class DirectDebit {
        public String AccountNumber;
        public String SortCode;
    }
}