public class CustomSettingInitialization {
    @TestVisible private static final Map<String,String> DOCUMENT_TYPES = new Map<String,String> {'Bank Statement' => 'BankStatement', 'Driving Licence' => 'DrivingLicence',
                'Passport' => 'Passport', 'Payslip' => 'Payslip', 'Tax return' => 'TaxReturn', 'Change of name' => 'ChangeOfName', 'Return to work letter' => 'ReturnToWorkLetter',
                'Contract of Employment' => 'EmploymentContract', 'Right to reside in the UK' => 'ProofOfRightToResideInUK', 'Proof of address' => 'ProofOfAddress'};

    @TestVisible private static final List<String> NEW_TASKS_SUBJECTS = new List<String> {
                                                'Security telephone check',
                                                'Request additional documents',
                                                'Exception sign off',
                                                'Manual Tamper check',
                                                'Aut10tix check',
                                                'Update Affordability Calculator',
                                                'App Support/Tech',
                                                'Request OFA details',
                                                'Manual credit search',
                                                'Load CIFAS',
                                                'Carry out web checks for proof of employment/business',
                                                'Call to employer/business',
                                                'Carry out web checks for proof of trading',
                                                'Call to accountant for proof of trading',
                                                'Check all declared addresses have been searched',
                                                'Interbank check',
                                                'Check with Collections regarding missed Zopa loan payments',
                                                'Review Metadata'};

    @TestVisible private static final List<String> NEW_TASKS_SUBJECTS_COLLECTIONS_CASE = new List<String> {
                                                'Collections - Sent loan balance',
                                                'Collections - Sent Repayment Offer response',
                                                'Collections - Sent Trust Deed/IVA/DAS response',
                                                'Collections - Sent Bankruptcy/Sequestration response',
                                                'Collections - Sent Death Certificate/deceased related correspondence',
                                                'Collections - Sent financial difficulties letter',
                                                'Collections - Sent DD re-apply letter',
                                                'Collections - Sent Other',
                                                'Collections - Received third party authority balance request',
                                                'Collections - Received Financial Statement',
                                                'Collections - Received Repayment Offer',
                                                'Collections - Received notification of no payment',
                                                'Collections - Received Trust Deed/IVA/DAS',
                                                'Collections - Received Bankruptcy/Sequestration notification',
                                                'Collections - Received Cheque',
                                                'Collections - Received Notification of financial difficulties',
                                                'Collections - Received Death Certificate',
                                                'Collections - Received Returned post notification',
                                                'Collections - Received other',
                                                'Collections - Equifax trace',
                                                'Other',
                                                'Recoveries - Received settlement offer',
                                                'Recoveries - Sent response to settlement offer',
                                                'Recoveries - Sent "Defaulted referring to Cabot" email',
                                                'Recoveries - Sent case to Cabot',
                                                'Recoveries - Sent out income and expenditure form'};

    @TestVisible private static final Map<String,String> NEW_COMPANY_CLASS_OPTIONS = new Map<String,String> {
                                                'Unknown' => 'Unknown',
                                                'Accountancy' => 'Accountancy',
                                                'Bank Non Clsb' => 'BankNonClsb',
                                                'Bank' => 'Bank',
                                                'Building Society' => 'BuildingSociety',
                                                'Credit Broker' => 'CreditBroker',
                                                'Credit Card' => 'CreditCard',
                                                'Customs Excise' => 'CustomsExcise',
                                                'Cheque Guarantor' => 'ChequeGuarantor',
                                                'Charge Card' => 'ChargeCard',
                                                'Credit Insurer' => 'CreditInsurer',
                                                'Consumer Letter' => 'ConsumerLetter',
                                                'Commercial Reporting' => 'CommercialReporting',
                                                'Communication Supplier' => 'CommunicationSupplier',
                                                'Debt Collector' => 'DebtCollector',
                                                'Distribution Wholesalers' => 'DistributionWholesalers',
                                                'Employment Agency' => 'EmploymentAgency',
                                                'Enquiry Agent' => 'EnquiryAgent',
                                                'Energy Supplier' => 'EnergySupplier',
                                                'Finance House' => 'FinanceHouse',
                                                'Financial Services' => 'FinancialServices',
                                                'General Insurance' => 'GeneralInsurance',
                                                'Government' => 'Government',
                                                'Hire Car Rental' => 'HireCarRental',
                                                'Home Furnisher' => 'HomeFurnisher',
                                                'Home Improvement' => 'HomeImprovement',
                                                'Home Lending' => 'HomeLending',
                                                'House Builder' => 'HouseBuilder',
                                                'Health Services' => 'HealthServices',
                                                'Hotel And Travel' => 'HotelAndTravel',
                                                'Insurance Broker' => 'InsuranceBroker',
                                                'Insurance' => 'Insurance',
                                                'Inland Revenue' => 'InlandRevenue',
                                                'Loss Adjuster' => 'LossAdjuster',
                                                'Leasing' => 'Leasing',
                                                'Motor Dealer' => 'MotorDealer',
                                                'Media' => 'Media',
                                                'Manufacturing Industrial' => 'ManufacturingIndustrial',
                                                'Marketing' => 'Marketing',
                                                'Miscellaneous' => 'Miscellaneous',
                                                'Mail Order' => 'MailOrder',
                                                'Mortgage Supplier' => 'MortgageSupplier',
                                                'Overseas' => 'Overseas',
                                                'Property Management' => 'PropertyManagement',
                                                'Police' => 'Police',
                                                'Public Utility' => 'PublicUtility',
                                                'Rental' => 'Rental',
                                                'Retailer' => 'Retailer',
                                                'Stock Broker' => 'StockBroker',
                                                'Solicitor' => 'Solicitor',
                                                'Slot Rental' => 'SlotRental',
                                                'Security Services' => 'SecurityServices',
                                                'Tv Programme Supplier' => 'TvProgrammeSupplier',
                                                'Travel Insurer' => 'TravelInsurer',
                                                'Third Party' => 'ThirdParty',
                                                'Tv Rental' => 'TvRental',
                                                'Training' => 'Training',
                                                'Zopa Application' => 'ZopaApplication'};

