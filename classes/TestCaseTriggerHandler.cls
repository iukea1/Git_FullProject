@IsTest
public class TestCaseTriggerHandler {

    @IsTest
    public static void TestECContract()
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
    }
}