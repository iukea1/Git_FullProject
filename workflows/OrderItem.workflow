<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Unity_Cloud_Orchestrator</fullName>
        <field>Is_Unity_Cloud_orchestrator__c</field>
        <literalValue>1</literalValue>
        <name>Update Unity Cloud Orchestrator</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Check Unity Cloud Orchestrator</fullName>
        <actions>
            <name>Update_Unity_Cloud_Orchestrator</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND (
NOT(ISNULL(Id )),
CONTAINS(Product2.Name ,&quot;EC-ORCH-AAS&quot;)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
