@IsTest
public class TestQuoteLineTriggerHandler {
    
    @IsTest
    public static void ReductionQuoteTest_Reduction()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 vxSub= new Product2(Name='VX-1000 Sub ',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxSub;
        Product2 vxProd= new Product2(Name='VX-1000 Sub(Asset)',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxProd;
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=vxProd.Id);
        insert asset1;
        Contract con= new Contract(AccountId=acc.Id);
        insert con;
        
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=2,SBQQ__Product__c=vxSub.Id);
        insert sub;
        
        asset1.SBQQ__CurrentSubscription__c=sub.Id;
        update asset1;
         
        SBQQ__Quote__c quote= new SBQQ__Quote__c(Product_Type__c='EDGECONNECT');
        insert quote;
        
        SBQQ__QuoteLine__c ql= new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=vxSub.Id,SBQQ__Quantity__c=2,SBQQ__RenewedSubscription__c=sub.Id);
        insert ql;
        
        ql.SBQQ__Quantity__c=1;
        update ql;
        SBQQ__QuoteLine__c outputQL=[Select Reduction_QL__c from SBQQ__QuoteLine__c where Id=:ql.Id ];
        System.assert(outputQL.Reduction_QL__c==1);
        
    }
  	
    @IsTest
    public static void ReductionQuoteTest_Reduction_Zero()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 vxSub= new Product2(Name='VX-1000 Sub ',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxSub;
        Product2 vxProd= new Product2(Name='VX-1000 Sub(Asset)',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxProd;
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=vxProd.Id);
        insert asset1;
        Contract con= new Contract(AccountId=acc.Id);
        insert con;
        
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=2,SBQQ__Product__c=vxSub.Id);
        insert sub;
        
        asset1.SBQQ__CurrentSubscription__c=sub.Id;
        update asset1;
         
        SBQQ__Quote__c quote= new SBQQ__Quote__c(Product_Type__c='EDGECONNECT');
        insert quote;
        
        SBQQ__QuoteLine__c ql= new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=vxSub.Id,SBQQ__Quantity__c=2,SBQQ__RenewedSubscription__c=sub.Id);
        insert ql;
        
        ql.SBQQ__Quantity__c=1;
        update ql;
        SBQQ__QuoteLine__c outputQL=[Select Reduction_QL__c from SBQQ__QuoteLine__c where Id=:ql.Id ];
        System.assert(outputQL.Reduction_QL__c==1);
        ql.SBQQ__Quantity__c=2;
        update ql;
        outputQL=[Select Reduction_QL__c from SBQQ__QuoteLine__c where Id=:ql.Id ];
        System.assert(outputQL.Reduction_QL__c==0);
        
    }
}