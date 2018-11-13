@ISTest
public class TestQuoteTriggerHandler {

    @ISTest
    public static void TestQuoteStageCopiedintoEvalOpp()
    {
        Account acc= new Account(Name='TEst Account');
        insert acc;
      
        Opportunity opp= new Opportunity(AccountId=acc.Id,Name='TEst Opp',StageName='New',CloseDate=Date.today());
        insert opp;
        Opportunity evalopp= new Opportunity(AccountId=acc.Id,Name='TEst Opp',StageName='Open',CloseDate=Date.today(),OwnerId=UserInfo.getUserId(),Technical_Responsible__c=UserInfo.getUserId());
        evalOpp.Related_Opportunity__c=opp.Id;
        evalOpp.POC_Opportunity__c=true;
        
        insert evalopp;
        Test.startTest();
        SBQQ__Quote__c objQuote= new SBQQ__Quote__c(Product_Type__c='EDGECONNECT',SBQQ__Opportunity2__c=evalOpp.Id);
        insert objQuote;
         Test.stopTest();
        objQuote.POC_Status__c='Approved To Ship';
        update objQuote;
       
        Opportunity outputEvalOpp=[Select StageName from Opportunity where Id=:evalOpp.Id];
        System.assertEquals('Approved To Ship', outputEvalOpp.StageName);
        Opportunity outputOpp=[Select StageName,Active_POC__c,POC_History__c from Opportunity where Id=:opp.Id];
        System.assertEquals(true, outputOpp.Active_POC__c);
        System.assertEquals(true, outputOpp.POC_History__c);
        
    }
  
