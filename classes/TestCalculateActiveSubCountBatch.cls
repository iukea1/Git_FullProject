@ISTest
public class TestCalculateActiveSubCountBatch {
    @IsTest
    public static void TestCalculateSubCountandDates()
    {
        
        Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Opportunity opp= new Opportunity(Name='Test Opp',AccountId=acc.Id,StageName='New',CloseDate=Date.today());
        insert opp;
        Product2 vxSub= new Product2(Name='VX-1000 Sub ',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxSub;
        Product2 vxProd= new Product2(Name='VX-1000 Sub(Asset)',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxProd;
        SBQQ__Quote__c quote= new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,Product_Type__c='NX/VX');
        insert quote;
        Contract con= new Contract(AccountId=acc.Id,SBQQ__Quote__c=quote.Id,StartDate=Date.today(),EndDate=Date.today().addDays(365));
        insert con;
        con.status='Activated';
        con.Trigger_Account_Sync__c=true;
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=vxSub.Id);
        insert sub;
          Test.startTest();
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=vxProd.Id,Status='Customer Subscription Active',SBQQ__CurrentSubscription__c=sub.Id);
        insert asset1;
        SBQQ__SubscribedAsset__c subAsset= new SBQQ__SubscribedAsset__c(SBQQ__Asset__c=asset1.Id,SBQQ__Subscription__c=sub.Id,SBQQ__Active__c=true);
        insert subAsset;
        List<sObject> lstCon= new List<sObject>();
        lstCon.add(con);
      
        CalculateActiveSubCountBatch obj = new CalculateActiveSubCountBatch();
       	Database.executeBatch(obj);
          Test.stopTest();
        Account outputAcc=[Select Active_Asset_Count__c,EC_Customer_Date__c,WAN_OP_Customer_Date__c from Account where Id=:acc.Id];
        System.debug('Active_Asset_Count__c'+outputAcc.Active_Asset_Count__c);
        System.assert(outputAcc.Active_Asset_Count__c>0);
        System.assert(outputAcc.EC_Customer_Date__c==null);
        System.assert(outputAcc.WAN_OP_Customer_Date__c!=null);
      
        
    }
    @IsTest
    public static void TestCalculateSubCountandDates_EC()
    {
        
        Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Opportunity opp= new Opportunity(Name='Test Opp',AccountId=acc.Id,StageName='New',CloseDate=Date.today());
        insert opp;
        Product2 ecSub= new Product2(Name='EC-BASE-1Y ',Model__c='EC-BASE-1Y',Family='Virtual Image', PRoduct_Type__c='EDGECONNECT');
        insert ecSub;
        
        SBQQ__Quote__c quote= new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,Product_Type__c='EDGECONNECT');
        insert quote;
        Contract con= new Contract(AccountId=acc.Id,SBQQ__Quote__c=quote.Id,StartDate=Date.today(),EndDate=Date.today().addDays(365));
        insert con;
        con.status='Activated';
        con.Trigger_Account_Sync__c=true;
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=ecSub.Id);
        insert sub;
        
     
        List<sObject> lstCon= new List<sObject>();
        lstCon.add(con);
        Test.startTest();
        CalculateActiveSubCountBatch obj = new CalculateActiveSubCountBatch();
       	Database.executeBatch(obj);
        Test.stopTest();
        Account outputAcc=[Select Active_Asset_Count__c,EC_Customer_Date__c,WAN_OP_Customer_Date__c from Account where Id=:acc.Id];
        System.debug('Active_Asset_Count__c'+outputAcc.Active_Asset_Count__c);
        System.assert(outputAcc.Active_Asset_Count__c>0);
        System.assert(outputAcc.EC_Customer_Date__c!=null);
        System.assert(outputAcc.WAN_OP_Customer_Date__c==null);
        
        
    }
    
    
}