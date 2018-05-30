<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>GMS_Fulfillment</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>GMS Fulfillment</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>Shipment_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Steelbrick_Email_Templates/GMS_Fulfillment</template>
    </alerts>
    <alerts>
        <fullName>VRX_Fulfillment</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>VRX Fulfillment</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>Shipment_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Steelbrick_Email_Templates/VRX_Fulfillment</template>
    </alerts>
    <alerts>
        <fullName>VX_Fulfillment</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>VX Fulfillment</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sale Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>Shipment_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Steelbrick_Email_Templates/VX_Fulfillment</template>
    </alerts>
    <alerts>
        <fullName>test</fullName>
        <description>test</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>prane@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Welcome_Email_Test</template>
    </alerts>
    <fieldUpdates>
        <fullName>Populate_First_Order_field</fullName>
        <field>First_Order__c</field>
        <literalValue>1</literalValue>
        <name>Populate First Order field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SBCF_Set_Contracted_to_True</fullName>
        <field>SBQQ__Contracted__c</field>
        <literalValue>1</literalValue>
        <name>SBCF Set Contracted to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SBCF_Set_Contracting_Method</fullName>
        <field>SBQQ__ContractingMethod__c</field>
        <literalValue>Single Contract</literalValue>
        <name>SBCF Set Contracting Method</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SBCF_Set_Shipment_Contact_to_PO_Contact</fullName>
        <field>Shipping_Status__c</field>
        <name>SBCF Set Shipment Contact to PO Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>GMS Fulfillment Email</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.GMS_Count__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.SBQQ__Contracted__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Product_Type__c</field>
            <operation>equals</operation>
            <value>NX/VX</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>GMS_Fulfillment</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Order.ActivatedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Populate First Order</fullName>
        <actions>
            <name>Populate_First_Order_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
SBQQ__Quote__r.Order_Count__c==1,
IsPickVal(Status ,&quot;Activated&quot;),
Virtual_Product_Count__c &gt;0
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SBCF Set Contracted to True</fullName>
        <actions>
            <name>SBCF_Set_Contracted_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SBCF Set Contracting Method</fullName>
        <actions>
            <name>SBCF_Set_Contracting_Method</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL( SBQQ__Quote__r.Product_Type__c , &quot;EDGECONNECT&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>VRX Fulfillment Email</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.VRX_Count__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.SBQQ__Contracted__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Product_Type__c</field>
            <operation>equals</operation>
            <value>NX/VX</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>VRX_Fulfillment</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Order.ActivatedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>VX Fulfillment Email</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.VX_Count__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.SBQQ__Contracted__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Product_Type__c</field>
            <operation>equals</operation>
            <value>NX/VX</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>VX_Fulfillment</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Order.ActivatedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
