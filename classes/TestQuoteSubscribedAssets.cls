@IsTest
public class TestQuoteSubscribedAssets {
    @IsTest
    public static void Test1()
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
        Asset asset2= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=vxProd.Id);
        insert asset2;
        Contract con= new Contract(AccountId=acc.Id);
        insert con;
        
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=vxSub.Id);
        insert sub;
        
        asset1.SBQQ__CurrentSubscription__c=sub.Id;
        update asset1;
        asset2.SBQQ__CurrentSubscription__c=sub.Id;
        update asset2;
		SBQQ__SubscribedAsset__c obj1= new SBQQ__SubscribedAsset__c(SBQQ__Subscription__c=sub.Id,SBQQ__Asset__c=asset1.Id,SBQQ__Active__c=true);
        insert obj1;
        SBQQ__SubscribedAsset__c obj2= new SBQQ__SubscribedAsset__c(SBQQ__Subscription__c=sub.Id,SBQQ__Asset__c=asset2.Id,SBQQ__Active__c=true);
        insert obj2;
        Test.startTest();
        Opportunity opp= new Opportunity(Name='TEst opp', CloseDate=Date.today(),StageName='New',AccountId=acc.Id,SBQQ__RenewedContract__c=con.Id);
        insert opp;
        SBQQ__quote__c quote= new SBQQ__quote__c(SBQQ__Opportunity2__c=opp.Id);
        insert quote;
        
        ApexPages.StandardController stdCon= new ApexPages.StandardController(quote);
        QuoteSubscribedAssetsExtension ext= new QuoteSubscribedAssetsExtension(stdCon);
        PageReference pageRef= new PageReference('apex/QuoteSubscribedAssets');
        Test.setCurrentPageReference(pageRef);
        System.assert(ext.lstAssets.size()>0);
        ext.lstAssets[0].IsChecked=true;
        ext.lstAssets[1].IsChecked=false;
        ext.save();
        SBQQ__quote__c quoteResult=[Select Serial_Number_Notes__c from SBQQ__Quote__c where Id=:quote.Id];
        System.debug(quoteResult.Serial_Number_Notes__c!=null);
        
        Test.stopTest();
       
    }
    @IsTest
    public static void Test_Validation()
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
        Asset asset2= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=vxProd.Id);
        insert asset2;
        Contract con= new Contract(AccountId=acc.Id);
        insert con;
        
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=vxSub.Id);
        insert sub;
        
        asset1.SBQQ__CurrentSubscription__c=sub.Id;
        update asset1;
        asset2.SBQQ__CurrentSubscription__c=sub.Id;
        update asset2;
		SBQQ__SubscribedAsset__c obj1= new SBQQ__SubscribedAsset__c(SBQQ__Subscription__c=sub.Id,SBQQ__Asset__c=asset1.Id,SBQQ__Active__c=true);
        insert obj1;
        SBQQ__SubscribedAsset__c obj2= new SBQQ__SubscribedAsset__c(SBQQ__Subscription__c=sub.Id,SBQQ__Asset__c=asset2.Id,SBQQ__Active__c=true);
        insert obj2;
        Test.startTest();
        Opportunity opp= new Opportunity(Name='TEst opp', CloseDate=Date.today(),StageName='New',AccountId=acc.Id,SBQQ__RenewedContract__c=con.Id);
        insert opp;
        SBQQ__quote__c quote= new SBQQ__quote__c(SBQQ__Opportunity2__c=opp.Id);
        insert quote;
        
        ApexPages.StandardController stdCon= new ApexPages.StandardController(quote);
        QuoteSubscribedAssetsExtension ext= new QuoteSubscribedAssetsExtension(stdCon);
        PageReference pageRef= new PageReference('apex/QuoteSubscribedAssets');
        Test.setCurrentPageReference(pageRef);
        System.assert(ext.lstAssets.size()>0);
        ext.lstAssets[0].IsChecked=false;
        ext.lstAssets[1].IsChecked=false;
        ext.save();
        SBQQ__quote__c quoteResult=[Select Serial_Number_Notes__c from SBQQ__Quote__c where Id=:quote.Id];
        System.debug(quoteResult.Serial_Number_Notes__c==null);
        
        Test.stopTest();
       
    }
 	@IsTest
    public static void Test_AllSelected()
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
        Asset asset2= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=vxProd.Id);
        insert asset2;
        Contract con= new Contract(AccountId=acc.Id);
        insert con;
        
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=vxSub.Id);
        insert sub;
        
        asset1.SBQQ__CurrentSubscription__c=sub.Id;
        update asset1;
        asset2.SBQQ__CurrentSubscription__c=sub.Id;
        update asset2;
		SBQQ__SubscribedAsset__c obj1= new SBQQ__SubscribedAsset__c(SBQQ__Subscription__c=sub.Id,SBQQ__Asset__c=asset1.Id,SBQQ__Active__c=true);
        insert obj1;
        SBQQ__SubscribedAsset__c obj2= new SBQQ__SubscribedAsset__c(SBQQ__Subscription__c=sub.Id,SBQQ__Asset__c=asset2.Id,SBQQ__Active__c=true);
        insert obj2;
        Test.startTest();
        Opportunity opp= new Opportunity(Name='TEst opp', CloseDate=Date.today(),StageName='New',AccountId=acc.Id,SBQQ__RenewedContract__c=con.Id);
        insert opp;
        SBQQ__quote__c quote= new SBQQ__quote__c(SBQQ__Opportunity2__c=opp.Id);
        insert quote;
        
        ApexPages.StandardController stdCon= new ApexPages.StandardController(quote);
        QuoteSubscribedAssetsExtension ext= new QuoteSubscribedAssetsExtension(stdCon);
        PageReference pageRef= new PageReference('apex/QuoteSubscribedAssets');
        Test.setCurrentPageReference(pageRef);
        System.assert(ext.lstAssets.size()>0);
        ext.lstAssets[0].IsChecked=true;
        ext.lstAssets[1].IsChecked=true;
        ext.save();
        SBQQ__quote__c quoteResult=[Select Serial_Number_Notes__c from SBQQ__Quote__c where Id=:quote.Id];
        System.debug(quoteResult.Serial_Number_Notes__c==null);
        
        Test.stopTest();
       
    }
}