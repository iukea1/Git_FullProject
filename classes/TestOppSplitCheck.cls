/**
 * Test class for OppSplitCheckExt.
 *
 * @author: SnapBI
 *
 * @changelog
 * 08/10/2018 Eric He - Created.
 */
@isTest
private class TestOppSplitCheck 
{   
    @isTest static void checkOppSplits() 
    {
        Account newAccount = TestDataFactory.createAccount();
        insert newAccount;

        Contact newContact = TestDataFactory.createContact(newAccount.Id);
        insert newContact;

        Opportunity newOpp = TestDataFactory.createOpportunity(newAccount.Id);        
        insert newOpp;
        Test.startTest();

        List<OpportunitySplit> splits = [select Id, SplitPercentage from OpportunitySplit where OpportunityId = :newOpp.Id and SplitType.IsActive = true and SplitType.IsTotalValidated = false];
        if(!splits.isEmpty())
        {
            for(OpportunitySplit split : splits)
            {
                split.SplitPercentage = 50;
            }
            update splits;
        }

        ApexPages.StandardController stdController = new ApexPages.StandardController(newOpp);

        OppSplitCheckExt ext = new OppSplitCheckExt(stdController);

        System.assertEquals(ext.WarningMsg, '');
        System.assertNotEquals(ext.ErrorMsg, '');
        Test.stopTest();
    }
    
}