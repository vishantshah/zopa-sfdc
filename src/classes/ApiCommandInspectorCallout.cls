public with sharing class ApiCommandInspectorCallout {

    public static Boolean isExternalIdOfLoanCorrect(String loan_external_id) {
        if (String.isBlank(loan_external_id)) {
            MessageUtility.addFatalPageMessage('Loan of this case doesn\'t have external Id. Callout can\'t be performed');
            return false;
        } else {
            return true;
        }
    }
}