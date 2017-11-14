<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Status_as_Escalated</fullName>
        <field>Status</field>
        <literalValue>Escalated</literalValue>
        <name>Set Status as Escalated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_as_Tech</fullName>
        <field>Status</field>
        <literalValue>With Tech</literalValue>
        <name>Set Status as Tech</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TFRT_Case_Comment_Added_by_Tech</fullName>
        <field>Tech_First_Response_Time__c</field>
        <formula>IF( ISBLANK(Parent.Tech_First_Response_Time__c),now(),Parent.Tech_First_Response_Time__c)</formula>
        <name>TFRT Case Comment Added by Tech</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tech_Comment_Status_New</fullName>
        <field>Status</field>
        <literalValue>New</literalValue>
        <name>Change Case Status New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>New Comment Added by Team Lead</fullName>
        <actions>
            <name>Tech_Comment_Status_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>CreatedBy.UserRoleId = &apos;00E20000001nJD8&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Comment by CS on Escalated</fullName>
        <actions>
            <name>Set_Status_as_Escalated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( CreatedById =  Parent.OwnerId ,  ISNULL(Parent.EscalationDateTime) = False)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Comment by CS on Tech Case</fullName>
        <actions>
            <name>Set_Status_as_Tech</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( CreatedBy.Id = Parent.OwnerId,  Parent.Assign_to_Tech__c = true)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TFRT Case Comment Added by Tech</fullName>
        <actions>
            <name>TFRT_Case_Comment_Added_by_Tech</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Parent.OwnerId &lt;&gt;  CreatedById</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
