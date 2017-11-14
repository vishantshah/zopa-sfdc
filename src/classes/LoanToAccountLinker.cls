public without sharing class LoanToAccountLinker {

    private static LoanToAccountLinker Instance;

    @TestVisible private Map<String, Id> MemberIdToAccountIdMap;

    public static LoanToAccountLinker getInstance() {
        if (Instance == null) {
            Instance = new LoanToAccountLinker();
        }
        return Instance;
    }

    private LoanToAccountLinker() {
        MemberIdToAccountIdMap = new Map<String, Id>();
    }

    public void getAllAccountIdsByMemberIds(List<Loan__c> new_loans){
        Set<String> member_ids_from_loans = getAllMemberIdsFromLoans(new_loans);
        MemberIdToAccountIdMap = getAccountIdsMapByMemberIds(member_ids_from_loans);
    }

    private Set<String> getAllMemberIdsFromLoans(List<Loan__c> new_loans){
        Set<String> member_ids_from_loans = new Set<String>();
        for(Loan__c new_loan : new_loans){
            member_ids_from_loans.add(new_loan.Member_ID__c);
        }
        return member_ids_from_loans;
    }

    private Map<String, Id> getAccountIdsMapByMemberIds(Set<String> member_ids_from_loans){
        member_ids_from_loans.remove(null);
        Map<String, Id> member_id_to_account_id_map = new Map<String, Id>();
        List<Account> account_list = [SELECT Id, MemberID__c FROM Account WHERE MemberID__c IN: member_ids_from_loans];
        for(Account acc : account_list){
            member_id_to_account_id_map.put(acc.MemberID__c, acc.Id);
        }
        return member_id_to_account_id_map;
    }

    public void setAccountIdForLoan(Loan__c new_loan){
        Id account_id = MemberIdToAccountIdMap.get(new_loan.Member_ID__c);
        if(account_id != null){
            new_loan.Account__c = account_id;
        }
    }
}