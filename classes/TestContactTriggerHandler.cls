@IsTest
public class TestContactTriggerHandler {
 static final String PORTAL_PROFILE = '13a-SP Partner Portal';
    
    @isTest(seeAllData=true)
    static void testUpdatePartnerRole()
    {
        List<User> portalUsers = [select Id, ContactId, Contact.AccountId, Contact.Partner_Role__c from User where IsActive = true and Profile.Name = :PORTAL_PROFILE and ContactId != null and Contact.Partner_Role__c != 'Manager' limit 1];
        if(portalUsers.size() > 0)
        {
            User portalUser = portalUsers[0];
            if(portalUser.Contact != null && portalUser.Contact.AccountId != null)
            {
                Contact contact = portalUser.Contact;
                contact.Partner_Role__c = 'Manager';
                
                Test.startTest();
                update contact;
                List<UserRole> userRoles = [select Id from UserRole where PortalRole = 'Manager' and PortalAccountId = :contact.AccountId limit 1];
                if(userRoles.size() > 0)
                {
                    UserRole userRole = userRoles[0];
                    portalUser = [select UserRoleId from User where Id = :portalUser.Id];
                    System.assertEquals(userRole.Id, portalUser.UserRoleId);
                }
                Test.stopTest();  
            }
        }
    }
    
     @IsTest(SeeAllData=true)
    public static void TestAssignGeo_Insert()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, Region__c='West',GEO__c='NAM',
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        System.RunAs(usr)
        {
            Test.startTest();
            Contact con= new Contact(FirstName='TestFirst',LastName='Test Last',OwnerId=usr.Id);
            insert con;
            
            Contact newCon=[Select GEO__c,Accurate_GEO__c from Contact where Id=:con.id];
            System.assertEquals(newCon.Accurate_GEO__c,usr.GEO__c);
            Test.stopTest();
        }
        
    }
    
    @IsTest(SeeAllData=true)
    public static void TestAssignGeo_Update()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, Region__c='West',GEO__c='NAM',
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        User usr1 = new User(Alias = 'standt', Email='testUser1@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, Region__c='East',GEO__c='APAC',
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@uniquetest.com');
        
        usr1.IsActive =true;
        insert usr1;
        System.RunAs(usr)
        {
            Test.startTest();
            Contact con= new Contact(FirstName='TestFirst',LastName='Test Last',OwnerId=usr.Id);
            insert con;
            
            Contact newCon=[Select GEO__c,Accurate_GEO__c from Contact where Id=:con.id];
            System.assertEquals(newCon.Accurate_GEO__c,usr.GEO__c);
            newCon.OwnerId=usr1.Id;
            update newCon;
            
            Contact expectedCon=[Select GEO__c,Accurate_GEO__c from Contact where Id=:con.id];
            System.assertEquals(expectedCon.Accurate_GEO__c,usr1.GEO__c);
            Test.stopTest();
        }
        
    }
}