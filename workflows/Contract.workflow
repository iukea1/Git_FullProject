<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ContractExpiration</fullName>
        <description>Contract Expiration</description>
        <protected>false</protected>
        <recipients>
            <recipient>lquilici@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/ContractExpiration</template>
    </alerts>
    <alerts>
        <fullName>ContractExtended</fullName>
        <ccEmails>notifications@silver-peak.com,renewalsTeam@silver-peak.com</ccEmails>
        <description>Notify Account Manger and Customer when Contract is extended</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reseller_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>POC/ContractRenewed</template>
    </alerts>
    <alerts>
        <fullName>Contract_Expiration_Notice_1_day</fullName>
        <description>Contract Expiration Notice -1 day</description>
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
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Steelbrick_Email_Templates/EC_Contract_Exp_Notice_expired_day_after</template>
    </alerts>
    <alerts>
        <fullName>Contract_Expiration_Notice_30</fullName>
        <description>EC Contract Before 30 Days</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>prane@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Steelbrick_Email_Templates/EC_Contract_Expiration_Notice_30days</template>
    </alerts>
    <alerts>
        <fullName>Contract_Expiration_Notice_in_0_days</fullName>
        <description>Contract Expiration Notice in 0 days</description>
        <protected>false</protected>
        <recipients>
            <recipient>prane@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Steelbrick_Email_Templates/EC_Contract_Expiration_Notice_30days</template>
    </alerts>
    <alerts>
        <fullName>Contract_Expiration_Notice_in_60_days</fullName>
        <description>EC Contract Before 60 Days</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>prane@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Steelbrick_Email_Templates/EC_Contract_Expiration_Notice_60days</template>
    </alerts>
    <alerts>
        <fullName>Contract_Expiration_Notice_in_90_days</fullName>
        <description>EC Contract Before 90 days</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>prane@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Steelbrick_Email_Templates/EC_Contract_Expiration_Notice_90days</template>
    </alerts>
    <alerts>
        <fullName>EC_Contract_Expiration_Notice_after_30_days</fullName>
        <description>EC Contract 30 Days After</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>prane@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Steelbrick_Email_Templates/EC_Contract_Expirat_Notice_30days_after</template>
    </alerts>
    <alerts>
        <fullName>Eval_Contract_5_Days_before_expire</fullName>
        <description>Eval Contract -5 Days before expire</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>POC_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Steelbrick_Email_Templates/Eval_Contract_5_Days_Before_expiration</template>
    </alerts>
    <alerts>
        <fullName>Eval_Contract_On_Day</fullName>
        <description>Eval Contract On Day</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>POC_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Steelbrick_Email_Templates/Eval_Contract_expired_today</template>
    </alerts>
    <alerts>
        <fullName>Non_EC_Renewal_Email_Template</fullName>
        <ccEmails>notifications@silver-peak.com,renewalsTeam@silver-peak.com</ccEmails>
        <description>Non EC Renewal Email Template</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reseller_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Steelbrick_Email_Templates/NonECRenewal</template>
    </alerts>
    <alerts>
        <fullName>Send_Contract_expiration_a_day_after</fullName>
        <description>EC Contract 1 Day After</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Steelbrick_Email_Templates/EC_Contract_Exp_Notice_expired_day_after</template>
    </alerts>
    <alerts>
        <fullName>Unity_Cloud_Orch_1_Day_After</fullName>
        <description>Unity Cloud Orch 1 Day After</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Steelbrick_Email_Templates/Cloud_Orch_Contract_Expiration_day_after</template>
    </alerts>
    <alerts>
        <fullName>Unity_Cloud_Orch_30_Days_Before</fullName>
        <description>Unity Cloud Orch 30 Days Before</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Steelbrick_Email_Templates/Cloud_Orch_Contract_Expiration_30_days</template>
    </alerts>
    <alerts>
        <fullName>Unity_Cloud_Orch_60_Days_Before</fullName>
        <description>Unity Cloud Orch 60 Days Before</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Steelbrick_Email_Templates/Cloud_Orch_Contract_Expiration_60_days</template>
    </alerts>
    <alerts>
        <fullName>Unity_Cloud_Orch_90_Days_Before</fullName>
        <description>Unity Cloud Orch 90 Days Before</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Steelbrick_Email_Templates/Cloud_Orch_Contract_Expiration_90_days</template>
    </alerts>
    <alerts>
        <fullName>VX_Sub_30_Days_After</fullName>
        <description>VX Sub 30 Days After</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Steelbrick_Email_Templates/VX_Contract_Expirat_Notice_30days_after</template>
    </alerts>
    <alerts>
        <fullName>VX_Sub_30_Days_Before</fullName>
        <description>VX Sub 30 Days Before</description>
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
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Steelbrick_Email_Templates/VX_Contract_Expiration_Notice_30days</template>
    </alerts>
    <alerts>
        <fullName>VX_Sub_60_Days_Before</fullName>
        <description>VX Sub 60 Days Before</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Steelbrick_Email_Templates/VX_Contract_Expiration_Notice_60days</template>
    </alerts>
    <alerts>
        <fullName>VX_Sub_Day_After</fullName>
        <description>VX Sub Day After</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Steelbrick_Email_Templates/VX_Contract_Expirat_Notice_1day_after</template>
    </alerts>
    <alerts>
        <fullName>Vx_Sub_90_Days_Before</fullName>
        <description>Vx Sub 90 Days Before</description>
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
            <recipient>Renewal Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Steelbrick_Email_Templates/VX_Contract_Expiration_Notice_90days</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_the_status_to_Expired</fullName>
        <field>Status</field>
        <literalValue>Expired</literalValue>
        <name>Change the status to Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Set_EC_Total_Contract_Value</fullName>
        <field>SD_WAN_Optimization_Value__c</field>
        <formula>SBQQ__Quote__r.License_Value__c</formula>
        <name>Contract: Set EC Total Contract Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Set_Master_Contract_True</fullName>
        <field>SBQQ__MasterContract__c</field>
        <literalValue>1</literalValue>
        <name>Contract: Set Master Contract = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Set_Status_to_Activated</fullName>
        <field>Status</field>
        <literalValue>Activated</literalValue>
        <name>Contract: Set Status to Activated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SBCF_Set_Renewal_Forecast</fullName>
        <field>SBQQ__RenewalForecast__c</field>
        <literalValue>1</literalValue>
        <name>SBCF Set Renewal Forecast</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SBCF_Set_Renewal_Term</fullName>
        <field>SBQQ__RenewalTerm__c</field>
        <formula>12</formula>
        <name>SBCF Set Renewal Term</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SBCF_Set_Status_to_Activated</fullName>
        <field>Status</field>
        <literalValue>Activated</literalValue>
        <name>SBCF Set Status to Activated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>contract_expiry</fullName>
        <field>Status</field>
        <literalValue>Expired</literalValue>
        <name>contract_expiry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Automated New or Renewed Contract notifications</fullName>
        <actions>
            <name>ContractExtended</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND( NOT(ISPICKVAL(Contract_Type__c,&quot;Evaluation&quot;)), OR( ISCHANGED( EndDate ) &amp;&amp;  ISPICKVAL( Status , &quot;Activated&quot;), ISPICKVAL( Status , &quot;Activated&quot;) &amp;&amp; ISPICKVAL( Priorvalue(Status) , &quot;Draft&quot;), ISPICKVAL( Status , &quot;Activated&quot;) &amp;&amp; ISPICKVAL( Priorvalue(Status) , &quot;Expired&quot;) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contract%3A Edited</fullName>
        <actions>
            <name>Contract_Set_EC_Total_Contract_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Set&apos;s actions to occur when contracts are edited.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EdgeConnect After Expiration</fullName>
        <actions>
            <name>Change_the_status_to_Expired</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.Product_Type__c</field>
            <operation>equals</operation>
            <value>EDGECONNECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Evaluation_Quote__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.EndDate</field>
            <operation>lessThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EC_Contract_Expiration_Notice_after_30_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Contract_expiration_a_day_after</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>EdgeConnect Upcoming Expiration</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Contract.Product_Type__c</field>
            <operation>equals</operation>
            <value>EDGECONNECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Evaluation_Quote__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Contract_Expiration_Notice_30</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Contract_Expiration_Notice_in_60_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Contract_Expiration_Notice_in_90_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Eval Contract Expiration</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Contract.Evaluation_Quote__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Eval_Contract_On_Day</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Change_the_status_to_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Eval_Contract_5_Days_before_expire</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Non EC Renewal Contract</fullName>
        <active>true</active>
        <formula>AND(
NOT( Product_Type__c==&quot;EDGECONNECT&quot;),
NOT(ISNULL(SBQQ__Order__c)),
 ISPICKVAL(SBQQ__Order__r.Type,&quot;Renewal&quot;),
 ISPICKVAL(Status,&quot;Activated&quot;),
 NOT(Evaluation_Quote__c )
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Non_EC_Renewal_Email_Template</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.ActivatedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SBCF Set Contract Fields</fullName>
        <actions>
            <name>SBCF_Set_Renewal_Term</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>SBQQ__Opportunity__r.POC_Opportunity__c = FALSE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SBCF_Set_Renewal_Forecast</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.CreatedDate</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SBCF Set Status to Activated</fullName>
        <actions>
            <name>SBCF_Set_Status_to_Activated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.Status</field>
            <operation>equals</operation>
            <value>Draft</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Trigger Virtual Sub Sync</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Contract.StartDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Contract.StartDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Unity Cloud Orchestrator After Expiration</fullName>
        <actions>
            <name>Change_the_status_to_Expired</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.Unity_Cloud_Orchestrator_Count__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Evaluation_Quote__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.EndDate</field>
            <operation>lessThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Unity_Cloud_Orch_1_Day_After</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Unity Cloud Orchestrator Upcoming Expiration</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Contract.Unity_Cloud_Orchestrator_Count__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Evaluation_Quote__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Unity_Cloud_Orch_60_Days_Before</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Unity_Cloud_Orch_30_Days_Before</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Unity_Cloud_Orch_90_Days_Before</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>VX Subscription After Expiration</fullName>
        <actions>
            <name>Change_the_status_to_Expired</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.Product_Type__c</field>
            <operation>equals</operation>
            <value>NX/VX</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Evaluation_Quote__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Virtual_Subscription_Count__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.EndDate</field>
            <operation>lessThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>VX_Sub_Day_After</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>VX_Sub_30_Days_After</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>VX Subscription Upcoming Expiration</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Contract.Product_Type__c</field>
            <operation>equals</operation>
            <value>NX/VX</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Evaluation_Quote__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Virtual_Subscription_Count__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Vx_Sub_90_Days_Before</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>VX_Sub_60_Days_Before</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>VX_Sub_30_Days_Before</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
