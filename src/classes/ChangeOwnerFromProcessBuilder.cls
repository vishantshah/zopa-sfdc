global class ChangeOwnerFromProcessBuilder {
    @TestVisible private static Id CaseOwnerId;

    @InvocableMethod(label='Change owner by Name')
    global static void changeOwnerIdOnCase(List<ConvertCaseActionRequest> requests) {
        Set<Id> set_case_id = new Set<Id>();
        for (convertCaseActionRequest request: requests) {
            set_case_id.add(request.TheCase.Id);
        }
        setCaseOwnerId(requests[0].OwnerName);
        List<Case> list_cases = [SELECT id, OwnerId FROM Case WHERE id IN :set_case_id];
        changeOwnerCases(list_cases);
    }

    private static void changeOwnerCases(List<Case> list_cases){
        if (list_cases.size() != 0) {
            for (Case current_case: list_cases){
                current_case.OwnerId = CaseOwnerId;
            }
            update list_cases;
        }
    }

    private static void setCaseOwnerId(String owner_name){
        List<Group> the_groups = [SELECT Id FROM Group WHERE Name = :owner_name and Type = 'Queue' LIMIT 1];
        if (the_groups.size() != 0){
            CaseOwnerId = the_groups[0].id;
        }
    }

    global class ConvertCaseActionRequest {
        @InvocableVariable(required=true)
        global Case TheCase;

        @InvocableVariable(required=true)
        global String OwnerName;
    }
}