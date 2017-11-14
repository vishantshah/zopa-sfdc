public with sharing class ApiLoanDataProvider extends ApiDataProvider{
    @TestVisible private static ApiLoanDataProvider Self;
    @TestVisible private String LoanUuid;
    @TestVisible private ApiCommandsFactory.ApiCommandAbstractBuilder CommandImplementation;

    private ApiLoanDataProvider(String loan_uuid, ApiCommandsFactory.ApiCommandAbstractBuilder command_implementation) {
        LoanUuid = loan_uuid;
        CommandImplementation = command_implementation;
    }

    public static ApiLoanDataProvider getInstance(String loan_uuid, ApiCommandsFactory.ApiCommandAbstractBuilder command_implementation) {
        if(Self == null){
            Self = new ApiLoanDataProvider(loan_uuid,command_implementation);
        }
        return Self;
    }

    public List<ApiResponseLoanInformation.ZopaLoanHistory> getData() {
        if(LoanUuid == null){
            ErrorOnExecution = 'This loan doesn\'t have an Id. Can\'t retrieve information.';
        } else {
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(CommandImplementation);
            if (handleCommandResponseSuccess(response)) {
                return ApiResponseLoanInformation.parse(response.getBody());
            }
        }
        return null;
    }


}