    @TestVisible private static final Map<String,String> NEW_ACCOUNT_TYPE_OPTIONS = new Map<String,String> {
                                                'Invalid' => 'Invalid',
                                                'Unknown' => 'Unknown',
                                                'Bank Default' => 'BankDefault',
                                                'Hire Purchase' => 'HirePurchase',
                                                'Loan' => 'Loan',
                                                'Mortgage' => 'Mortgage',
                                                'Budget Card' => 'BudgetCard',
                                                'Credit Card' => 'CreditCard',
                                                'Charge Card' => 'ChargeCard',
                                                'Rental' => 'Rental',
                                                'Mail Order Agency' => 'MailOrderAgency',
                                                'Fixed Term' => 'FixedTerm',
                                                'Fixed Term Deferred' => 'FixedTermDeferred',
                                                'Secured Loan' => 'SecuredLoan',
                                                'Option Account' => 'OptionAccount',
                                                'Varying Subscription' => 'VaryingSubscription',
                                                'Current Account' => 'CurrentAccount',
                                                'Overdraft' => 'Overdraft',
                                                'Public Utility' => 'PublicUtility',
                                                'Communications Supplier' => 'CommunicationsSupplier',
                                                'Balloon Lease' => 'BalloonLease',
                                                'Lease Purchase' => 'LeasePurchase',
                                                'Bounced Cheque' => 'BouncedCheque',
                                                'Council Arrears' => 'CouncilArrears',
                                                'Lease Residual' => 'LeaseResidual',
                                                'Share Dealing' => 'ShareDealing',
                                                'Home Lending' => 'HomeLending',
                                                'Student Loans' => 'StudentLoans',
                                                'Insurance' => 'Insurance',
                                                'PayDay Loan' => 'PayDayLoan',
                                                'Rent' => 'Rent'};

    @TestVisible private static final Map<String,String> NEW_TASKS_REASON_COLLECTIONS_CALL_CASE = new Map<String,String> {
                                                'Reached voicemail' => 'Reached voicemail, left a message.',
                                                'Bad number' => 'Bad number – Disconnected, not in service, not recognised.',
                                                'No response' => 'No response/answer and no option to leave a message.',
                                                'Number does not relate to borrower' => 'Number does not relate to borrower – wrong number.',
                                                'Answered by third party' => 'Answered by third party – borrower not available.',
                                                'Borrower answered refused DPA' => 'Borrower answered - refused DPA.',
                                                'Borrower answered requested call back' => 'Borrower answered – requested call back or advised would call us back.',
                                                'Borrower answered then terminated on being' => 'Borrower answered – then terminated on being advised its Zopa calling.'};

    @TestVisible private static final Map<String,String> OTHER_OPTIONS_FOR_LOG_A_CALL = new Map<String,String> {
                                                'Test 1' => 'Test First',
                                                'Test 2' => 'Test Second',
                                                'Test 3' => 'Test Third'};

    public static void createDefaultMUTaskSubjects() {
        if (Manual_Underwriting_Task_Subjects__c.getAll() == new Map<String, Manual_Underwriting_Task_Subjects__c>()) {
            List<Manual_Underwriting_Task_Subjects__c> subject_settings = new List<Manual_Underwriting_Task_Subjects__c>();
            for (String subject : NEW_TASKS_SUBJECTS) {
                subject_settings.add(new Manual_Underwriting_Task_Subjects__c(Name = subject.left(38), Task_Subject__c = subject));
            }
            insert subject_settings;
        }
    }

    public static void createDefaultCRTaskSubjects() {
        if (Collections_Recoveries_Task_Subjects__c.getAll() == new Map<String, Collections_Recoveries_Task_Subjects__c>()) {
            List<Collections_Recoveries_Task_Subjects__c> subject_settings = new List<Collections_Recoveries_Task_Subjects__c>();
            for (String subject : NEW_TASKS_SUBJECTS_COLLECTIONS_CASE) {
                subject_settings.add(new Collections_Recoveries_Task_Subjects__c(Name = getDefaultCRTaskSubjectsName(subject), Task_Subject__c = subject));
            }
            insert subject_settings;
        }
    }

