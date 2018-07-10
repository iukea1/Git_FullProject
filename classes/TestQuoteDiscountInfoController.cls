@Istest
public class TestQuoteDiscountInfoController {

    @Istest
    public static void test1()
    {
        Account acc = new Account(Name='test');
        insert acc;
        
        Account resellerAcc= new Account(Name='Reseller',Type='Partner',Partner_Type__c='Reseller',Reseller_Agreement__c=true);
        insert resellerAcc;
        
        Account distAccount= new Account(Name='Reseller',Type='Partner',Partner_Type__c='Distributor');
        insert distAccount;
        Opportunity opp= new Opportunity(Name='Testopp',AccountId=acc.Id,StageName='New',CloseDate=Date.today());
        insert opp;
        SBQQ__Quote__c quote= new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Type__c='NX/VX',Reseller_Partner__c=resellerAcc.Id,Distributor_Partner__c=distAccount.Id);
        insert quote;
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(quote);
        QuoteDiscountInfoController obj= new QuoteDiscountInfoController(stdController);
        System.assert(obj.DiscountQuote!=null);
        
    }
}