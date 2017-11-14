public class EmailMessageReceivingDocuments {
    private static EmailMessageReceivingDocuments Instance;
    @TestVisible private List<Case> AllCasesToUpdate;
    @TestVisible private List<Messaging.SingleEmailMessage> AllMessagesToSend;
    @TestVisible private Id UnderwritingRecordtypeId;
    @TestVisible private Id CasePrepPendingQueueId;

    public static EmailMessageReceivingDocuments getInstance(){
        if (Instance == null) {
            Instance = new EmailMessageReceivingDocuments();
        }
        return Instance;
    }

    private EmailMessageReceivingDocuments() {
        AllCasesToUpdate = new List<Case>();
        UnderwritingRecordtypeId = RecordTypeUtility.getIdByName(RecordTypeUtility.CASE_MANUAL_UNDERWRITING);
        CasePrepPendingQueueId = CaseUtility.getInstance().getQueueIdFromName(CaseUtility.QueueName.PENDING_CASE_PREP);
        AllMessagesToSend = new List<Messaging.SingleEmailMessage>();
    }

    public void checkIfEmailMeetTheCondition(EmailMessage email_message) {
        if(isIncomingMessageReplyFromCustomer(email_message)){
            Case parent_case = getCaseWithRequiredInfo(email_message);
            if (isMeetBasicCritiria(parent_case) && !parent_case.IsClosed) {
                addToTheAllCasesToUpdateMap(parent_case);
            } else if(isMeetBasicCritiria(parent_case) && parent_case.IsClosed && isOwnedByUser(parent_case.Owner.ProfileId)) {
                addEmailNotificationEmail(parent_case);
            }
        }
    }

    public void updateAllCases() {
        if (AllCasesToUpdate.size() > 0) {
            update AllCasesToUpdate;
            AllCasesToUpdate.clear();
        }
        if (AllMessagesToSend.size() > 0) {
            Messaging.sendEmail(AllMessagesToSend, false);
            AllMessagesToSend.clear();
        }
    }

    private Boolean isIncomingMessageReplyFromCustomer(EmailMessage message) {
        return message.Incoming == true && [SELECT COUNT() FROM EmailMessage WHERE ParentId =: message.ParentId AND FromAddress =: message.FromAddress]>0;
    }

    private Case getCaseWithRequiredInfo(EmailMessage new_message) {
        return [SELECT IsClosed, RecordTypeId, Status, OwnerId, Owner.ProfileId, Owner.FirstName, CaseNumber, Account.Name FROM Case WHERE id =: new_message.ParentId];
    }

    private Boolean isMeetBasicCritiria(Case parent_case) {
        return parent_case.RecordTypeId == UnderwritingRecordtypeId;
    }

    private void addToTheAllCasesToUpdateMap(Case parent_case) {
        if (parent_case.OwnerId == CasePrepPendingQueueId) {
            addAssignmentRuleOption(parent_case);
        } else if (isOwnedByUser(parent_case.Owner.ProfileId)) {
            addEmailNotificationEmail(parent_case);
        }
        updateStatusToDocumentRecievedAndAddToTheAllCases(parent_case);
    }

    private void addAssignmentRuleOption(Case parent_case) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.assignmentRuleId = CaseUtility.getInstance().getAssignmentRuleIdByName(CaseUtility.AssignmentRuleName.MOVE_TO_CASE_PREP);
        parent_case.setOptions(dmo);
    }

    private void updateStatusToDocumentRecievedAndAddToTheAllCases(Case parent_case) {
        if (parent_case.Status == 'Open') {
            parent_case.Status = 'Open - Document Received';
        } else {
            parent_case.Status = 'In Progress - Document Received';
        }
        AllCasesToUpdate.add(parent_case);
    }

    private Boolean isOwnedByUser(Id owner_profile_id) {
        return owner_profile_id != null;
    }

    private void addEmailNotificationEmail(Case related_case) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(related_case.OwnerId);
        mail.setSubject('Case returned');
        String body = 'Hey ' + related_case.Owner.FirstName + ', <br><br>';
        body += related_case.Account.Name + ' just replied to your case ' + related_case.CaseNumber + '.<br><br>';
        body += 'Please follow up on this case: <br>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + related_case.Id;
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(false);
        AllMessagesToSend.add(mail);
    }
}