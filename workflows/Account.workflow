<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_Partner_Application_Approved</fullName>
        <ccEmails>amenjivar@silver-peak.com, lauren@snapbi.com</ccEmails>
        <description>Account: Partner Application Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Partner_Marketing_Contact_E_Mail_Address__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Partner_Signatory_Contact_E_Mail_Address__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Primary_Partner_Contact_E_Mail_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/Partner_Application_Approved_HTML</template>
    </alerts>
    <alerts>
        <fullName>Account_Partner_Application_Approved_Marketing_Contact</fullName>
        <description>Account: Partner Application Approved Marketing Contact</description>
        <protected>false</protected>
        <recipients>
            <field>MarketingPartnerContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/Partner_Application_Approved_HTML_Marketing_Contact</template>
    </alerts>
    <alerts>
        <fullName>Account_Partner_Application_Approved_Primary_Contact</fullName>
        <ccEmails>lauren@snapbi.com</ccEmails>
        <description>Account: Partner Application Approved Primary Contact</description>
        <protected>false</protected>
        <recipients>
            <field>RegisteringUserContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/Partner_Application_Approved_HTML_Primary_Contact</template>
    </alerts>
    <alerts>
        <fullName>Account_Partner_Application_Approved_Signatory_Contact</fullName>
        <ccEmails>lauren@snapbi.com</ccEmails>
        <description>Account: Partner Application Approved Signatory Contact</description>
        <protected>false</protected>
        <recipients>
            <field>SignatoryPartnerContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/Partner_Application_Approved_HTML_Signatory_Contact</template>
    </alerts>
    <alerts>
        <fullName>Account_Partner_Application_Denied</fullName>
        <description>Account: Partner Application Denied</description>
        <protected>false</protected>
        <recipients>
            <field>PrimaryPartnerContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/Partner_Application_Denial</template>
    </alerts>
    <alerts>
        <fullName>Account_Partner_Application_Denied_Duplicate</fullName>
        <description>Account: Partner Application Denied - Duplicate</description>
        <protected>false</protected>
        <recipients>
            <recipient>pchavez@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/Partner_Application_Denied_Duplicate</template>
    </alerts>
    <alerts>
        <fullName>Account_Partner_Application_Overdue</fullName>
        <ccEmails>channel@silver-peak.com</ccEmails>
        <description>Account: Partner Application Overdue</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Partner_Account_Templates/Partner_Application_Approval_Overdue</template>
    </alerts>
    <alerts>
        <fullName>Account_Partner_Application_Pending</fullName>
        <ccEmails>lauren@snapbi.com</ccEmails>
        <description>Account: Partner Application Pending</description>
        <protected>false</protected>
        <recipients>
            <field>PrimaryPartnerContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/Partner_Application_Pending</template>
    </alerts>
    <alerts>
        <fullName>Account_Partner_Application_Submitted</fullName>
        <ccEmails>channel@silver-peak.com, lauren@snapbi.com</ccEmails>
        <description>Account: Partner Application Submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Field and Channel Marketing Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>ivara@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jkoh@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kpiper@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ltaelman@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/New_Partner_Application_Submitted</template>
    </alerts>
    <alerts>
        <fullName>Account_Send_New_Partner_Approved_Distributor_Alert</fullName>
        <ccEmails>lauren@snapbi.com</ccEmails>
        <description>Account: Send New Partner Approved Distributor Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ewhite@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/New_Partner_Approved_Distributor_Alert</template>
    </alerts>
    <alerts>
        <fullName>Account_Send_Partner_Application_Denial_Email</fullName>
        <description>Account: Send Partner Application Denial Email</description>
        <protected>false</protected>
        <recipients>
            <field>PrimaryPartnerContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/Partner_Application_Denial</template>
    </alerts>
    <alerts>
        <fullName>Expired_Flag_is_unchecked</fullName>
        <description>Expired Flag is unchecked</description>
        <protected>false</protected>
        <recipients>
            <recipient>shorton@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Expired_Customer_Flag_Unchecked</template>
    </alerts>
    <alerts>
        <fullName>Notify_Partner_Team_on_New_Partner_Creation</fullName>
        <ccEmails>lauren@snapbi.com</ccEmails>
        <description>Notify Partner Team on New Partner Creation</description>
        <protected>false</protected>
        <recipients>
            <recipient>amenjivar@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>bbruce@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ddalponte@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pchavez@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>shorton@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Account_Templates/Notification_New_Partner</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_To_Shari</fullName>
        <description>Send Email To Shari</description>
        <protected>false</protected>
        <recipients>
            <recipient>shorton@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Account_Type_To_Customer_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_Marketing_when_the_expired_customer_is_checked</fullName>
        <description>Send Email to Marketing when the expired customer is checked</description>
        <protected>false</protected>
        <recipients>
            <recipient>shorton@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Expired_Customer_Flag_checked</template>
    </alerts>
    <fieldUpdates>
        <fullName>Account_Set_App_Status_Denied_Dup</fullName>
        <description>sets partner application status = Denied - Duplicate Account</description>
        <field>Partner_Application_Status__c</field>
        <literalValue>Denied - Duplicate Account</literalValue>
        <name>Account: Set App Status Denied - Dup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_App_Status_Step_1_Approved</fullName>
        <field>Partner_Application_Status__c</field>
        <literalValue>Step 1 Approved</literalValue>
        <name>Account: Set App Status Step 1 Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Application_Status_Approved</fullName>
        <description>Set Partner Application Status to Approved</description>
        <field>Partner_Application_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Account: Set Application Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Application_Status_Denied</fullName>
        <description>Set Partner Application Status to Denied</description>
        <field>Partner_Application_Status__c</field>
        <literalValue>Denied</literalValue>
        <name>Account: Set Application Status Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Approved_Denied_Date</fullName>
        <description>The date the Account was approved or Denied</description>
        <field>Approved_Denied_Date__c</field>
        <formula>TODAY()</formula>
        <name>Account: Set Approved/Denied Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Partner_Level_to_Reigstered</fullName>
        <description>Partner Level Updates to Registered</description>
        <field>Partner_Level__c</field>
        <literalValue>Registered</literalValue>
        <name>Account: Set Partner Level to Reigstered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Partner_Type_to_Reseller</fullName>
        <description>Sets Partner Type to Reseller</description>
        <field>Partner_Type__c</field>
        <literalValue>Reseller</literalValue>
        <name>Account: Set Partner Type to Reseller</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Registered_Discount_NX_VX</fullName>
        <description>Set NXVX Reg Discount to 0.3</description>
        <field>Registered_Discount_Product__c</field>
        <formula>IF(
OR(
ISBLANK(Registered_Discount_Product__c),
Registered_Discount_Product__c = 0
),
0.3,
Registered_Discount_Product__c
)</formula>
        <name>Account: Set Registered Discount NX/VX</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Registered_Discount_Service</fullName>
        <description>Set Registered Discount Service to 0.23</description>
        <field>Registered_Discount_Service__c</field>
        <formula>IF( 
OR( 
ISBLANK(Registered_Discount_Service__c), 
Registered_Discount_Service__c = 0 
), 
0.23, 
Registered_Discount_Service__c 
)</formula>
        <name>Account: Set Registered Discount Service</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Registered_Edge_Connect</fullName>
        <description>Set Registered Edge Connect to 0.22</description>
        <field>Registered_Discount_EdgeConnect__c</field>
        <formula>IF( 
OR( 
ISBLANK(Registered_Discount_EdgeConnect__c), 
Registered_Discount_EdgeConnect__c = 0 
), 
0.22, 
Registered_Discount_EdgeConnect__c 
)</formula>
        <name>Account: Set Registered Edge Connect</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Standard_Discount_Edge_Conn</fullName>
        <description>Set Standard Edge Connect to 0.10</description>
        <field>Standard_Discount_EdgeConnect__c</field>
        <formula>IF( 
OR( 
ISBLANK(Standard_Discount_EdgeConnect__c), 
Standard_Discount_EdgeConnect__c = 0 
), 
0.10, 
Standard_Discount_EdgeConnect__c 
)</formula>
        <name>Account: Set Standard Discount Edge Conn</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Standard_Discount_NX_VX</fullName>
        <field>Standard_Discount_Product__c</field>
        <formula>IF( 
OR( 
ISBLANK(Standard_Discount_Product__c), 
Standard_Discount_Product__c = 0 
), 
0.15, 
Standard_Discount_Product__c 
)</formula>
        <name>Account: Set Standard Discount NX/VX</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Standard_Discount_Service</fullName>
        <description>Set Standard Discount Service to 0.05</description>
        <field>Standard_Discount_Service__c</field>
        <formula>IF( 
OR( 
ISBLANK(Standard_Discount_Service__c), 
Standard_Discount_Service__c = 0 
), 
0.05, 
Standard_Discount_Service__c 
)</formula>
        <name>Account: Set Standard Discount Service</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Type_Partner</fullName>
        <field>Type</field>
        <literalValue>Partner</literalValue>
        <name>Account: Set Type = Partner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_isPartner_c_True</fullName>
        <field>isPartner__c</field>
        <literalValue>1</literalValue>
        <name>Account: Set isPartner__c True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AcctRecType2Other</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Other</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>AcctRecType2Other</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AcctRecTypetoCust</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Customer</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>AcctRecTypetoCust</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeAccountTypeToCustomer</fullName>
        <field>Type</field>
        <literalValue>Customer</literalValue>
        <name>ChangeAccountTypeToCustomer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CheckExpiredCustomerFlag</fullName>
        <field>Expired_Customer__c</field>
        <literalValue>1</literalValue>
        <name>CheckExpiredCustomerFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ClearFirstCustomerQuarter</fullName>
        <field>First_Asset_Quarter__c</field>
        <name>ClearFirstCustomerQuarter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Hardware_Sync_Flag</fullName>
        <field>Sync_with_Cloud_Portal__c</field>
        <literalValue>0</literalValue>
        <name>Clear Hardware Sync Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Virtual_Asset_Flag_for_Metered</fullName>
        <field>Sync_Virtual_Assets_with_CP__c</field>
        <literalValue>0</literalValue>
        <name>Clear Virtual Asset Flag for Metered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetRecTypetoReseller</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Resellers</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SetRecTypetoReseller</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Account_to_ECSP</fullName>
        <field>ECSP__c</field>
        <literalValue>1</literalValue>
        <name>Set Account to ECSP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SyncEmployeeFields</fullName>
        <field>NumberOfEmployees</field>
        <formula>Number_of_Employees__c</formula>
        <name>SyncEmployeeFields</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sync_Virtual_Asset_to_Cloud_Portal</fullName>
        <field>Sync_Virtual_Assets_with_CP__c</field>
        <literalValue>1</literalValue>
        <name>Sync Virtual Asset to Cloud Portal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UnCheckExpiredCustomerFlag</fullName>
        <field>Expired_Customer__c</field>
        <literalValue>0</literalValue>
        <name>UnCheckExpiredCustomerFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>BL__AccountUpdate</fullName>
        <apiVersion>8.0</apiVersion>
        <endpointUrl>https://www.boulderlogic.com/Reference/SfdcNotificationBinding.asmx?blns=BL</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>prane@silver-peak.com</integrationUser>
        <name>AccountUpdate</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Account%3A Partner Account Enabled</fullName>
        <actions>
            <name>Account_Set_isPartner_c_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.IsPartner</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Account%3A Partner Application Created</fullName>
        <actions>
            <name>Account_Partner_Application_Submitted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Resellers</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Partner_Application_Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Account_Partner_Application_Pending</name>
                <type>Alert</type>
            </actions>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Account%3A Partner Application Status %3D Approved</fullName>
        <actions>
            <name>Notify_Partner_Team_on_New_Partner_Creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Partner_Application_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Account%3A Partner Application Status %3D Denied</fullName>
        <actions>
            <name>Account_Send_Partner_Application_Denial_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Partner_Application_Status__c</field>
            <operation>equals</operation>
            <value>Denied</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Account%3A Partner Application Status %3D Pending</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.Partner_Application_Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Account_Partner_Application_Overdue</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Account%3A Partner Application Status %3D Step 1 Approved</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.Partner_Application_Status__c</field>
            <operation>equals</operation>
            <value>Step 1 Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Account_Partner_Application_Overdue</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Account%3A Reseller Agreement Acknowledged True</fullName>
        <actions>
            <name>Account_Set_Partner_Level_to_Reigstered</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Account_Set_Partner_Type_to_Reseller</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Account_Set_Registered_Discount_NX_VX</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Account_Set_Registered_Discount_Service</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Account_Set_Registered_Edge_Connect</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Account_Set_Standard_Discount_Edge_Conn</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Account_Set_Standard_Discount_NX_VX</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Account_Set_Standard_Discount_Service</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Account_Set_Type_Partner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Reseller_Agreement_Acknowledged__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ActivateExpiredAccountField</fullName>
        <actions>
            <name>Send_Email_to_Marketing_when_the_expired_customer_is_checked</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CheckExpiredCustomerFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED(Active_Asset_Count__c), Active_Asset_Count__c==0, PRIORVALUE(Expired_Customer__c)=false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BL__AccountUpdate</fullName>
        <actions>
            <name>BL__AccountUpdate</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(LastModifiedDate) &amp;&amp; BL__SyncWithBoulderLogic__c == true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Clear Cloud Portal Sync Flag for Metered</fullName>
        <actions>
            <name>Clear_Hardware_Sync_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Virtual_Asset_Flag_for_Metered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Account.Service_Provider_Account_Type__c</field>
            <operation>equals</operation>
            <value>EC-SP-Metered,EC-SP-Metered +Orch-SP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Sync_with_Cloud_Portal__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Sync_Virtual_Assets_with_CP__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ClearFirstCustomerQuarter</fullName>
        <actions>
            <name>ClearFirstCustomerQuarter</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.First_Asset_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DeactivateExpiredAccountField</fullName>
        <actions>
            <name>Expired_Flag_is_unchecked</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UnCheckExpiredCustomerFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED(Active_Asset_Count__c),  Active_Asset_Count__c&gt;0, PRIORVALUE(Expired_Customer__c)=true )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Partner Team on New Partner</fullName>
        <actions>
            <name>Notify_Partner_Team_on_New_Partner_Creation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Partner_Portal_Enabled__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send email to partner team users when new partner is enabled for new account.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PopulateRightAccountType</fullName>
        <actions>
            <name>Send_Email_To_Shari</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ChangeAccountTypeToCustomer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED(Active_Asset_Count__c), Active_Asset_Count__c &gt;0, NOT(OR(ISPICKVAL(PRIORVALUE(Type),&quot;Customer&quot;),ISPICKVAL(PRIORVALUE(Type),&quot;Partner&quot;))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set ECSP to True</fullName>
        <actions>
            <name>Set_Account_to_ECSP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to automate the ECSP value when the Parent assigned to the account is set as ECSP.  Intent is to lock the field but allow newly created accounts to get updated properly through workflow, regardless of ECSP field rights of the creator.</description>
        <formula>Parent.ECSP__c = TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SetRecordTypetoCustomer</fullName>
        <actions>
            <name>AcctRecTypetoCust</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>Customer,Prospect</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SetRecordTypetoOther</fullName>
        <actions>
            <name>AcctRecType2Other</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>Competitor</value>
        </criteriaItems>
        <description>Set Record Type to Other</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SetRecordTypetoReseller</fullName>
        <actions>
            <name>SetRecTypetoReseller</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <description>Set Record Type to Reseller</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Sync the account if unity orch attributes change</fullName>
        <actions>
            <name>Sync_Virtual_Asset_to_Cloud_Portal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT( Sync_Virtual_Assets_with_CP__c ), OR( ISCHANGED( Unity_Orch_Admin_User__c ), ISCHANGED(  Unity_Orch_Domain__c ), ISCHANGED( Unity_Orch_Location__c  ), ISCHANGED( Unity_Orch_Version__c ) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SyncEmployeeFields</fullName>
        <actions>
            <name>SyncEmployeeFields</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>if there is a process that feeds Number of Employees, since the value to employees since it is the only field displayed on the page layout</description>
        <formula>AND(ISCHANGED(Number_of_Employees__c),  ISBLANK( NumberOfEmployees ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
