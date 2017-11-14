public class LoanStatusChecker {
    public static final Set<String> SET_STATUS_FOR_CLOSE = new Set<String>{'Settled', 'Closed', 'Paid'};
    public static Set<Id> LoanIdWithClosedtStatus = new Set<Id>();

    public static Boolean isClosedStatus(String current_status){
        Boolean result = false;
        if (SET_STATUS_FOR_CLOSE.contains(current_status)){
            result = true;
        }
        return result;
    }
}