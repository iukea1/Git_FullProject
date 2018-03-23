@IsTest
public class AssociateToQuoteLineAddConTest {

    @IsTest
    public static void TestAssociateToQL()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Product2 prod= new Product2(Name='EC-XS-1Y', Family='Product',Product_Type__c='EDGECONNECT');
        insert prod;
        Opportunity opp= new Opportunity(AccountId=acc.id, Name='test Opp',StageName='Discovery',CloseDate=Date.today().addDays(30),POC_Opportunity__c=true);
        insert opp;
        SBQQ__Quote__c quote= new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__StartDate__c=Date.today());
        insert quote;
        SBQQ__QuoteLine__c ql= new SBQQ__QuoteLine__c(SBQQ__Product__c=prod.Id,SBQQ__Quote__c=quote.Id,SBQQ__Quantity__c=2);
        insert ql;
        Quote_Address__c quoteAdd= new Quote_Address__c(Quote__c=quote.Id,Name='Test Data');
        insert quoteAdd;
        ApexPages.StandardController stdCon= new ApexPages.StandardController(quoteAdd);
        AssociateToQuoteLineAddressController con= new AssociateToQuoteLineAddressController(stdCon);
        System.debug(con.lstQLA.size()>0);
        
        
    }
    
     @IsTest
    public static void TestAssociateToQL_Save()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Product2 prod= new Product2(Name='EC-XS-1Y', Family='Product',Product_Type__c='EDGECONNECT');
        insert prod;
        Opportunity opp= new Opportunity(AccountId=acc.id, Name='test Opp',StageName='Discovery',CloseDate=Date.today().addDays(30),POC_Opportunity__c=true);
        insert opp;
        SBQQ__Quote__c quote= new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__StartDate__c=Date.today());
        insert quote;
        SBQQ__QuoteLine__c ql= new SBQQ__QuoteLine__c(SBQQ__Product__c=prod.Id,SBQQ__Quote__c=quote.Id,SBQQ__Quantity__c=2);
        insert ql;
        Quote_Address__c quoteAdd= new Quote_Address__c(Quote__c=quote.Id,Name='Test Data');
        insert quoteAdd;
        ApexPages.StandardController stdCon= new ApexPages.StandardController(quoteAdd);
        AssociateToQuoteLineAddressController con= new AssociateToQuoteLineAddressController(stdCon);
        System.debug(con.lstQLA.size()>0);
        for(AssociateToQuoteLineAddressController.QLAWrapper obj:con.lstQLA)
        {
            obj.ShippingQuantity=5;
        }
        con.SaveData();
    }
    
      @IsTest
    public static void TestAssociateToQL_Update()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Product2 prod= new Product2(Name='EC-XS-1Y', Family='Product',Product_Type__c='EDGECONNECT');
        insert prod;
        Opportunity opp= new Opportunity(AccountId=acc.id, Name='test Opp',StageName='Discovery',CloseDate=Date.today().addDays(30),POC_Opportunity__c=true);
        insert opp;
        SBQQ__Quote__c quote= new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__StartDate__c=Date.today());
        insert quote;
        SBQQ__QuoteLine__c ql= new SBQQ__QuoteLine__c(SBQQ__Product__c=prod.Id,SBQQ__Quote__c=quote.Id,SBQQ__Quantity__c=2);
        insert ql;
        Quote_Address__c quoteAdd= new Quote_Address__c(Quote__c=quote.Id,Name='Test Data');
        insert quoteAdd;
        ApexPages.StandardController stdCon= new ApexPages.StandardController(quoteAdd);
        AssociateToQuoteLineAddressController con= new AssociateToQuoteLineAddressController(stdCon);
        System.debug(con.lstQLA.size()>0);
        for(AssociateToQuoteLineAddressController.QLAWrapper obj:con.lstQLA)
        {
            obj.ShippingQuantity=5;
        }
        con.SaveData();
        con= new AssociateToQuoteLineAddressController(stdCon);
        for(AssociateToQuoteLineAddressController.QLAWrapper obj:con.lstQLA)
        {
            obj.ShippingQuantity=5;
        }
        con.SaveData();
    }
    
     @IsTest
    public static void TestAssociateToQL_Exception()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Product2 prod= new Product2(Name='EC-XS-1Y', Family='Product',Product_Type__c='EDGECONNECT');
        insert prod;
        Opportunity opp= new Opportunity(AccountId=acc.id, Name='test Opp',StageName='Discovery',CloseDate=Date.today().addDays(30),POC_Opportunity__c=true);
        insert opp;
        SBQQ__Quote__c quote= new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__StartDate__c=Date.today());
        insert quote;
        SBQQ__QuoteLine__c ql= new SBQQ__QuoteLine__c(SBQQ__Product__c=prod.Id,SBQQ__Quote__c=quote.Id,SBQQ__Quantity__c=2);
        insert ql;
        Quote_Address__c quoteAdd= new Quote_Address__c(Quote__c=quote.Id,Name='Test Data');
        insert quoteAdd;
        ApexPages.StandardController stdCon= new ApexPages.StandardController(quoteAdd);
        AssociateToQuoteLineAddressController con= new AssociateToQuoteLineAddressController(stdCon);
        System.debug(con.lstQLA.size()>0);
        for(AssociateToQuoteLineAddressController.QLAWrapper obj:con.lstQLA)
        {
            obj.ShippingQuantity=5;
        }
        con.SaveData();
        con= new AssociateToQuoteLineAddressController(stdCon);
        for(AssociateToQuoteLineAddressController.QLAWrapper obj:con.lstQLA)
        {
            obj.ShippingQuantity=5;
            obj.QLData=null;
        }
        con.SaveData();
    }
}