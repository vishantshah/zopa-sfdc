<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_IT_Support</fullName>
        <ccEmails>alex.king@zopa.com</ccEmails>
        <ccEmails>tosin.wilkie@zopa.com</ccEmails>
        <ccEmails>michael.oswell@zopa.com</ccEmails>
        <description>Alert IT Support</description>
        <protected>false</protected>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/New_Case_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Alert_Infrastructure</fullName>
        <ccEmails>vishal.bharakhda@zopa.com</ccEmails>
        <description>Alert Infrastructure</description>
        <protected>false</protected>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/New_Case_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Alert_Tech_Support</fullName>
        <ccEmails>toby.smith@zopa.com</ccEmails>
        <ccEmails>thomas@zopa.com</ccEmails>
        <ccEmails>bolaji.abikoye@zopa.com</ccEmails>
        <ccEmails>collette.gray@zopa.com</ccEmails>
        <description>Alert Tech Support</description>
        <protected>false</protected>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/New_Case_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Assigned_to_Chris</fullName>
        <ccEmails>chris.leader@zopa.com</ccEmails>
        <description>Assigned to Chris</description>
        <protected>false</protected>
        <senderAddress>contact-us@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/New_Case_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Assigned_to_Yemi</fullName>
        <ccEmails>Opeyemi.Akinnayajo@zopa.com</ccEmails>
        <description>Assigned to Yemi</description>
        <protected>false</protected>
        <senderAddress>contact-us@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/New_Case_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Case_2_Day_Notification</fullName>
        <description>Case 2 Day Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Tech_Automatic_Response_2days</template>
    </alerts>
    <alerts>
        <fullName>Case_2_Day_Notification2</fullName>
        <description>Case 2 Day Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Tech_Automatic_Response_2days</template>
    </alerts>
    <alerts>
        <fullName>Case_Assigned_Alert</fullName>
        <description>Case Assigned Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Assigned_Tech_Case</template>
    </alerts>
    <alerts>
        <fullName>Case_Closed_Inactivity_Alert</fullName>
        <description>Case Closed Inactivity Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Closed_Tech_Case_Inactivity</template>
    </alerts>
    <alerts>
        <fullName>Email_HR_about_HR_Notification</fullName>
        <ccEmails>hr@zopa.com</ccEmails>
        <description>Email HR about HR Notification</description>
        <protected>false</protected>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Tech_Automatic_Response</template>
    </alerts>
    <alerts>
        <fullName>New_Case_Alert</fullName>
        <ccEmails>zopianitteam@zopa.com</ccEmails>
        <description>New Case Alert</description>
        <protected>false</protected>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Tech_Auto_Response_Mod</template>
    </alerts>
    <alerts>
        <fullName>New_Weekend_IT_Alert</fullName>
        <ccEmails>matthew.brunton@zopa.com</ccEmails>
        <ccEmails>07738001948@txtlocal.co.uk</ccEmails>
        <ccEmails>07732441472@txtlocal.co.uk</ccEmails>
        <ccEmails>07983309768@txtlocal.co.uk</ccEmails>
        <description>New Weekend IT Alert</description>
        <protected>false</protected>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Auto_Response/New_Case_Opened_Weekend</template>
    </alerts>
    <alerts>
        <fullName>Notify_HR</fullName>
        <ccEmails>hr@zopa.com</ccEmails>
        <description>Notify HR</description>
        <protected>false</protected>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Tech_Automatic_Response</template>
    </alerts>
    <alerts>
        <fullName>Notify_Initial_underwriter_user_for_case_review</fullName>
        <description>Notify Initial underwriter user for case review</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Case_Management/ReviewCaseRequest</template>
    </alerts>
    <alerts>
        <fullName>Send_Case_Closed_Notification</fullName>
        <description>Send Case Closed Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Closed_Tech_Case</template>
    </alerts>
    <alerts>
        <fullName>Send_Case_Reminder_Notification</fullName>
        <description>Send Case Reminder Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Tech_Automatic_Response_2days</template>
    </alerts>
    <alerts>
        <fullName>Send_Case_Update_Notification</fullName>
        <description>Send Case Update Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Tech_Templates/Tech_Auto_Response_Update</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_Kylie</fullName>
        <ccEmails>kylie.akers@zopa.com</ccEmails>
        <description>Send Email to Kylie</description>
        <protected>false</protected>
        <senderAddress>contact-us@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/New_Case_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_Rakhi</fullName>
        <ccEmails>rakhi.patel@zopa.com</ccEmails>
        <description>Send email to Rakhi</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Tech_Templates/New_Case_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Sending_Automatic_Reminder_by_email</fullName>
        <ccEmails>emailtosalesforce@0-9y81cdohaha4yzxb7mb9levp7wzik9esldczqybnsh7pe2iq8.2-lh0keaq.eu9.le.salesforce.com</ccEmails>
        <description>Sending Automatic Reminder by email</description>
        <protected>false</protected>
        <recipients>
            <field>Workflow_Emailing_Person_Account__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>zopa.loans@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Underwriter/AutDocRem</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Set_Owned_Date</fullName>
        <field>Date_Owned__c</field>
        <formula>NOW()</formula>
        <name>Case Set Owned Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clean_Automatic_Cancel_Date</fullName>
        <field>Automatic_Cancel_Date__c</field>
        <name>Clean Automatic Cancel Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clean_Automatic_Reminder_Date</fullName>
        <field>Automatic_Reminder_Date__c</field>
        <name>Clean Automatic Reminder Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ClosetheChat</fullName>
        <description>Updates the status of the chat case to closed.</description>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>ClosetheChat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Collection_Set_Case_Category</fullName>
        <field>Call_Reason__c</field>
        <literalValue>Collections Call</literalValue>
        <name>Collection - Set Case Category</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CpAssignment</fullName>
        <field>CasePrepAssignment__c</field>
        <literalValue>1</literalValue>
        <name>CpAssignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Save_sub_process_value</fullName>
        <field>Previous_Sub_Process__c</field>
        <formula>TEXT( PRIORVALUE( Sub_Process__c ) )</formula>
        <name>Save sub-process value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetLoanAsAutoCanceled</fullName>
        <field>Auto_Canceled_Loan__c</field>
        <literalValue>1</literalValue>
        <name>SetLoanAsAutoCanceled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetOwnerOnHold</fullName>
        <field>OwnerId</field>
        <lookupValue>On_Hold</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>SetOwnerOnHold</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_As_Closed</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Set As Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Assign_to_Tech_True</fullName>
        <field>Assign_to_Tech__c</field>
        <literalValue>1</literalValue>
        <name>Set Assign to Tech True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_CAse_reason_as_Junk</fullName>
        <field>Call_Reason__c</field>
        <literalValue>Junk</literalValue>
        <name>Set CAse reason as Junk</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Call_Reason_as_Rapid_Return</fullName>
        <field>Call_Reason__c</field>
        <literalValue>Access to Funds/Rapid returns</literalValue>
        <name>Set Call Reason as Rapid Return</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Status_to_In_Progress</fullName>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>Set Case Status to &quot;In Progress&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Complaint_Flag</fullName>
        <field>Complaint__c</field>
        <literalValue>1</literalValue>
        <name>Set Complaint Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Joiner</fullName>
        <description>Set_Joiner</description>
        <field>Call_Reason__c</field>
        <literalValue>Joiner</literalValue>
        <name>Set_Joiner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Leaver</fullName>
        <field>Call_Reason__c</field>
        <literalValue>Leaver</literalValue>
        <name>Set_Leaver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Priority_High</fullName>
        <field>Priority</field>
        <literalValue>High</literalValue>
        <name>Set Priority High</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Priority_High_Cancel</fullName>
        <field>Priority</field>
        <literalValue>High</literalValue>
        <name>Set Priority High</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_as_Pending</fullName>
        <field>Status</field>
        <literalValue>Pending</literalValue>
        <name>Set Status as Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Tech_Assigned_Date</fullName>
        <field>Assigned_to_Tech_Time__c</field>
        <formula>Now()</formula>
        <name>Set Tech Assigned Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_to_Lender</fullName>
        <field>OwnerId</field>
        <lookupValue>Lenders</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set to Lender</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UnderCaseFloW</fullName>
        <description>Updates the field to show that this is an underwriting case</description>
        <field>UnderwritingAssignment__c</field>
        <literalValue>1</literalValue>
        <name>UnderCaseFloW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateFraudField</fullName>
        <description>This updates the field FraudCaseAssignment, after fraud case has been assigned to Fraud queue ( any )</description>
        <field>FraudCaseAssignment__c</field>
        <literalValue>1</literalValue>
        <name>UpdateFraudField</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Automatic_Cancel_Date_7</fullName>
        <field>Automatic_Cancel_Date__c</field>
        <formula>IF(ISBLANK( Automatic_Cancel_Date__c ), DATETIMEVALUE(TEXT(TODAY() + 7)+&quot; 18:00:00&quot;), Automatic_Cancel_Date__c)</formula>
        <name>Update Automatic Cancel Date +7</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Automatic_Reminder_Date</fullName>
        <description>When Status field becomes equals &quot;Pending&quot;, &quot;Automatic Reminder Date&quot; field must be updated to now + 72 hours.</description>
        <field>Automatic_Reminder_Date__c</field>
        <formula>IF(ISBLANK(  Automatic_Reminder_Date__c ), NOW() + 3, Automatic_Reminder_Date__c )</formula>
        <name>Update Automatic Reminder Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Call_Reason_to_Login</fullName>
        <field>Call_Reason__c</field>
        <literalValue>Password Reset</literalValue>
        <name>Update_Call_Reason_to_Login</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Call_Reason_to_autotopup</fullName>
        <field>Call_Reason__c</field>
        <literalValue>Auto-top up</literalValue>
        <name>Update_Call_Reason_to_auto-topup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Call_Reason_to_fasttrack</fullName>
        <field>Call_Reason__c</field>
        <literalValue>Fast Track</literalValue>
        <name>Update_Call_Reason_to_fasttrack</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Reason</fullName>
        <field>Reason</field>
        <literalValue>Cancellation</literalValue>
        <name>Update Case Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Priority</fullName>
        <field>Priority</field>
        <literalValue>High</literalValue>
        <name>Update Priority</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_User_Type_Borrower</fullName>
        <field>User_Type__c</field>
        <literalValue>Borrower</literalValue>
        <name>Update_User_Type_Borrower</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_User_Type_Internal</fullName>
        <field>User_Type__c</field>
        <literalValue>Internal</literalValue>
        <name>Update_User_Type_Internal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_User_Type_Lender</fullName>
        <field>User_Type__c</field>
        <literalValue>Lender</literalValue>
        <name>Update_User_Type_Lender</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_call_reason_to_cancellation</fullName>
        <field>Call_Reason__c</field>
        <literalValue>Cancellation</literalValue>
        <name>Update_call_reason_to cancellation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>2 Day Awaiting Response</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Tech Support Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Manual Underwriting</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Case_2_Day_Notification2</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_Status_as_Pending</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Case_Closed_Inactivity_Alert</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_As_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>6</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Add Case Team to Case</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Tech Support</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Login Reason</fullName>
        <actions>
            <name>Update_Call_Reason_to_Login</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8</booleanFilter>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Log in</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Login</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Login</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Log in</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>log in</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>login</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>login</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>log in</value>
        </criteriaItems>
        <description>Looks for Login patterns and assigns to Login Call Reason</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Assign to Tech team</fullName>
        <actions>
            <name>Alert_Tech_Support</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Tech_Assigned_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>Assign_to_Tech__c = True</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign_User_Type_Borrower</fullName>
        <actions>
            <name>Update_User_Type_Borrower</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Account.Expected_Usage__c</field>
            <operation>equals</operation>
            <value>Borrower</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Borrowers</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Tech Support Email</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Assign_User_Type_Lender</fullName>
        <actions>
            <name>Update_User_Type_Lender</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Account.Expected_Usage__c</field>
            <operation>equals</operation>
            <value>LenderNoneBusiness</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Lender</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Tech Support Email</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Assigned to IT Support</fullName>
        <actions>
            <name>Alert_IT_Support</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>IT Support</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assigned to Infrastructure</fullName>
        <actions>
            <name>Alert_Infrastructure</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Infrastructure</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AssignedToCollectionsAgent</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Collections &amp; Recoveries</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Assigned to Chris</fullName>
        <actions>
            <name>Assigned_to_Chris</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Chris Leader</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Assigned to Kylie</fullName>
        <actions>
            <name>Send_Email_to_Kylie</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Kylie Akers</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Assigned to Yemi</fullName>
        <actions>
            <name>Assigned_to_Yemi</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Opeyemi Akinnayajo</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Assignment Notification</fullName>
        <actions>
            <name>Case_Assigned_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>OR(Owner:User.UserRoleId = &apos;00E200000015bAN&apos;,Owner:User.UserRoleId = &apos;00E20000001nJDh&apos; ,Owner:User.UserRoleId = &apos;00E200000015bAI&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Closed Inactivity</fullName>
        <active>false</active>
        <formula>AND (NOT( ISBLANK( Tech_Owner__c)),  ISPICKVAL(Status ,&apos;Pending&apos;),   ISPICKVAL(Origin, &apos;Tech Support Email&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Case_Closed_Inactivity_Alert</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_As_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.LastModifiedDate</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Case Owned</fullName>
        <actions>
            <name>Case_Set_Owned_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND (ISCHANGED(OwnerId), ISBLANK(Date_Owned__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Set Internal</fullName>
        <actions>
            <name>Update_User_Type_Internal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Tech Support Email</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Set Leaver</fullName>
        <actions>
            <name>Set_Leaver</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Tech Support Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Leaver</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Leaver</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CaseHandlePendingStatus</fullName>
        <actions>
            <name>Update_Automatic_Cancel_Date_7</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Automatic_Reminder_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.DeveloperName = &apos;Manual_Underwriting&apos; &amp;&amp; ISPICKVAL(Status, &apos;Pending&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SetLoanAsAutoCanceled</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Automatic_Cancel_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Sending_Automatic_Reminder_by_email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Automatic_Reminder_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CasePrepCaseFlow</fullName>
        <actions>
            <name>CpAssignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Case Prep</value>
        </criteriaItems>
        <description>Picksup if a case has been assigned to case prep at any point</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CaseReviewForInitialUnderwriterNotification</fullName>
        <actions>
            <name>Notify_Initial_underwriter_user_for_case_review</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>if(  NOT(ISBLANK(Initial_Underwriter__c)),   AND(    OwnerId == Initial_Underwriter__r.Id,    PRIORVALUE(OwnerId) != Initial_Underwriter__r.Id  ),  false )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case_Joiner</fullName>
        <actions>
            <name>Set_Joiner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Joiner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Joiner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Tech Support</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Close Chat Case</fullName>
        <actions>
            <name>ClosetheChat</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>LiveChatTranscript.EndedBy</field>
            <operation>equals</operation>
            <value>Agent,Visitor,System</value>
        </criteriaItems>
        <description>Closes the chat case automatically</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Collections Urgent</fullName>
        <actions>
            <name>Set_Priority_High</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Callback,Mental,Deceased,Died,IVA,Hospital,Terminal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>equals</operation>
            <value>Callback,Mental,Deceased,Died,IVA,Hospital,Terminal</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CreanAutomaticProcessesDateWhenStatusChangedFromPending</fullName>
        <actions>
            <name>Clean_Automatic_Cancel_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clean_Automatic_Reminder_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Remove any value in Automatic Reminder Date Automatic Cancel Date, when a status is moved from Pending to something else but not in case of document upload</description>
        <formula>RecordType.DeveloperName = &apos;Manual_Underwriting&apos; &amp;&amp; ISCHANGED(Status)  &amp;&amp; ISPICKVAL(PRIORVALUE(Status), &apos;Pending&apos;) &amp;&amp;  NOT(ISPICKVAL(Status, &apos;Open - Document Received&apos;) || ISPICKVAL(Status, &apos;In Progress - Documents Received&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Dealer Invoice tasks</fullName>
        <actions>
            <name>Invoice_Processed</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>Sent_to_Print</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>dealerInvoices</value>
        </criteriaItems>
        <description>A SalesForce rule which creates 2 tasks upon creation of a dealer invoice case</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>FTF</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FraudCaseFlow</fullName>
        <actions>
            <name>UpdateFraudField</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Fraud</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>HR Notification</fullName>
        <actions>
            <name>Notify_HR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Tech Support Email,Zopian.IT,Data.IT,Appsupport.IT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>HR Notification</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Junk</fullName>
        <actions>
            <name>Set_As_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_CAse_reason_as_Junk</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Junk</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New IT Email Received</fullName>
        <actions>
            <name>New_Case_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  ISPICKVAL(Origin,&quot;Zopian.IT&quot;),  ISPICKVAL(PRIORVALUE
(Status), &quot;Pending&quot;)   , ISPICKVAL(Status, &quot;New&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New IT Email Received Weekend</fullName>
        <actions>
            <name>New_Weekend_IT_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  ISPICKVAL(Origin,&quot;Zopian.IT&quot;),  MOD(  DATEVALUE(CreatedDate)  - DATE(1900, 1, 7), 7)&gt;5)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Voicemail</fullName>
        <actions>
            <name>Set_to_Lender</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Expected_Usage__c</field>
            <operation>equals</operation>
            <value>Lender</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Contact Us Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Voicemail</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New_Collection_Case_Assign</fullName>
        <actions>
            <name>SetOwnerOnHold</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Collections &amp; Recoveries</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Is_Sensitive__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Save old Sub Process</fullName>
        <actions>
            <name>Save_sub_process_value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Sub_Process__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Assign to Tech</fullName>
        <actions>
            <name>Set_Assign_to_Tech_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Owner:Queue.Id = &apos;00G20000002n34t&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Call Reason as Auto Top-up</fullName>
        <actions>
            <name>Update_Call_Reason_to_autotopup</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4</booleanFilter>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>auto top up</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>auto top up</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>auto lend</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>auto lend</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Case Reason to Call Reason Value</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Call_Reason__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Case Status to In progress</fullName>
        <actions>
            <name>Set_Case_Status_to_In_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Case Status to In progress when the case is owned by a queue, has a status of &quot;open&quot; and is then assigned to a user.</description>
        <formula>ISBLANK(Owner:Queue.QueueName)&amp;&amp;!ISBLANK(Owner:User.LastName) &amp;&amp; ISPICKVAL(Status,&quot;Open&quot;) &amp;&amp; !ISNEW() &amp;&amp;  ISCHANGED(OwnerId)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set as Cancellation</fullName>
        <actions>
            <name>Set_Priority_High_Cancel</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_call_reason_to_cancellation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4</booleanFilter>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Cancel</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Cancel</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set as Collections Call</fullName>
        <actions>
            <name>Collection_Set_Case_Category</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Collections Email</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set as Complaint</fullName>
        <actions>
            <name>Set_Complaint_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Priority</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4</booleanFilter>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Complaint</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Complain</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Complaint</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Complain</value>
        </criteriaItems>
        <description>Detects the word Complaint and then sets the Complaint flag on the case</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set as Fast Track</fullName>
        <actions>
            <name>Update_Call_Reason_to_fasttrack</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Fast Track</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Fast Track</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set as Rapid Return</fullName>
        <actions>
            <name>Set_Call_Reason_as_Rapid_Return</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Rapid Return</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Rapid Return</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set as Web Issues</fullName>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4</booleanFilter>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>webproblems</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>error</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>error</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>webproblems</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Tech Case Updated</fullName>
        <actions>
            <name>Send_Case_Update_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Zopian.IT,Data.IT,Appsupport.IT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Tech_Case_Closed</fullName>
        <actions>
            <name>Send_Case_Closed_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Tech Support Email,Zopian.IT,Data.IT,Appsupport.IT</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UnderwritersCaseFlow</fullName>
        <actions>
            <name>UnderCaseFloW</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Underwrit</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Contacts</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Contact.AccountName</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Urgent Priority</fullName>
        <actions>
            <name>Set_Priority_High</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2 OR 3 OR 4) AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Comments</field>
            <operation>contains</operation>
            <value>Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Call_Reason__c</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sets priority as Urgent</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>fgrgfs</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.X3rd_Party__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Invoice_Processed</fullName>
        <assignedTo>tech@zopa.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>10</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Invoice Processed</subject>
    </tasks>
    <tasks>
        <fullName>Sent_to_Print</fullName>
        <assignedTo>tech@zopa.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>10</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Sent to Print</subject>
    </tasks>
</Workflow>
