@IsTest	
public class TestSBQQSubscriptionController {

    
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
        SBQQSubscriptionController obj= new SBQQSubscriptionController();
        obj.ContractId=con.Id;
        System.assert(obj.lstVXSubAssets.size()>0);
        
    }
}