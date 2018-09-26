@isTest
private class TestOpportunitySplitTrigger 
{	
	@isTest static void createSplitLogTest()
    {
        Account newAccount = TestDataFactory.createAccount();
        insert newAccount;

        Contact newContact = TestDataFactory.createContact(newAccount.Id);
        insert newContact;     

        Test.startTest();

        Opportunity newOpp = TestDataFactory.createOpportunity(newAccount.Id);    
        // Opportunity owner is auto-added to the Opportunity Split and Opportunity Split logs are created in the trigger.
        insert newOpp;        

        List<OpportunitySplit> splits = [select Id, SplitPercentage from OpportunitySplit where OpportunityId = :newOpp.Id and SplitType.IsActive = true and SplitType.DeveloperName != 'Revenue'];

        Integer logsForInsert = [select count() from OpportunitySplitLog__c where Event__c = 'Insert'];
        System.assert(logsForInsert > 0);

        // Update Opportunity Splits
        for(OpportunitySplit split : splits)
        {
            split.SplitPercentage = 50;
        }
        update splits;
        Integer logsForUpdate = [select count() from OpportunitySplitLog__c where Event__c = 'Update'];
        System.assert(logsForUpdate > 0);

        // Delete Opportunity Splits
        delete splits;
        Integer logsForDelete = [select count() from OpportunitySplitLog__c where Event__c = 'Delete'];
        System.assert(logsForDelete > 0);

        Test.stopTest();
	}	
}