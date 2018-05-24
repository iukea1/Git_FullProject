@IsTest
public class TestCloudPortalPostAssetsJob {
    @IsTest
    public static void TestBatchAssets_ExistingAccount_EC()
    {
        Account acc= new Account(Name='acme',Cloud_Portal_Account_Id__c='123666669898');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spacc;
        SBQQ__Quote__c objQuote= new SBQQ__Quote__c(Product_Type__c='EDGECONNECT',SBQQ__StartDate__c=Date.today());
        insert objQuote;
        Contract objContract= new Contract();
        objContract.AccountId=acc.Id;
        objContract.SBQQ__Quote__c=objQuote.Id;
        objContract.EndDate=Date.today().addYears(1);
        insert objContract;
        objContract.Status='Activated';
        update objContract;
        Product2 baseProduct = new Product2();
        baseProduct.Name = 'EC-BASE-1Y';
        baseProduct.ProductCode = 'EC-BASE';
        baseProduct.Model__c = 'EC-BASE';
        baseProduct.Family='Virtual Image';
        baseProduct.Product_Type__c='EDGECONNECT';
        insert baseProduct;
        
        Product2 boostProduct = new Product2();
        boostProduct.Name = 'EC-BOOST-1Y';
        boostProduct.ProductCode = 'EC-BOOST';
        boostProduct.Model__c = 'EC-BOOST';
        boostProduct.Family='Virtual Image';
        boostProduct.Product_Type__c='EDGECONNECT';
        insert boostProduct;
        
        Product2 plusProduct = new Product2();
        plusProduct.Name = 'EC-PLUS-1Y';
        plusProduct.ProductCode = 'EC-PLUS';
        plusProduct.Model__c = 'EC-PLUS';
        plusProduct.Family='Virtual Image';
        plusProduct.Product_Type__c='EDGECONNECT';
        insert plusProduct;
        
        Product2 saasProduct = new Product2();
        saasProduct.Name = 'EC-SAAS-1Y';
        saasProduct.ProductCode = 'EC-SAAS';
        saasProduct.Model__c = 'EC-SAAS';
        saasProduct.Family='Virtual Image';
  		saasProduct.Product_Type__c='EDGECONNECT';
        insert saasProduct;
        
        Product2 ecOrchAAS = new Product2();
        ecOrchAAS.Name = 'EC-ORCH-AAS-1Y';
        ecOrchAAS.ProductCode = 'EC-ORCH-AAS-1Y';
        ecOrchAAS.Model__c = 'EC-ORCH-AAS-1Y';
        ecOrchAAS.Family='Virtual Image';
        ecOrchAAS.Product_Type__c='EDGECONNECT';
        insert ecOrchAAS;
        
        Product2 ecPerpetual = new Product2();
        ecPerpetual.Name = 'EC-SP-50-B';
        ecPerpetual.ProductCode = 'EC-SP-50-B';
        ecPerpetual.Model__c = 'EC-SP-50-B';
        ecPerpetual.Family='Virtual Image';
        ecPerpetual.Product_Type__c='EC-SP-Perpetual';
        insert ecPerpetual;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId=acc.Id;
        asset.Status='Customer Owned';
        asset.Product2Id=ecPerpetual.Id;
        asset.Quantity = 1;
        asset.Sync_With_Cloud_Portal__c=true;
        asset.Cloud_Portal_Sync_Status__c='Pending';
        insert asset;
        License__c objLicense= new License__c();
        objLicense.AssetId__c=asset.Id;
        objLicense.License_Expiration__c=null;
        insert objLicense;
        
        
        SBQQ__Subscription__c subOrch= new SBQQ__Subscription__c();
        subOrch.SerialNumber__c = '001BBC039649_t';
        subOrch.SBQQ__Account__c = acc.Id;
        subOrch.SBQQ__Product__c = ecOrchAAS.Id;
        subOrch.SBQQ__Quantity__c = 1;
        subOrch.SBQQ__Contract__c=objContract.Id;
        insert subOrch;
        
        SBQQ__Subscription__c baseSub= new SBQQ__Subscription__c();
        baseSub.SerialNumber__c = '001BBC039649_t';
        baseSub.SBQQ__Account__c = acc.Id;
        baseSub.SBQQ__Product__c = baseProduct.Id;
        baseSub.SBQQ__Quantity__c = 1;
        baseSub.SBQQ__Contract__c=objContract.Id;
        insert baseSub;
        
         SBQQ__Subscription__c saasSub= new SBQQ__Subscription__c();
        saasSub.SerialNumber__c = '001BBC039649_t';
        saasSub.SBQQ__Account__c = acc.Id;
        saasSub.SBQQ__Product__c = saasProduct.Id;
        saasSub.SBQQ__Quantity__c = 1;
        saasSub.SBQQ__Contract__c=objContract.Id;
        insert saasSub;
        
         SBQQ__Subscription__c plusSub= new SBQQ__Subscription__c();
        plusSub.SerialNumber__c = '001BBC039649_t';
        plusSub.SBQQ__Account__c = acc.Id;
        plusSub.SBQQ__Product__c = plusProduct.Id;
        plusSub.SBQQ__Quantity__c = 1;
        plusSub.SBQQ__Contract__c=objContract.Id;
        insert plusSub;
        
        
        SBQQ__Subscription__c sub1= new SBQQ__Subscription__c();
        sub1.SerialNumber__c = '001BBC039649_t';
        sub1.SBQQ__Account__c = acc.Id;
        sub1.SBQQ__Product__c = boostProduct.Id;
        sub1.SBQQ__Quantity__c = 10;
        sub1.SBQQ__Contract__c=objContract.Id;
        insert sub1;
        SBQQ__Subscription__c sub2= new SBQQ__Subscription__c();
        sub2.SerialNumber__c = '001BBC039649_t';
        sub2.SBQQ__Account__c = acc.Id;
        sub2.SBQQ__Product__c = plusProduct.Id;
        sub2.SBQQ__Quantity__c = 10;
        sub2.SBQQ__Contract__c=objContract.Id;
        insert sub2;
        acc.Sync_Virtual_Assets_with_CP__c=true;
        update acc;
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        CloudPortalPostAssetsJob obj= new CloudPortalPostAssetsJob();
        Database.executeBatch(obj);
        
        Test.stopTest();
    }
    @IsTest
    public static void TestBatchAssets_CreateAccount()
    {
        Account acc= new Account(Name='acme_test');
        insert acc;
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        CloudPortalAccountHelper.CreateAccount(acc.Id, acc.Name);
        Test.stopTest();
    }
    
