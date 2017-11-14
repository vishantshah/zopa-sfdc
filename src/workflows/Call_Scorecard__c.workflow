<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Call_Scorecard_Set_Total_Percent</fullName>
        <field>Total_Percent__c</field>
        <formula>(Total_Points__c/Total_Possible_Points__c)</formula>
        <name>Call Scorecard Set Total Percent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Total Percent</fullName>
        <actions>
            <name>Call_Scorecard_Set_Total_Percent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Scorecard__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