    private static String getDefaultCRTaskSubjectsName(String subject){
        subject = subject.remove('Collections - ');
        subject = subject.remove('Recoveries - ');
        subject = subject.remove(' ');
        subject = subject.remove('"');
        return subject.left(38);
    }

    public static void createDefaultZopaDocumentTypes() {
        if (Available_Document_Types__c.getAll() == new Map<String, Available_Document_Types__c>()) {
            List<Available_Document_Types__c> doc_settings = new List<Available_Document_Types__c>();
            for (String doc_type : DOCUMENT_TYPES.keySet()) {
                String zopa_doc_type = DOCUMENT_TYPES.get(doc_type);
                doc_settings.add(new Available_Document_Types__c(Name = doc_type, Zopa_Value__c = zopa_doc_type));
            }
            insert doc_settings;
        }
    }

    public static void createCompanyClassOptions() {
        if (Company_Class_Options_MU__c.getAll() == new Map<String, Company_Class_Options_MU__c>()) {
            List<Company_Class_Options_MU__c> company_class_settings = new List<Company_Class_Options_MU__c>();
            for (String company_class_setting : NEW_COMPANY_CLASS_OPTIONS.keySet()) {
                String zopa_company_class_setting = NEW_COMPANY_CLASS_OPTIONS.get(company_class_setting);
                company_class_settings.add(new Company_Class_Options_MU__c(Name = company_class_setting, Zopa_Value__c = zopa_company_class_setting));
            }
            insert company_class_settings;
        }
    }

    public static void createAccountTypeOption() {
        delete [SELECT Id FROM Account_Type_Option_MU__c];
        List<Map<String,String>> csv_data_from_static_resource = CsvUtility.getDataFromCsvStaticResource('AccountType');
        List<Account_Type_Option_MU__c> account_type_settings = new List<Account_Type_Option_MU__c>();
        for (Map<String,String> account_type_setting_map : csv_data_from_static_resource) {
            String account_type_name = account_type_setting_map.get('Name');
            String account_type_zopa_value = account_type_setting_map.get('Zopa_Value__c');
            String account_type_row_type = account_type_setting_map.get('Row_Type__c');
            account_type_settings.add(new Account_Type_Option_MU__c(Name = account_type_name, Zopa_Value__c = account_type_zopa_value, Row_Type__c = account_type_row_type));
        }
        upsert account_type_settings;
    }

    public static void createDefaultCRTaskReasons() {
        if (Collections_Call_Task_Reason__c.getAll() == new Map<String, Collections_Call_Task_Reason__c>()) {
            List<Collections_Call_Task_Reason__c> company_class_settings = new List<Collections_Call_Task_Reason__c>();
            for (String company_class_setting : NEW_TASKS_REASON_COLLECTIONS_CALL_CASE.keySet()) {
                String zopa_company_class_setting = NEW_TASKS_REASON_COLLECTIONS_CALL_CASE.get(company_class_setting);
                company_class_settings.add(new Collections_Call_Task_Reason__c(Name = company_class_setting.left(38), Task_Reason__c = zopa_company_class_setting));
            }
            insert company_class_settings;
        }
    }

    public static void createSettingsForMock(){
        Set<String> list_existing_mock_manager_settings = Mock_Manager_for_Callout__c.getAll().keySet();
        List<Zopa_Api_Command__mdt> command_info =[SELECT Name_of_the_mock_class__c FROM Zopa_Api_Command__mdt WHERE Name_of_the_mock_class__c != null];
        Set<Mock_Manager_for_Callout__c> set_new_mocks = new Set<Mock_Manager_for_Callout__c>();
        for (Zopa_Api_Command__mdt current_command: command_info){
            if (!list_existing_mock_manager_settings.contains(current_command.Name_of_the_mock_class__c)){
                set_new_mocks.add(new Mock_Manager_for_Callout__c(Name = current_command.Name_of_the_mock_class__c));
            }
        }
        if (set_new_mocks.size() != 0){
            insert new List<Mock_Manager_for_Callout__c> (set_new_mocks);
        }
    }

    public static void createOtherOptionsForLogACall() {
        if (Log_a_Call_Other_Options__c.getAll() == new Map<String, Log_a_Call_Other_Options__c>()) {
            List<Log_a_Call_Other_Options__c> company_class_settings = new List<Log_a_Call_Other_Options__c>();
            for (String company_class_setting : OTHER_OPTIONS_FOR_LOG_A_CALL.keySet()) {
                String zopa_company_class_setting = OTHER_OPTIONS_FOR_LOG_A_CALL.get(company_class_setting);
                company_class_settings.add(new Log_a_Call_Other_Options__c(Name = company_class_setting.left(38), Value__c = zopa_company_class_setting));
            }
            insert company_class_settings;
        }
    }
}