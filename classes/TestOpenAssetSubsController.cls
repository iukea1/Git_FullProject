@IsTest
public class TestOpenAssetSubsController {

    @isTest
    static void testSubscription()
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
   		SBQQ__SubscribedAsset__c subAsset= new SBQQ__SubscribedAsset__c();
        subAsset.SBQQ__Asset__c=asset1.Id;
        subAsset.SBQQ__Subscription__c=sub.Id;
        subAsset.SBQQ__Active__c=true;
        insert subAsset;
        
        Case caseData= new Case(AccountId=acc.Id, AssetId=asset1.Id);
        insert caseData;
        ApexPages.StandardController stdController= new ApexPages.StandardController(caseData);
        OpenAssetSubsController objSubs= new OpenAssetSubsController(stdController);
        System.assert(objSubs.lstSubs.size()>0);
    }
    
     @isTest
    static void testAsset()
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
   		SBQQ__SubscribedAsset__c subAsset= new SBQQ__SubscribedAsset__c();
        subAsset.SBQQ__Asset__c=asset1.Id;
        subAsset.SBQQ__Subscription__c=sub.Id;
        subAsset.SBQQ__Active__c=true;
        insert subAsset;
        
        Case caseData= new Case(AccountId=acc.Id, Subscription__c=sub.Id);
        insert caseData;
        ApexPages.StandardController stdController= new ApexPages.StandardController(caseData);
        OpenAssetSubsController objSubs= new OpenAssetSubsController(stdController);
        System.assert(objSubs.lstAssets.size()>0);
    }
}