     @IsTest
    public static void TestApprovers_NAM()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
  
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User owner2ndManagerId = new User(Alias = 'standt', Email='testUser2@uniquetest.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = p.Id, 
                                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser2@uniquetest.com',IsActive=true);
        
        insert owner2ndManagerId;
        User owner1stManagerId = new User(Alias = 'standt', Email='testUser1@uniquetest.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = p.Id, managerId=owner2ndManagerId.Id,
                                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@uniquetest.com',IsActive=true);
        
        insert owner1stManagerId;
        User ownerId = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, managerId=owner1stManagerId.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com',IsActive=true);
        
        insert ownerId;
        
        User SE2ndManagerId = new User(Alias = 'standt', Email='testUser3@uniquetest.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, 
                                       TimeZoneSidKey='America/Los_Angeles', UserName='testUser3@uniquetest.com',IsActive=true);
        
        insert SE2ndManagerId;
        User SE1stManagerId = new User(Alias = 'standt', Email='testUser4@uniquetest.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, managerId=SE2ndManagerId.Id,
                                       TimeZoneSidKey='America/Los_Angeles', UserName='testUser4@uniquetest.com',IsActive=true);
        
        insert SE1stManagerId;
        User SEId = new User(Alias = 'standt', Email='testUser5@uniquetest.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, managerId=SE1stManagerId.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser5@uniquetest.com',IsActive=true);
        
        insert SEId;
        Opportunity opp= new Opportunity(AccountId=acc.Id,Name='TEst Opp',StageName='New',CloseDate=Date.today());
        insert opp;
        Opportunity evalopp= new Opportunity(AccountId=acc.Id,Name='TEst Opp',StageName='Open',CloseDate=Date.today(),OwnerId=UserInfo.getUserId(),Technical_Responsible__c=UserInfo.getUserId());
        evalOpp.Related_Opportunity__c=opp.Id;
        evalOpp.POC_Opportunity__c=true;
        evalOpp.OwnerId=ownerId.Id;
        insert evalopp;
        Test.startTest();
        SBQQ__Quote__c objQuote= new SBQQ__Quote__c(Product_Type__c='EDGECONNECT',SBQQ__Opportunity2__c=evalOpp.Id);
        insert objQuote;
        Test.stopTest();
        SBQQ__Quote__c output=[Select Id ,RSM_Approver_LK__c,RSM_Sales_Director_Approver_LK__c,RSM_VP_Sales_Approver_LK__c,SE_Approver_LK__c,SE_Director_Approver_LK__c,SE_Manager_Approver_LK__c from SBQQ__Quote__c where Id=:objQuote.Id] ;
        System.assert(output.RSM_Approver_LK__c!=null);
        System.assert(output.RSM_Sales_Director_Approver_LK__c!=null);
        System.assert(output.RSM_VP_Sales_Approver_LK__c!=null);
        System.assert(output.SE_Approver_LK__c!=null);
        System.assert(output.SE_Director_Approver_LK__c!=null);
        System.assert(output.SE_Manager_Approver_LK__c!=null);
    }
    @IsTest
    public static void TestApprovers_APAC()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
  
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User owner2ndManagerId = new User(Alias = 'standt', Email='testUser2@uniquetest.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = p.Id, 
                                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser2@uniquetest.com',IsActive=true);
        
        insert owner2ndManagerId;
        User owner1stManagerId = new User(Alias = 'standt', Email='testUser1@uniquetest.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = p.Id, managerId=owner2ndManagerId.Id,
                                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@uniquetest.com',IsActive=true);
        
        insert owner1stManagerId;
        User ownerId = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, managerId=owner1stManagerId.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com',IsActive=true);
        
        insert ownerId;
        
        User SE2ndManagerId = new User(Alias = 'standt', Email='testUser3@uniquetest.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, 
                                       TimeZoneSidKey='America/Los_Angeles', UserName='testUser3@uniquetest.com',IsActive=true);
        
        insert SE2ndManagerId;
        User SE1stManagerId = new User(Alias = 'standt', Email='testUser4@uniquetest.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, managerId=SE2ndManagerId.Id,
                                       TimeZoneSidKey='America/Los_Angeles', UserName='testUser4@uniquetest.com',IsActive=true);
        
        insert SE1stManagerId;
        User SEId = new User(Alias = 'standt', Email='testUser5@uniquetest.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, managerId=SE1stManagerId.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser5@uniquetest.com',IsActive=true);
        
        insert SEId;
        Opportunity opp= new Opportunity(AccountId=acc.Id,Name='TEst Opp',StageName='New',CloseDate=Date.today());
        insert opp;
        Opportunity evalopp= new Opportunity(AccountId=acc.Id,Name='TEst Opp',StageName='Open',CloseDate=Date.today(),OwnerId=UserInfo.getUserId(),Technical_Responsible__c=UserInfo.getUserId());
        evalOpp.Related_Opportunity__c=opp.Id;
        evalOpp.POC_Opportunity__c=true;
        evalOpp.Sales_Region__c='APAC';
        evalOpp.OwnerId=ownerId.Id;
       
        insert evalopp;
        Test.startTest();
        SBQQ__Quote__c objQuote= new SBQQ__Quote__c(Product_Type__c='EDGECONNECT',SBQQ__Opportunity2__c=evalOpp.Id);
        insert objQuote;
        Test.stopTest();
        SBQQ__Quote__c output=[Select Id ,RSM_Approver_LK__c,RSM_Sales_Director_Approver_LK__c,RSM_VP_Sales_Approver_LK__c,SE_Approver_LK__c,SE_Director_Approver_LK__c,SE_Manager_Approver_LK__c from SBQQ__Quote__c where Id=:objQuote.Id] ;
        System.assert(output.RSM_Approver_LK__c!=null);
        System.assert(output.RSM_Sales_Director_Approver_LK__c!=null);
        System.assert(output.RSM_VP_Sales_Approver_LK__c!=null);
        System.assert(output.SE_Approver_LK__c!=null);
        System.assert(output.SE_Director_Approver_LK__c!=null);
        System.assert(output.SE_Manager_Approver_LK__c!=null);
    }
    @IsTest
    public static void TestApprovers_Update()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
  
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User owner2ndManagerId = new User(Alias = 'standt', Email='testUser2@uniquetest.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = p.Id, 
                                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser2@uniquetest.com',IsActive=true);
        
        insert owner2ndManagerId;
        User owner1stManagerId = new User(Alias = 'standt', Email='testUser1@uniquetest.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = p.Id, managerId=owner2ndManagerId.Id,
                                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@uniquetest.com',IsActive=true);
        
        insert owner1stManagerId;
        User ownerId = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, managerId=owner1stManagerId.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com',IsActive=true);
        
        insert ownerId;
        
        User SE2ndManagerId = new User(Alias = 'standt', Email='testUser3@uniquetest.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, 
                                       TimeZoneSidKey='America/Los_Angeles', UserName='testUser3@uniquetest.com',IsActive=true);
        
        insert SE2ndManagerId;
        User SE1stManagerId = new User(Alias = 'standt', Email='testUser4@uniquetest.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, managerId=SE2ndManagerId.Id,
                                       TimeZoneSidKey='America/Los_Angeles', UserName='testUser4@uniquetest.com',IsActive=true);
        
        insert SE1stManagerId;
        User SEId = new User(Alias = 'standt', Email='testUser5@uniquetest.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, managerId=SE1stManagerId.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser5@uniquetest.com',IsActive=true);
        
        insert SEId;
        Opportunity opp= new Opportunity(AccountId=acc.Id,Name='TEst Opp',StageName='New',CloseDate=Date.today());
        insert opp;
        Opportunity evalopp= new Opportunity(AccountId=acc.Id,Name='TEst Opp',StageName='Open',CloseDate=Date.today(),OwnerId=UserInfo.getUserId(),Technical_Responsible__c=UserInfo.getUserId());
        evalOpp.Related_Opportunity__c=opp.Id;
        evalOpp.POC_Opportunity__c=true;
        insert evalopp;
       
        SBQQ__Quote__c objQuote= new SBQQ__Quote__c(Product_Type__c='EDGECONNECT',SBQQ__Opportunity2__c=evalOpp.Id);
        insert objQuote;
        evalOpp.OwnerId=ownerId.Id;
        update evalOpp;
         Test.startTest();
        objQuote.Refresh_Approvers__c=true;
        update objQuote;
        
        Test.stopTest();
        SBQQ__Quote__c output=[Select Id ,RSM_Approver_LK__c,RSM_Sales_Director_Approver_LK__c,RSM_VP_Sales_Approver_LK__c,SE_Approver_LK__c,SE_Director_Approver_LK__c,SE_Manager_Approver_LK__c from SBQQ__Quote__c where Id=:objQuote.Id] ;
        System.assert(output.RSM_Approver_LK__c!=null);
        System.assert(output.RSM_Sales_Director_Approver_LK__c!=null);
        System.assert(output.RSM_VP_Sales_Approver_LK__c!=null);
        System.assert(output.SE_Approver_LK__c!=null);
        System.assert(output.SE_Director_Approver_LK__c!=null);
        System.assert(output.SE_Manager_Approver_LK__c!=null);
        
    }
    
}