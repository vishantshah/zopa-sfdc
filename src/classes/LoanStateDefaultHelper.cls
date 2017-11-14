public with sharing class LoanStateDefaultHelper {

    public static Boolean changeLoanStatusToRialtoToDefault(String uuid, String current_default_reason){
        if (ApiCommandInspectorCallout.isExternalIdOfLoanCorrect(uuid)) {
            ApiCommandConfirmDefault command = new ApiCommandConfirmDefault(uuid, current_default_reason);
            HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(command);
            if (command.CommandSuccessful) {
                MessageUtility.addInfoPageMessage('MAKE DEFAULT request has been sent successfully!');
                return true;
            } else {
                MessageUtility.addFatalPageMessage(command.CommandError);
            }
        }
        return false;
    }
}