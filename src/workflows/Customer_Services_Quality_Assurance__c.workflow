<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AddCDevPCt</fullName>
        <description>Adds the percentage score to the Cdev Percent</description>
        <field>CdevPct__c</field>
        <formula>CDevScore__c/ CdevMaxScore__c</formula>
        <name>AddCDevPCt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPInboundPctupdate</fullName>
        <field>CPinboundPct__c</field>
        <formula>CpInboundScore__c / CPInboundMaxScore__c</formula>
        <name>CPInboundPctupdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CPInboundPctPopulate</fullName>
        <actions>
            <name>CPInboundPctupdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Services_Quality_Assurance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CP_Inbound_Call_Scorecard</value>
        </criteriaItems>
        <description>Populates the CPinboundPct field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CdevPctPopulate</fullName>
        <actions>
            <name>AddCDevPCt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Services_Quality_Assurance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Client Dev ScoreCard</value>
        </criteriaItems>
        <description>Populates the CdevPct field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
