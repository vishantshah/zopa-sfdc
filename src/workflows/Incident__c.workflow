<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Incident_Email_Alert</fullName>
        <ccEmails>matthew.brunton@zopa.com</ccEmails>
        <description>New Incident Email Alert</description>
        <protected>false</protected>
        <senderAddress>tech@zopa.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Templates/New_Incident_Created</template>
    </alerts>
    <fieldUpdates>
        <fullName>Incident_Update_Close_Date</fullName>
        <field>Date_Closed__c</field>
        <formula>Now()</formula>
        <name>Incident Update Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Incident Set Closed Date</fullName>
        <actions>
            <name>Incident_Update_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Incident__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Incident Created</fullName>
        <actions>
            <name>New_Incident_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Incident__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
