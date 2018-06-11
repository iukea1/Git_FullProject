@IsTest
public class TestCaseTriggerHandler {
    
    @IsTest
    public static void TestECContract_Insert()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='New', ForecastCategoryName ='Omitted', AccountId=acc.Id,Product_Type__c='Both');
        insert testOpp;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact cont= new Contact(LastName='Test',AccountId=acc.Id);
        insert cont;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        product.Product_Type__c = 'EDGECONNECT';
        product.Family = 'Virtual Image';
        insert product;
        
        Product2 echw = new Product2();
        echw.Name = 'EC-XS-1Y';
        echw.ProductCode = 'EC-XS-1Y';
        echw.Model__c = 'EC-XS-1Y';
        echw.Product_Type__c = 'EDGECONNECT';
        echw.Family = 'Product';
        insert echw;
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = echw.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        asset.Licenses_Nodes__c=10;
        insert asset;
        SBQQ__Quote__c quote= new SBQQ__Quote__c(SBQQ__Opportunity2__c=testOpp.Id,Product_Type__c='EDGECONNECT');
        insert quote;
        Contract con= new Contract(AccountId=acc.Id,SBQQ__Quote__c=quote.Id,StartDate=Date.today());
        insert con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Quantity__c=1,SBQQ__Account__c=acc.Id,SBQQ__Product__c=product.Id,SBQQ__Contract__c=con.Id);
        insert sub;
        
        Case case1= new Case(AccountId=acc.Id,AssetId=asset.Id);
        insert case1;
        Case outputCase=[Select Id,Asset_Sub_Contract__c from Case where Id=:case1.Id];
        System.assert(outputCase.Asset_Sub_Contract__c!=null);
    }
    
    @IsTest
    public static void TestECContract_Update()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='New', ForecastCategoryName ='Omitted', AccountId=acc.Id,Product_Type__c='Both');
        insert testOpp;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact cont= new Contact(LastName='Test',AccountId=acc.Id);
        insert cont;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        product.Product_Type__c = 'EDGECONNECT';
        product.Family = 'Virtual Image';
        insert product;
        
        Product2 echw = new Product2();
        echw.Name = 'EC-XS-1Y';
        echw.ProductCode = 'EC-XS-1Y';
        echw.Model__c = 'EC-XS-1Y';
        echw.Product_Type__c = 'EDGECONNECT';
        echw.Family = 'Product';
        insert echw;
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = echw.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        asset.Licenses_Nodes__c=10;
        insert asset;
        SBQQ__Quote__c quote= new SBQQ__Quote__c(SBQQ__Opportunity2__c=testOpp.Id,Product_Type__c='EDGECONNECT');
        insert quote;
        Contract con= new Contract(AccountId=acc.Id,SBQQ__Quote__c=quote.Id,StartDate=Date.today());
        insert con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Quantity__c=1,SBQQ__Account__c=acc.Id,SBQQ__Product__c=product.Id,SBQQ__Contract__c=con.Id);
        insert sub;
        
        Case case1= new Case(AccountId=acc.Id);
        insert case1;
        Case outputCase=[Select Id,Asset_Sub_Contract__c from Case where Id=:case1.Id];
        System.assert(outputCase.Asset_Sub_Contract__c==null);
        case1.assetId=asset.Id;
        update case1;
        outputCase=[Select Id,Asset_Sub_Contract__c from Case where Id=:case1.Id];
        System.assert(outputCase.Asset_Sub_Contract__c!=null);
    }
    
    @IsTest
    public static void TestNonECContract_Insert()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='New', ForecastCategoryName ='Omitted', AccountId=acc.Id,Product_Type__c='Both');
        insert testOpp;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact cont= new Contact(LastName='Test',AccountId=acc.Id);
        insert cont;
        Product2 product = new Product2();
        product.Name = 'VX-1000';
        product.ProductCode = 'VX-1000';
        product.Model__c = 'VX-1000';
        product.Product_Type__c = 'NX/VX';
        product.Family = 'Virtual Image';
        insert product;
        
        Product2 hw = new Product2();
        hw.Name = 'NX-1700';
        hw.ProductCode = 'NX-1700';
        hw.Model__c = 'NX-1700';
        hw.Product_Type__c = 'NX/VX';
        hw.Family = 'Product';
        insert hw;
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = hw.Id;
        asset.Status = 'Customer Owned';
        asset.Quantity = 1;
        asset.Licenses_Nodes__c=10;
        insert asset;
        SBQQ__Quote__c quote= new SBQQ__Quote__c(SBQQ__Opportunity2__c=testOpp.Id,Product_Type__c='NX/VX');
        insert quote;
        Contract con= new Contract(AccountId=acc.Id,SBQQ__Quote__c=quote.Id,StartDate=Date.today());
        insert con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Quantity__c=1,SBQQ__Account__c=acc.Id,SBQQ__Product__c=product.Id,SBQQ__Contract__c=con.Id);
        insert sub;
        
        asset.SBQQ__CurrentSubscription__c=sub.Id;
        Update asset;
        Case case1= new Case(AccountId=acc.Id,AssetId=asset.Id);
        insert case1;
        Case outputCase=[Select Id,Asset_Sub_Contract__c from Case where Id=:case1.Id];
        System.assert(outputCase.Asset_Sub_Contract__c!=null);
    }
    
    @IsTest
    public static void TestNonECContract_Update()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='New', ForecastCategoryName ='Omitted', AccountId=acc.Id,Product_Type__c='Both');
        insert testOpp;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact cont= new Contact(LastName='Test',AccountId=acc.Id);
        insert cont;
        Product2 product = new Product2();
        product.Name = 'VX-1000';
        product.ProductCode = 'VX-1000';
        product.Model__c = 'VX-1000';
        product.Product_Type__c = 'NX/VX';
        product.Family = 'Virtual Image';
        insert product;
        
        Product2 hw = new Product2();
        hw.Name = 'NX-1700';
        hw.ProductCode = 'NX-1700';
        hw.Model__c = 'NX-1700';
        hw.Product_Type__c = 'NX/VX';
        hw.Family = 'Product';
        insert hw;
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = hw.Id;
        asset.Status = 'Customer Owned';
        asset.Quantity = 1;
        asset.Licenses_Nodes__c=10;
        insert asset;
        SBQQ__Quote__c quote= new SBQQ__Quote__c(SBQQ__Opportunity2__c=testOpp.Id,Product_Type__c='NX/VX');
        insert quote;
        Contract con= new Contract(AccountId=acc.Id,SBQQ__Quote__c=quote.Id,StartDate=Date.today());
        insert con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Quantity__c=1,SBQQ__Account__c=acc.Id,SBQQ__Product__c=product.Id,SBQQ__Contract__c=con.Id);
        insert sub;
        
        asset.SBQQ__CurrentSubscription__c=sub.Id;
        Update asset;
        Case case1= new Case(AccountId=acc.Id);
        insert case1;
        Case outputCase=[Select Id,Asset_Sub_Contract__c from Case where Id=:case1.Id];
        System.assert(outputCase.Asset_Sub_Contract__c==null);
        case1.assetId=asset.Id;
        update case1;
        outputCase=[Select Id,Asset_Sub_Contract__c from Case where Id=:case1.Id];
        System.assert(outputCase.Asset_Sub_Contract__c!=null);
    }
    
    //A non Tech Support case is created for a account that has DE Notes
    @isTest
    static void NewCaseNotTechSupport()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='Engineering Support']; 
        User engUser = new User(Alias = 'standt', Email='testUser@testenguser.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prof.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testenguser.com');  
        
        Account acc = new Account(Name = 'Hybrid Technologies', Type = 'Customer', Deployment_Engineering__c = True);
        insert acc;
        
        Contact con = new Contact(FirstName = 'John', LastName  = 'Doe', AccountId = acc.Id);
        insert con;
        
        De_Note__c den = new DE_Note__c(Account_Name__c = acc.Id, DE_Notes__c = 'TestNotes', Send_Email_To_Case_Owners__c = True);
        insert den;
        
        Case case1 = new Case(Subject = 'Invalid Case for DE Notes', AccountId = acc.Id, ContactId = con.Id, RecordTypeId = '012500000005HNd', Priority = 'P4 - Low', Type = 'Customer Service', Origin = 'Web');
        insert case1;
        
        List<DE_Case_Note__c> lstDECaseNotes = [Select Id, De_Note__r.Id from DE_Case_Note__c where DE_Note__r.Id =:den.Id];
        system.assertEquals(0,lstDECaseNotes.size() );
    }
    
    //A Tech Support Case is created for an account that has DE Notes
    @isTest
    static void NewCaseIsTechSupport()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='Engineering Support']; 
        User engUser = new User(Alias = 'standt', Email='testUser@testenguser.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prof.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testenguser.com');  
        
        Account acc = new Account(Name = 'Hybrid Technologies', Type = 'Customer', Deployment_Engineering__c = True);
        insert acc;
        
        Contact con = new Contact(FirstName = 'John', LastName  = 'Doe', AccountId = acc.Id);
        insert con;
        
        De_Note__c den = new DE_Note__c(Account_Name__c = acc.Id, DE_Notes__c = 'TestNotes', Send_Email_To_Case_Owners__c = True);
        insert den;
        
        Case case1 = new Case(Subject = 'Valid Case for DE Notes', AccountId = acc.Id, ContactId = con.Id, RecordTypeId = '012500000005Aui', Priority = 'P4 - Low', Type = 'Customer Service', Origin = 'Web');
        insert case1;
        
        List<DE_Case_Note__c> lstDECaseNotes = [Select Id, De_Note__r.Id from DE_Case_Note__c where DE_Note__r.Id =:den.Id];
        system.assertEquals(1,lstDECaseNotes.size() );
    }
}