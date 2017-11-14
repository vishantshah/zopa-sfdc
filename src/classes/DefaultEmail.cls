global class DefaultEmail implements QuickAction.QuickActionDefaultsHandler {

    public static final String DEFAULT_RESPONSE_TEMPLATE = 'Branded_Standard';

    global DefaultEmail() { }

    // The only interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {

        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = getSendEmailFromCaseDefaults(defaults);

        if (sendEmailDefaults == null) return;

        EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();

        // set the template
        List<EmailTemplate> templates = [select id from EmailTemplate where developername = : DEFAULT_RESPONSE_TEMPLATE limit 1];
        if (templates.size() == 0) return;

        sendEmailDefaults.setTemplateId(templates[0].Id);
        sendEmailDefaults.setInsertTemplateBody(false);
        sendEmailDefaults.setIgnoreTemplateSubject(false);

    }

    private QuickAction.SendEmailQuickActionDefaults getSendEmailFromCaseDefaults(QuickAction.QuickActionDefaults[] defaults) {
        QuickAction.SendEmailQuickActionDefaults item;

        for (Integer j = 0; j < defaults.size(); j++) {

            if (!(defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults)) continue;

            item = (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
            if (item.getTargetSObject().getSObjectType() == EmailMessage.sObjectType &&
               item.getActionName().equals('Case.Email') &&
               item.getActionType().equals('Email')) {
                return item;
            }
        }

        // couldn't find the defaults
        return null;
    }
}