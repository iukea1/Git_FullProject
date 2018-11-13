<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SBCF_Set_Contracting_Method_for_ORCH_AAS</fullName>
        <field>SBQQ__ContractingMethod__c</field>
        <literalValue>Contract Separately</literalValue>
        <name>SBCF Set Contracting Method for ORCH-AAS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_End_Date</fullName>
        <field>EndDate</field>
        <formula>SBQQ__QuoteLine__r.End_Date__c</formula>
        <name>Update End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Product_Family_field</fullName>
        <field>Product_Family__c</field>
        <formula>TEXT(PricebookEntry.Product2.Family)</formula>
        <name>Update Product Family field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Product_Name</fullName>
        <field>Product_Name__c</field>
        <formula>PricebookEntry.Product2.Name</formula>
        <name>Update Product Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Start_Date</fullName>
        <field>ServiceDate</field>
        <formula>SBQQ__QuoteLine__r.SBQQ__StartDate__c</formula>
        <name>Update Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
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
    <rules>
        <fullName>Populate Product Family on Order Product line</fullName>
        <actions>
            <name>Update_Product_Family_field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Product_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OrderItem.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SBCF Set Contracting Method for ORCH-AAS %26 Smart Hands</fullName>
        <actions>
            <name>SBCF_Set_Contracting_Method_for_ORCH_AAS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Name</field>
            <operation>startsWith</operation>
            <value>EC-ORCH-AAS</value>
        </criteriaItems>
        <description>removing product name starts with SMRT-HND 9.25.2018</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Start%2FEnd Date</fullName>
        <actions>
            <name>Update_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Used to set Start and End Date based off quote line. Currently order products is inheriting a random date. This is a workaround until the bug can be identified.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
