<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Closed_By</fullName>
        <description>The Closed by Field is updated based on when the status is changed to Closed.</description>
        <field>Closed_By__c</field>
        <formula>LastModifiedBy.FirstName +&quot; &quot; +  LastModifiedBy.LastName</formula>
        <name>Update Closed By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Closed_Date</fullName>
        <field>Closed_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Capture Cap Closed Date</fullName>
        <actions>
            <name>Update_Closed_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to capture the date when the status is changed to Closed.</description>
        <formula>AND( ISCHANGED(Status__c), TEXT(Status__c) = &quot;Closed&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
