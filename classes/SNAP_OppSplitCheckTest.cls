/**
 * Test class for SNAP_OppSplitCheckExt.
 *
 * @author: SnapBI
 *
 * @changelog
 * 08/10/2018 Eric He - Created.
 */
@isTest
private class SNAP_OppSplitCheckTest 
{	
	@isTest static void checkOppSplits() 
    {
        Account newAccount = SNAP_TestDataFactory.createAccount();
        insert newAccount;

        Contact newContact = SNAP_TestDataFactory.createContact(newAccount.Id);
        insert newContact;

        Opportunity newOpp = SNAP_TestDataFactory.createOpportunity(newAccount.Id);        
        insert newOpp;
        Test.startTest();

        List<OpportunitySplit> splits = [select Id, SplitPercentage from OpportunitySplit where OpportunityId = :newOpp.Id and SplitType.IsActive = true];
        if(!splits.isEmpty())
        {
            for(OpportunitySplit split : splits)
            {
                split.SplitPercentage = 50;
            }
            update splits;
        }

        ApexPages.StandardController stdController = new ApexPages.StandardController(newOpp);

        SNAP_OppSplitCheckExt ext = new SNAP_OppSplitCheckExt(stdController);

        System.assertEquals(ext.WarningMsg, '');
        System.assertNotEquals(ext.ErrorMsg, '');
        Test.stopTest();
	}
}