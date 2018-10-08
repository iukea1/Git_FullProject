@Istest
public class TestEvalQuoteProductController {
 
    public testmethod static void TestVXSubAssset()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 vxSub= new Product2(Name='VX-1000 Sub ',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxSub;
        Product2 vxProd= new Product2(Name='VX-1000 Sub(Asset)',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxProd;
        SBQQ__Quote__c objQuote= new SBQQ__Quote__c(Product_Type__c='NX/VX',SBQQ__StartDate__c=Date.today());
        insert objQuote;
        
        SBQQ__QuoteLine__c ql1= new SBQQ__QuoteLine__c(SBQQ__Product__c=vxSub.Id,SBQQ__Quote__c=objQuote.Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false);
        insert ql1;
        SBQQ__QuoteLine__c ql2= new SBQQ__QuoteLine__c(SBQQ__Product__c=vxProd.Id,SBQQ__Quote__c=objQuote.Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=true);
        insert ql2;
        
      
        
        
        Product2 nx1700= new Product2(Name='NX-700',Model__c='NX-700',Family='Product', PRoduct_Type__c='NX/VX');
        insert nx1700;
        SBQQ__QuoteLine__c ql3= new SBQQ__QuoteLine__c(SBQQ__Product__c=nx1700.Id,SBQQ__Quote__c=objQuote.Id,SBQQ__Quantity__c=1);
        insert ql3;
        Quote_Address__c addr= new Quote_Address__c(Quote__c=objQuote.Id);
        insert addr;
        Quote_Line_Address__c addrLine= new Quote_Line_Address__c(Quote__c=objQuote.Id,Quote_Address__c=addr.Id,Quote_Line__c=ql3.Id,Shipping_Quantity__c=1);
        insert addrLine;
        
        EvalQuoteProductController obj= new EvalQuoteProductController();
        obj.QuoteId=objQuote.Id;
        System.assert(obj.SWProd.size()>0);
        System.assert(obj.HWProd.size()>0);
        
    }
     public testmethod static void TestVXSubAssset_Blank()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
     
        
        EvalQuoteProductController obj= new EvalQuoteProductController();
        obj.QuoteId=null;
        System.assert(obj.SWProd.size()==0);
        System.assert(obj.HWProd.size()==0);
        
    }
}