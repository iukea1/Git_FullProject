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
    @testSetup
    static void setup()
    {
        Account newAccount = TestDataFactory.createAccount();
        insert newAccount;

        Contact newContact = TestDataFactory.createContact(newAccount.Id);
        insert newContact;     

        Opportunity newOpp = TestDataFactory.createOpportunity(newAccount.Id);      
        newOpp.Name = 'Opp with Splits';  
        insert newOpp;
    }

    @isTest
    static void testSplitLessAllocated()
    {
        Opportunity newOpp = [select Id from Opportunity where Name = 'Opp with Splits'];
        Test.startTest();

        List<OpportunitySplit> splits = [select Id, SplitPercentage from OpportunitySplit where OpportunityId = :newOpp.Id and SplitType.IsActive = true and SplitType.IsTotalValidated = false];

        for(OpportunitySplit split : splits)
        {
            split.SplitPercentage = 50;
        }
        update splits;

        ApexPages.StandardController stdController = new ApexPages.StandardController(newOpp);

        OppSplitCheckExt ext = new OppSplitCheckExt(stdController);

        System.assertEquals(ext.WarningMsg, '');
        System.assertNotEquals(ext.ErrorMsg, '');
        Test.stopTest();
    }

    @isTest 
    static void testSplitOverAllocated() 
    {  
        Opportunity newOpp = [select Id, Technical_Responsible__c from Opportunity where Name = 'Opp with Splits'];

        Profile adminProfile = [select Id from Profile where Name = 'System Administrator'];

        // create SE users
        List<User> users = new List<User>();
        for(Integer i = 1; i <= 2; i++)
        {
            users.add(new User(
                Alias = 'admin' + i, 
                Email = 'admin' + i + '@testorg.com',
                EmailEncodingKey = 'UTF-8', 
                LastName = 'Testing' + i, 
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', 
                ProfileId = adminProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'admin' + i + DateTime.now().getTime() + '@testorg.com',
                Role_Type__c = 'SE')
            );
        }
        insert users;     

        newOpp.Technical_Responsible__c = users[0].Id;
        update newOpp;         

        // add the second SE user to the split, which makes the total split percentage over-allocated.
        List<OpportunitySplit> newSplits = new List<OpportunitySplit>();
        for(OpportunitySplitType splitType : [select Id from OpportunitySplitType where IsActive = true and IsTotalValidated = false])
        {
            newSplits.add(new OpportunitySplit(OpportunityId = newOpp.Id, SplitTypeId = splitType.Id, SplitOwnerId = users[1].Id, SplitPercentage = 100));
        }
        insert newSplits;

        Test.startTest();        
        ApexPages.StandardController stdController = new ApexPages.StandardController(newOpp);

        OppSplitCheckExt ext = new OppSplitCheckExt(stdController);

        System.assertNotEquals(ext.WarningMsg, '');
        System.assertEquals(ext.ErrorMsg, '');
        Test.stopTest();
    }    
}