     @IsTest
    public static void TestBatchAssets_GetAccount()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spacc;
        SBQQ__Quote__c objQuote= new SBQQ__Quote__c(Product_Type__c='EDGECONNECT',SBQQ__StartDate__c=Date.today());
        insert objQuote;
        Contract objContract= new Contract();
        objContract.AccountId=acc.Id;
        objContract.SBQQ__Quote__c=objQuote.Id;
        objContract.EndDate=Date.today().addYears(1);
        insert objContract;
        objContract.Status='Activated';
        update objContract;
        Product2 baseProduct = new Product2();
        baseProduct.Name = 'EC-BASE-1Y';
        baseProduct.ProductCode = 'EC-BASE';
        baseProduct.Model__c = 'EC-BASE';
        baseProduct.Family='Virtual Image';
        baseProduct.Product_Type__c='EDGECONNECT';
        insert baseProduct;
        
        Product2 boostProduct = new Product2();
        boostProduct.Name = 'EC-BOOST-1Y';
        boostProduct.ProductCode = 'EC-BOOST';
        boostProduct.Model__c = 'EC-BOOST';
        boostProduct.Family='Virtual Image';
        boostProduct.Product_Type__c='EDGECONNECT';
        insert boostProduct;
        
        Product2 plusProduct = new Product2();
        plusProduct.Name = 'EC-PLUS-1Y';
        plusProduct.ProductCode = 'EC-PLUS';
        plusProduct.Model__c = 'EC-PLUS';
        plusProduct.Family='Virtual Image';
        plusProduct.Product_Type__c='EDGECONNECT';
        insert plusProduct;
        
        Product2 saasProduct = new Product2();
        saasProduct.Name = 'EC-SAAS-1Y';
        saasProduct.ProductCode = 'EC-SAAS';
        saasProduct.Model__c = 'EC-SAAS';
        saasProduct.Family='Virtual Image';
  		saasProduct.Product_Type__c='EDGECONNECT';
        insert saasProduct;
        
