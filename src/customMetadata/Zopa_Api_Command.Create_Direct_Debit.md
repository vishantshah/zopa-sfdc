<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Create Direct Debit</label>
    <protected>true</protected>
    <values>
        <field>Http_Method__c</field>
        <value xsi:type="xsd:string">POST</value>
    </values>
    <values>
        <field>IsCollectionsCommand__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Name_of_the_mock_class__c</field>
        <value xsi:type="xsd:string">ApiCommandNewDirectDebitMock</value>
    </values>
    <values>
        <field>Url_Mapping_Contains_Letter_Id__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Url_Mapping_Contains_Letter_Send_Method__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Url_Mapping_Contains_Template_Name__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Url_Mapping_Contains_Uuid__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Url_Mapping__c</field>
        <value xsi:type="xsd:string">/loans/{id}/direct-debit-mandate</value>
    </values>
</CustomMetadata>
