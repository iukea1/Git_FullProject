@isTest
private class TestAsyncOppSplitsJob
{
    @isTest
    static void testCreateOppSplits()
    {
        Account newAccount = TestDataFactory.createAccount();
        insert newAccount;

        Contact newContact = TestDataFactory.createContact(newAccount.Id);
        insert newContact;

        Opportunity newOpp = TestDataFactory.createOpportunity(newAccount.Id);        
        insert newOpp;

        List<OpportunitySplitType> splitTypes = [select Id from OpportunitySplitType where IsActive = true and DeveloperName != 'Revenue'];

        List<OpportunitySplit> splits = new List<OpportunitySplit>();
        for(OpportunitySplitType splitType : splitTypes)
        {
            splits.add(new OpportunitySplit(
                SplitOwnerId = UserInfo.getUserId(), 
                OpportunityId = newOpp.Id, 
                SplitTypeId = splitType.Id, 
                SplitPercentage = 100
            ));
        }

        Test.startTest();

        System.enqueueJob(new AsyncOppSplitsJob(splits));

        Test.stopTest();

        Integer count = [select count() from OpportunitySplit where OpportunityId = :newOpp.Id and SplitOwnerId = :UserInfo.getUserId()];
        System.assert(count > 0);
    }   
}