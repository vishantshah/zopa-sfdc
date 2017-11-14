global class SendLettersHandler {

    @InvocableMethod(label='Send Letter to Customer' description='Generate requests to ZOPA for sending letters.')
    public static void sendLettersToCustomers(List<SendLetterRequest> requests) {
        if (System.isBatch() || System.isFuture() || System.isScheduled()) {
            sendLetters(requests);
        } else {
            sendLettersAsync(JSON.serialize(requests));
        }
    }

    @Future(callout=true)
    private static void sendLettersAsync(String requests_string) {
        List<SendLetterRequest> requests = (List<SendLetterRequest>) JSON.deserialize(requests_string, List<SendLetterRequest>.class);
        sendLetters(requests);
    }

    private static void sendLetters(List<SendLetterRequest> requests) {
        ApiCommandLettersBulkPost letters_bulk_post_command = new ApiCommandLettersBulkPost();
        prepareApiSendLetterRequests(letters_bulk_post_command, requests);
        HttpResponse response = ApiCommandsFactory.getInstance().performApiCommandCallout(letters_bulk_post_command);
        if (letters_bulk_post_command.CommandSuccessful) {
            addLetterTasks(requests, response.getStatusCode());
        } else {
            addLetterTasks(requests, response.getStatusCode());
            sendErrorMessagesToAdmins(requests);
        }
    }

    private static void prepareApiSendLetterRequests(ApiCommandLettersBulkPost command, List<SendLetterRequest> requests) {
        for(SendLetterRequest request : requests) {
            command.addSendLetterRequest(request.LoanGuid, request.TemplateName, 'auto');
        }
    }

    private static void addLetterTasks(List<SendLetterRequest> requests, Integer status_code) {
        List<Task> letter_tasks = new List<Task>();
        for (SendLetterRequest request : requests) {
            letter_tasks.add(createLetterTask(request.CaseRecord.Loan__c, request.TemplateLabel, status_code));
            letter_tasks.add(createLetterTask(request.CaseRecord.Id, request.TemplateLabel, status_code));
        }
        insert letter_tasks;
    }

    private static Task createLetterTask(String related_to_id, String template_name, Integer status_code) {
        String task_subject = getTaskSubject(template_name, status_code);
        return TaskBuilder.getBuilder()
                .setSubject(task_subject)
                .setStatus('Completed')
                .setType('Letter')
                .setRelatedTo(related_to_id)
                .setRecordType(RecordTypeUtility.TASK_COLLECTIONS_LETTER)
                .setCompletedDateTime(Datetime.now())
                .getRecord();
    }

    private static String getTaskSubject(String template_name, Integer status_code) {
        if(status_code == 200) {
            return getTaskSubjectWhenSuccess200(template_name);
        } else if (status_code == 202) {
            return getTaskSubjectWhenSuccess202(template_name);
        } else {
            return getTaskSubjectWhenFail(template_name);
        }
    }

    private static String getTaskSubjectWhenSuccess200(String template_name) {
        return 'Letter Sent (Automatically) - ' + template_name;
    }

    private static String getTaskSubjectWhenSuccess202(String template_name) {
        return 'Letter Accepted to Send (Automatically) - ' + template_name;
    }

    private static String getTaskSubjectWhenFail(String template_name) {
        return 'Failed to Send Letter (Automatically) - ' + template_name;
    }

    private static void sendErrorMessagesToAdmins(List<SendLetterRequest> requests) {
        String requests_report = prepareRequestsReport(requests);
        List<String> admins_addresses = getAdminsAddresses();
        Messaging.SingleEmailMessage email_to_send = prepareMessageForAdmin(admins_addresses, requests_report);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email_to_send}, false);
    }

    private static String prepareRequestsReport(List<SendLetterRequest> requests) {
        String requests_report = '';
        for(SendLetterRequest request : requests) {
            requests_report += ''
                    + 'Loan Guid: ' + request.LoanGuid + ' - '
                    + 'Case Id: ' + request.CaseRecord.Id + ' - '
                    + 'Template Name: ' + request.TemplateName + '<br/>';
        }
        return requests_report;
    }

    private static List<String> getAdminsAddresses() {
        Id admin_profile_id = ProfileUtilities.getInstance().getProfileIdForType(ProfileUtilities.ProfileType.SYSADMIN);
        List<String> admins_addresses = new List<String>();
        for (User admin_user : [SELECT Email FROM User WHERE ProfileId = :admin_profile_id AND isActive = true]) {
            admins_addresses.add(admin_user.Email);
        }
        return admins_addresses;
    }

    private static Messaging.SingleEmailMessage prepareMessageForAdmin(List<String> to_addresses, String requests_report) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(to_addresses);
        mail.setSubject('Failed to send letters Automatically.');
        String body = 'Failed to send letters Automatically from Process Builder: Collections Letters.<br/><br/>';
        body += 'Letters to send:<br/>';
        body += requests_report;
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(false);
        return mail;
    }

    global class SendLetterRequest {
        @InvocableVariable(label='Case' required=true)
        global Case CaseRecord;

        @InvocableVariable(label='Template Name' required=true)
        global String TemplateName;

        @InvocableVariable(label='Template Label' required=true)
        global String TemplateLabel;

        @InvocableVariable(label='Loan Guid' required=true)
        global String LoanGuid;
    }
}