        Product2 ecOrchAAS = new Product2();
        ecOrchAAS.Name = 'EC-ORCH-AAS-1Y';
        ecOrchAAS.ProductCode = 'EC-ORCH-AAS-1Y';
        ecOrchAAS.Model__c = 'EC-ORCH-AAS-1Y';
        ecOrchAAS.Family='Virtual Image';
        ecOrchAAS.Product_Type__c='EDGECONNECT';
        insert ecOrchAAS;
        
        Product2 ecPerpetual = new Product2();
        ecPerpetual.Name = 'EC-SP-50-B';
        ecPerpetual.ProductCode = 'EC-SP-50-B';
        ecPerpetual.Model__c = 'EC-SP-50-B';
        ecPerpetual.Family='Virtual Image';
        ecPerpetual.Product_Type__c='EC-SP-Perpetual';
        insert ecPerpetual;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId=acc.Id;
        asset.Status='Customer Owned';
        asset.Product2Id=ecPerpetual.Id;
        asset.Quantity = 1;
        asset.Sync_With_Cloud_Portal__c=true;
        asset.Cloud_Portal_Sync_Status__c='Pending';
        insert asset;
        License__c objLicense= new License__c();
        objLicense.AssetId__c=asset.Id;
        objLicense.License_Expiration__c=null;
        insert objLicense;
        
        
        SBQQ__Subscription__c subOrch= new SBQQ__Subscription__c();
        subOrch.SerialNumber__c = '001BBC039649_t';
        subOrch.SBQQ__Account__c = acc.Id;
        subOrch.SBQQ__Product__c = ecOrchAAS.Id;
        subOrch.SBQQ__Quantity__c = 1;
        subOrch.SBQQ__Contract__c=objContract.Id;
        insert subOrch;
        
        SBQQ__Subscription__c baseSub= new SBQQ__Subscription__c();
        baseSub.SerialNumber__c = '001BBC039649_t';
        baseSub.SBQQ__Account__c = acc.Id;
        baseSub.SBQQ__Product__c = baseProduct.Id;
        baseSub.SBQQ__Quantity__c = 1;
        baseSub.SBQQ__Contract__c=objContract.Id;
        insert baseSub;
        
         SBQQ__Subscription__c saasSub= new SBQQ__Subscription__c();
        saasSub.SerialNumber__c = '001BBC039649_t';
        saasSub.SBQQ__Account__c = acc.Id;
        saasSub.SBQQ__Product__c = saasProduct.Id;
        saasSub.SBQQ__Quantity__c = 1;
        saasSub.SBQQ__Contract__c=objContract.Id;
        insert saasSub;
        
         SBQQ__Subscription__c plusSub= new SBQQ__Subscription__c();
        plusSub.SerialNumber__c = '001BBC039649_t';
        plusSub.SBQQ__Account__c = acc.Id;
        plusSub.SBQQ__Product__c = plusProduct.Id;
        plusSub.SBQQ__Quantity__c = 1;
        plusSub.SBQQ__Contract__c=objContract.Id;
        insert plusSub;
        
        
        SBQQ__Subscription__c sub1= new SBQQ__Subscription__c();
        sub1.SerialNumber__c = '001BBC039649_t';
        sub1.SBQQ__Account__c = acc.Id;
        sub1.SBQQ__Product__c = boostProduct.Id;
        sub1.SBQQ__Quantity__c = 10;
        sub1.SBQQ__Contract__c=objContract.Id;
        insert sub1;
        SBQQ__Subscription__c sub2= new SBQQ__Subscription__c();
        sub2.SerialNumber__c = '001BBC039649_t';
        sub2.SBQQ__Account__c = acc.Id;
        sub2.SBQQ__Product__c = plusProduct.Id;
        sub2.SBQQ__Quantity__c = 10;
        sub2.SBQQ__Contract__c=objContract.Id;
        insert sub2;
        acc.Sync_Virtual_Assets_with_CP__c=true;
        update acc;
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        CloudPortalPostAssetsJob obj= new CloudPortalPostAssetsJob();
        Database.executeBatch(obj);
        
        Test.stopTest();
    }
}