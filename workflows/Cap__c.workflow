<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Comment_on_Cap_Record</fullName>
        <description>New Comment on Cap Record</description>
        <protected>false</protected>
        <recipients>
            <recipient>pmusunuru@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Comment_on_Cap</template>
    </alerts>
    <rules>
        <fullName>Send email notification on comments</fullName>
        <actions>
            <name>New_Comment_on_Cap_Record</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This WFR sends an email notification to the users whenever comments are added.</description>
        <formula>AND(
ISCHANGED(Cap_Comments__c),
(Cap_Comments__c &lt;&gt; Null)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
