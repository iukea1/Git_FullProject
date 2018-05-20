@IsTest	
public class TestSBQQSubscriptionDataController {
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
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=vxProd.Id);
        insert asset1;
        Contract con= new Contract(AccountId=acc.Id);
        insert con;
        
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=vxSub.Id);
        insert sub;
        
        asset1.SBQQ__CurrentSubscription__c=sub.Id;
        update asset1;
        SBQQSubscriptionDataController obj= new SBQQSubscriptionDataController();
        obj.ContractId=con.Id;
        System.assert(obj.lstVXSubAssets.size()>0);
        
    }
    public testmethod static void TestEC_SubAssset()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 ecBase= new Product2(Name='EC-BASE-1Y ',Model__c='EC-BASE-1Y',Family='Virtual Image', PRoduct_Type__c='EDGECONNECT');
        insert ecBase;
        Product2 ecHW= new Product2(Name='EC-XS-1Y',Model__c='EC-XS-1Y',Family='Product', PRoduct_Type__c='EDGECONNECT');
        insert ecHW;
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=ecHW.Id);
        insert asset1;
        SBQQ__Quote__c objQuote= new SBQQ__Quote__c(Product_Type__c='EDGECONNECT',SBQQ__StartDate__c=Date.today());
        insert objQuote;
        Contract con= new Contract(AccountId=acc.Id,SBQQ__Quote__c=objQuote.Id);
        insert con;
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=ecBase.Id);
        insert sub;
        
        asset1.SBQQ__CurrentSubscription__c=sub.Id;
        update asset1;
        SBQQSubscriptionDataController obj= new SBQQSubscriptionDataController();
        obj.ContractId=con.Id;
        System.assert(obj.lstVXSubAssets.size()==0);
        System.assert(obj.lstAssetWrapper.size()>0);
        
    }
}