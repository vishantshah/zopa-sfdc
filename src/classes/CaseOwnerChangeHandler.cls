public class CaseOwnerChangeHandler{
    private Case OldCase;
    private Case NewCase;

    private CaseOwnerChangeHandler(Case old_case, Case new_case){
        OldCase = old_case;
        NewCase = new_case;
    }

    public static CaseOwnerChangeHandler getInstance(Case old_case, Case new_case){
        return new CaseOwnerChangeHandler(old_case, new_case);
    }

    public void updateStatusIfOwnerChanged(){
        if(isOwnerChanged() && isOldCaseStatusOpenDocumentReceived()){
            NewCase.Status = 'In Progress - Documents Received';
        }
    }

    @TestVisible
    private Boolean isOwnerChanged(){
        return OldCase.OwnerId != NewCase.OwnerId;
    }

    @TestVisible
    private Boolean isOldCaseStatusOpenDocumentReceived(){
        return OldCase.Status == 'Open - Document Received';
    }
}