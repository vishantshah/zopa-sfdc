public with sharing class ApiLoanCommonDataProvider extends ApiDataProvider{
    @TestVisible private static ApiLoanCommonDataProvider Self;
    @TestVisible private String LoanUuid;

    private ApiLoanCommonDataProvider(String loan_uuid) {
        LoanUuid = loan_uuid;
    }

    public static ApiLoanCommonDataProvider getInstance(String loan_uuid) {
        if(Self == null){
            Self = new ApiLoanCommonDataProvider(loan_uuid);
        }
        return Self;
    }

    public ApiResponseLoanCommonInformation getData() {
        if(LoanUuid == null){
            ErrorOnExecution = 'This loan doesn\'t have an Id. Can\'t retrieve information.';
        } else {
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(new ApiCommandCommonLoanInformation(LoanUuid));
            if (handleCommandResponseSuccess(response)) {
                return ApiResponseLoanCommonInformation.parse(response.getBody());
            }
        }
        return null;
    }
}