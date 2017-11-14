<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Change_Approval_Alert</fullName>
        <ccEmails>gareth.macquillin@zopa.com</ccEmails>
        <ccEmails>Vishal.Bharakhda@zopa.com</ccEmails>
        <description>Change - Approval Alert</description>
        <protected>false</protected>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Assigned_Change_Approval</template>
    </alerts>
    <alerts>
        <fullName>Change_Approval_Alert_Jon</fullName>
        <ccEmails>jonathan@zopa.com</ccEmails>
        <description>Change - Approval Alert - Jon</description>
        <protected>false</protected>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Assigned_Change_Approval</template>
    </alerts>
    <alerts>
        <fullName>Change_Approved_Gareth</fullName>
        <ccEmails>gareth.macquillin@zopa.com</ccEmails>
        <description>Change - Approved - Gareth</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Tech_Templates/Assigned_Change_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_Change_Approved_Alex</fullName>
        <ccEmails>alex.king@zopa.com</ccEmails>
        <description>Email Change Approved Alex</description>
        <protected>false</protected>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Assigned_Change_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_Change_Approved_Dean</fullName>
        <ccEmails>dean.ryan@zopa.com</ccEmails>
        <description>Email Change Approved Dean</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Tech_Templates/Assigned_Change_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_Change_Approved_Tosin</fullName>
        <ccEmails>tosin.wilkie@zopa.com</ccEmails>
        <description>Email Change Approved Tosin</description>
        <protected>false</protected>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/Assigned_Change_Approved</template>
    </alerts>
    <rules>
        <fullName>Change - Update Approved for Alex</fullName>
        <actions>
            <name>Email_Change_Approved_Alex</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Change__c.Approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Change__c.CreatedById</field>
            <operation>equals</operation>
            <value>Alex King</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change - Update Approved for Dean</fullName>
        <actions>
            <name>Email_Change_Approved_Dean</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Change__c.Approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Change__c.CreatedById</field>
            <operation>equals</operation>
            <value>Dean Ryan</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change - Update Approved for Gareth</fullName>
        <actions>
            <name>Change_Approved_Gareth</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Change__c.Approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Change__c.CreatedById</field>
            <operation>equals</operation>
            <value>Gareth MacQuillin</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change - Update Approved for Tosin</fullName>
        <actions>
            <name>Email_Change_Approved_Tosin</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Change__c.Approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Change__c.CreatedById</field>
            <operation>equals</operation>
            <value>Tosin Wilkie</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
