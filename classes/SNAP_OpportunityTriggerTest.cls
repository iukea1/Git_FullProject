@isTest
private class SNAP_OpportunityTriggerTest 
{
	@isTest static void testOppSplitsAutomation() 
    {
        Account newAccount = SNAP_TestDataFactory.createAccount();
        insert newAccount;

        Contact newContact = SNAP_TestDataFactory.createContact(newAccount.Id);
        insert newContact;

        Test.startTest();
        
        Opportunity newOpp = SNAP_TestDataFactory.createOpportunity(newAccount.Id);        
        insert newOpp;

        Opportunity oppToUpdate = new Opportunity(Id = newOpp.Id, Technical_Responsible__c = UserInfo.getUserId());
        update oppToUpdate;

        Test.stopTest();
	}
}