public class LoanStateChangedHandler {

    public static void createChatterPostsForLoansWithChangedState(List<Loan__c> old_list, List<Loan__c> new_list) {
        Map<Id, Loan__c> loans_with_changed_state = new Map<Id, Loan__c>();
        for(Integer i = 0; i < new_list.size(); i++) {
            if (isStateChanged(old_list[i], new_list[i])) {
                loans_with_changed_state.put(new_list[i].Id, new_list[i]);
            }
        }
        List<Case> related_cases = getRelatedCases(loans_with_changed_state.keySet());
        Map<Id, Id> loan_id_to_related_case_id = prepareLoanIdToRelatedCaseIdMap(related_cases);
        List<FeedItem> chatter_posts = prepareChatterPosts(loans_with_changed_state.values(), loan_id_to_related_case_id);
        insertChatterPosts(chatter_posts);
    }

    private static Boolean isStateChanged(Loan__c old_loan, Loan__c new_loan) {
        return old_loan.State__c != new_loan.State__c;
    }

    private static List<Case> getRelatedCases(Set<Id> loan_ids) {
        return [
                SELECT Id, Loan__c
                FROM Case
                WHERE Loan__c IN :loan_ids
                AND IsClosed = false
                AND RecordTypeId = :RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_COLLECTIONS_RECOVERIES)
        ];
    }

    private static Map<Id, Id> prepareLoanIdToRelatedCaseIdMap(List<Case> cases) {
        Map<Id, Id> loan_id_to_related_case_id = new Map<Id, Id>();
        for(Case case_item : cases) {
            loan_id_to_related_case_id.put(case_item.Loan__c, case_item.Id);
        }
        return loan_id_to_related_case_id;
    }

    private static List<FeedItem> prepareChatterPosts(List<Loan__c> loans_with_changed_state, Map<Id, Id> loan_id_to_related_case_id) {
        List<FeedItem> chatter_posts = new List<FeedItem>();
        for (Loan__c loan : loans_with_changed_state) {
            chatter_posts.add(prepareChatterPostForChangedState(loan.Id, loan.State__c));
            if(loan_id_to_related_case_id.containsKey(loan.Id)) {
                chatter_posts.add(prepareChatterPostForChangedState(loan_id_to_related_case_id.get(loan.Id), loan.State__c));
            }
        }
        return chatter_posts;
    }

    private static FeedItem prepareChatterPostForChangedState(Id record_id, String state) {
        FeedItem post = new FeedItem();
        post.ParentId = record_id;
        post.Body = 'changed Loan Status to "' + state + '" (ZOPA BE)';
        return post;
    }

    private static void insertChatterPosts(List<FeedItem> chatter_posts) {
        if(!chatter_posts.isEmpty()) {
            insert chatter_posts;
        }
    }
}