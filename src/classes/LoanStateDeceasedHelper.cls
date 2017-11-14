public with sharing class LoanStateDeceasedHelper {

    public static Boolean changeLoanStatusToRialtoToDeceased(String uuid){
        if (ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(uuid)) {
            ApiCommandConfirmDeceased command = new ApiCommandConfirmDeceased(uuid);
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(command);
            if (command.CommandSuccessful) {
                MessageUtility.addInfoPageMessage('Loan State was updated successfully');
                return true;
            } else {
                MessageUtility.addFatalPageMessage(command.CommandError);
            }
        }
        return false;
    }
}