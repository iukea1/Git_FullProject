@isTest
public  class SNAP_TestDataFactory 
{
    public static Account createAccount()
    {
        Account newAccount = new Account(Name = 'Acme');
        return newAccount;
    }

    public static Contact createContact(Id accountId)
    {
        Contact newContact = new Contact(
            AccountId = accountId,
            FirstName = 'FN',
            LastName = 'LN',
            Email = 'name@acme.com'
        );
        return newContact;
    }

    public static Opportunity createOpportunity(Id accountId)
    {
        Opportunity newOpp = new Opportunity(
            Name = 'Acme Opp',
            AccountId = accountId,
            CloseDate = Date.today().addMonths(1),
            StageName = 'New'
        );
        return newOpp;
    }
}