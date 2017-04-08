<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Email_Notification_Field</fullName>
        <field>New_Email_Notification_Text__c</field>
        <formula>TextBody</formula>
        <name>Update Email Notification Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Update New Email Notification Field</fullName>
        <actions>
            <name>Update_Email_Notification_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow captures the response from the user and populates in the New email notification field</description>
        <formula>AND( 
(Incoming= True),
(FromAddress =  Parent.SuppliedEmail), 
OR(
(Parent.RecordType.DeveloperName = &quot;Lab_Help_Requests&quot;), 
(Parent.RecordType.DeveloperName = &quot;DevOps_Help_Requests&quot;))
)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
