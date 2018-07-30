@IsTest
public class TestSubscriptionSharing {
    @IsTest
    public static void TestInsertSubscription()
    {
       	Account acc= new Account(Name='Test');
        insert acc;
        acc.Partner_Portal_Enabled__c=true;
        update acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = acc.Id, Email = 'test@test.com');
        insert portalContact;
        Test.startTest();
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser;
        portalContact.OwnerId = portalUser.Id;
        update portalContact;
        Test.stopTest();
        
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
        
        List<SBQQ__Subscription__Share> lstSubShare=[SELECT ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE IsDeleted=false and ParentId=:sub.Id];
   		System.debug('lstSubShare'+lstSubShare);
        System.assert(lstSubShare.size()>0);
        
   
 
    }
    
    
     @IsTest
    public static void TestInsertSubscription_SubShareUser()
    {
       	Account acc= new Account(Name='Test',Type='Partner');
        insert acc;
        acc.Partner_Portal_Enabled__c=true;
        update acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = acc.Id, Email = 'test@test.com');
        insert portalContact;
        Account acc1= new Account(Name='Test',Type='Partner');
        insert acc1;
		Contact portalContact1 = new Contact( FirstName = 'Test1', Lastname = 'Amit1', AccountId = acc1.Id, Email = 'test@test1.com');
        insert portalContact1;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser;
        portalContact.OwnerId = portalUser.Id;
        update portalContact;
        
        User portalUser1 = new User(
            Username = 'test127676uniquetest@test.com',
            ContactId = portalContact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test123787845',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser1;
        portalContact1.OwnerId = portalUser1.Id;
        update portalContact1;
        
        Product2 vxSub= new Product2(Name='VX-1000 Sub ',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxSub;
        Contract con= new Contract(AccountId=acc.Id);
        insert con;
        
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=vxSub.Id);
        insert sub;
        
        List<SBQQ__Subscription__Share> lstSubShare=[SELECT ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE IsDeleted=false and ParentId=:sub.Id];
   		System.debug('lstSubShare1'+lstSubShare.size());
        System.assert(lstSubShare.size()>0);
        Test.startTest();
        System.debug('portalUser1.Id'+ portalUser1.Id);
        AccountShare accShare1= new AccountShare(AccountId=acc.Id,UserOrGroupId=portalUser1.Id);
        accShare1.AccountAccessLevel='Read';
        accShare1.CaseAccessLevel='Read';
        accShare1.OpportunityAccessLevel='Read';
        insert accShare1;
        List<AccountShare> lstAcctShare=[Select Id from AccountShare where AccountId=:acc.Id and IsDeleted=false];
        System.debug('lstAcctShare'+lstAcctShare.size());
        SubscriptionSharingJob obj= new SubscriptionSharingJob();
        obj.execute(null,null);
        lstSubShare=[SELECT ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE IsDeleted=false and ParentId=:sub.Id];
   		System.debug('lstSubShare2 '+lstSubShare);
        System.assert(lstSubShare.size()>0);
       
       	delete accShare1;
        lstAcctShare=[Select Id from AccountShare where AccountId=:acc.Id and IsDeleted=false];
        System.debug('lstAcctShare2'+lstAcctShare.size());
        obj= new SubscriptionSharingJob();
        obj.execute(null,null);
        lstSubShare=[SELECT ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE IsDeleted=false and ParentId=:sub.Id];
   		System.debug('lstSubShare3 '+lstSubShare);
        System.assert(lstSubShare.size()>0);
        
        Test.stopTest();
 
    }
    
      @IsTest
    public static void TestInsertSubscription_SubShareRole()
    {
       	Account acc= new Account(Name='Test',Type='Partner');
        insert acc;
        acc.Partner_Portal_Enabled__c=true;
        update acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = acc.Id, Email = 'test@test.com');
        insert portalContact;
        Account acc1= new Account(Name='Test',Type='Partner');
        insert acc1;
		Contact portalContact1 = new Contact( FirstName = 'Test1', Lastname = 'Amit1', AccountId = acc1.Id, Email = 'test@test1.com');
        insert portalContact1;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser;
        portalContact.OwnerId = portalUser.Id;
        update portalContact;
        
        User portalUser1 = new User(
            Username = 'test127676uniquetest@test.com',
            ContactId = portalContact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test123787845',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser1;
        portalContact1.OwnerId = portalUser1.Id;
        update portalContact1;
        
        Product2 vxSub= new Product2(Name='VX-1000 Sub ',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxSub;
        Contract con= new Contract(AccountId=acc.Id);
        insert con;
        
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=vxSub.Id);
        insert sub;
        
        List<SBQQ__Subscription__Share> lstSubShare=[SELECT ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE IsDeleted=false and ParentId=:sub.Id];
   		System.debug('lstSubShare1'+lstSubShare.size());
        System.assert(lstSubShare.size()>0);
        Test.startTest();
        System.debug('portalUser1.Id'+ portalUser1.Id);
        AccountShare accShare1= new AccountShare(AccountId=acc.Id,UserOrGroupId=portalUser1.Id);
        accShare1.AccountAccessLevel='Read';
        accShare1.CaseAccessLevel='Read';
        accShare1.OpportunityAccessLevel='Read';
        insert accShare1;
        List<AccountShare> lstAcctShare=[Select Id from AccountShare where AccountId=:acc.Id and IsDeleted=false];
        System.debug('lstAcctShare'+lstAcctShare.size());
        SubscriptionSharingJob obj= new SubscriptionSharingJob();
        obj.execute(null,null);
        lstSubShare=[SELECT ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE IsDeleted=false and ParentId=:sub.Id];
   		System.debug('lstSubShare2 '+lstSubShare);
        System.assert(lstSubShare.size()>0);
       
       	delete accShare1;
        lstAcctShare=[Select Id from AccountShare where AccountId=:acc.Id and IsDeleted=false];
        System.debug('lstAcctShare2'+lstAcctShare.size());
        obj= new SubscriptionSharingJob();
        obj.execute(null,null);
        lstSubShare=[SELECT ParentId,UserOrGroupId FROM SBQQ__Subscription__Share WHERE IsDeleted=false and ParentId=:sub.Id];
   		System.debug('lstSubShare3 '+lstSubShare);
        System.assert(lstSubShare.size()>0);
        
        Test.stopTest();
 
    }

}