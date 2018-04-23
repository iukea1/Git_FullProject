@isTest
public class TestDENotesTriggers {
    
    //Test creation of DE Notes when Deployment Engineering is not checked on Account
    @isTest static void IsDeploymentEngineeringFalse(){
        Profile prof = [SELECT Id FROM Profile WHERE Name='Engineering Support']; 
        User engUser = new User(Alias = 'standt', Email='testUser@testenguser.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prof.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testenguser.com');
        
        try{
            Account acc  = new Account(Name = 'Hybrid Technologies', Type = 'Customer', Deployment_Engineering__c = False);
            insert acc;        
            
            De_Note__c den = new DE_Note__c(Account_Name__c = acc.Id, Deployment_Engineer__c = engUser.Id, DE_Notes__c = 'TestNotes', Send_Email_To_Case_Owners__c = True);
            insert den;
        }
        catch(exception e){
            system.assert(e.getMessage().contains('DE Notes can be created only when Deployment Engineering is checked on Account'));
        }   
    }
    
    //DE Case Notes should not be created for cases that are not Tech Support
    @isTest static void IsNotTechSupportCase(){
        Profile prof = [SELECT Id FROM Profile WHERE Name='Engineering Support']; 
        User engUser = new User(Alias = 'standt', Email='testUser@testenguser.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prof.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testenguser.com');
        
        Account acc = new Account(Name = 'Hybrid Technologies', Type = 'Customer', Deployment_Engineering__c = True);
        insert acc;
        
        Contact con = new Contact(FirstName = 'John', LastName  = 'Doe', AccountId = acc.Id);
        insert con;
        
        Case case1 = new Case(Subject = 'Invalid Case for DE Notes', AccountId = acc.Id, ContactId = con.Id, RecordTypeId = '012500000005HNd', Priority = 'P4 - Low', Type = 'Customer Service', Origin = 'Web');
        insert case1;
        
        De_Note__c den = new DE_Note__c(Account_Name__c = acc.Id, Deployment_Engineer__c = engUser.Id, DE_Notes__c = 'TestNotes', Send_Email_To_Case_Owners__c = True);
        insert den;
        
        List<DE_Case_Note__c> lstDECaseNotes = [Select Id, De_Note__r.Id from DE_Case_Note__c where DE_Note__r.Id =:den.Id];
        system.assertEquals(0,lstDECaseNotes.size() );
    }
    
    //DE Case Notes created for cases that are Tech Support
    @isTest static void IsTechSupportCase(){
        Profile prof = [SELECT Id FROM Profile WHERE Name='Engineering Support']; 
        User engUser = new User(Alias = 'standt', Email='testUser@testenguser.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prof.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testenguser.com');  
        
        Account acc = new Account(Name = 'Hybrid Technologies', Type = 'Customer', Deployment_Engineering__c = True);
        insert acc;
        
        Contact con = new Contact(FirstName = 'John', LastName  = 'Doe', AccountId = acc.Id);
        insert con;
        
        Case case1 = new Case(Subject = 'Valid Case for DE Notes', AccountId = acc.Id, ContactId = con.Id, RecordTypeId = '012500000005Aui', Priority = 'P4 - Low', Type = 'Customer Service', Origin = 'Web');
        insert case1;
        
        De_Note__c den = new DE_Note__c(Account_Name__c = acc.Id, Deployment_Engineer__c = engUser.Id, DE_Notes__c = 'TestNotes', Send_Email_To_Case_Owners__c = True);
        insert den;
        
        List<DE_Case_Note__c> lstDECaseNotes = [Select Id, De_Note__r.Id from DE_Case_Note__c where DE_Note__r.Id =:den.Id and Case_Number__r.Id = :Case1.Id];
        system.assertEquals(1,lstDECaseNotes.size() );
    }
    
    //A non Tech Support case is created for a account that has DE Notes
    @isTest static void NewCaseNotTechSupport(){
        Profile prof = [SELECT Id FROM Profile WHERE Name='Engineering Support']; 
        User engUser = new User(Alias = 'standt', Email='testUser@testenguser.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prof.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testenguser.com');  
        
        Account acc = new Account(Name = 'Hybrid Technologies', Type = 'Customer', Deployment_Engineering__c = True);
        insert acc;
        
        Contact con = new Contact(FirstName = 'John', LastName  = 'Doe', AccountId = acc.Id);
        insert con;
        
        De_Note__c den = new DE_Note__c(Account_Name__c = acc.Id, Deployment_Engineer__c = engUser.Id, DE_Notes__c = 'TestNotes', Send_Email_To_Case_Owners__c = True);
        insert den;
        
        Case case1 = new Case(Subject = 'Invalid Case for DE Notes', AccountId = acc.Id, ContactId = con.Id, RecordTypeId = '012500000005HNd', Priority = 'P4 - Low', Type = 'Customer Service', Origin = 'Web');
        insert case1;
        
        List<DE_Case_Note__c> lstDECaseNotes = [Select Id, De_Note__r.Id from DE_Case_Note__c where DE_Note__r.Id =:den.Id];
        system.assertEquals(0,lstDECaseNotes.size() );
    }
    
    //A Tech Support Case is created for an account that has DE Notes
    @isTest static void NewCaseIsTechSupport(){
        Profile prof = [SELECT Id FROM Profile WHERE Name='Engineering Support']; 
        User engUser = new User(Alias = 'standt', Email='testUser@testenguser.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prof.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testenguser.com');  
        
        Account acc = new Account(Name = 'Hybrid Technologies', Type = 'Customer', Deployment_Engineering__c = True);
        insert acc;
        
        Contact con = new Contact(FirstName = 'John', LastName  = 'Doe', AccountId = acc.Id);
        insert con;
        
        De_Note__c den = new DE_Note__c(Account_Name__c = acc.Id, Deployment_Engineer__c = engUser.Id, DE_Notes__c = 'TestNotes', Send_Email_To_Case_Owners__c = True);
        insert den;
        
        Case case1 = new Case(Subject = 'Valid Case for DE Notes', AccountId = acc.Id, ContactId = con.Id, RecordTypeId = '012500000005Aui', Priority = 'P4 - Low', Type = 'Customer Service', Origin = 'Web');
        insert case1;
        
        List<DE_Case_Note__c> lstDECaseNotes = [Select Id, De_Note__r.Id from DE_Case_Note__c where DE_Note__r.Id =:den.Id];
        system.assertEquals(1,lstDECaseNotes.size() );
    }
    
    //New Attachement is creaetd for DE Notes
    @isTest public static void NewAttachmentCreated(){
        Profile prof = [SELECT Id FROM Profile WHERE Name='Engineering Support']; 
        User engUser = new User(Alias = 'standt', Email='testUser@testenguser.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prof.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testenguser.com');     
        
        Account acc = new Account(Name = 'Hybrid Technologies', Type = 'Customer', Deployment_Engineering__c = True);
        insert acc;
        
        De_Note__c den = new DE_Note__c(Account_Name__c = acc.Id, Deployment_Engineer__c = engUser.Id, DE_Notes__c = 'TestNotes', Send_Email_To_Case_Owners__c = True);
        insert den;
        
        List<DE_Note__c> lstDENotes = [Select Id, Has_Attachment__c from DE_Note__c where Id =:den.Id];
        System.assertEquals(False, lstDENotes[0].Has_Attachment__c);
        
        Attachment att = new Attachment(Name = 'Test Attachment', Body = Blob.valueOf('abc'), ParentId = den.Id);
        insert att;
        
        List<DE_Note__c> lstDENotes1 = [Select Id, Has_Attachment__c from DE_Note__c where Id =:den.Id];
        System.assertEquals(True, lstDENotes1[0].Has_Attachment__c);  
    }
    
    //Attachment Deleted for DE Note with Multiple Attachments
    @isTest public static void AttachementDeleted(){
        Profile prof = [SELECT Id FROM Profile WHERE Name='Engineering Support']; 
        User engUser = new User(Alias = 'standt', Email='testUser@testenguser.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prof.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testenguser.com'); 
        
        Account acc = new Account(Name = 'Hybrid Technologies', Type = 'Customer', Deployment_Engineering__c = True);
        insert acc;
        
        De_Note__c den = new DE_Note__c(Account_Name__c = acc.Id, Deployment_Engineer__c = engUser.Id, DE_Notes__c = 'TestNotes', Send_Email_To_Case_Owners__c = True);
        insert den;
        
        List<DE_Note__c> lstDENotes = [Select Id, Has_Attachment__c from DE_Note__c where Id =:den.Id];
        System.assertEquals(False, lstDENotes[0].Has_Attachment__c);
        
        Attachment att = new Attachment(Name = 'Test Attachment', Body = Blob.valueOf('abc'), ParentId = den.Id);
        insert att;
        
        Attachment att1 = new Attachment(Name = 'Test Attachment1', Body = Blob.valueOf('abcd'), ParentId = den.Id);
        insert att1;
        
        List<DE_Note__c> lstDENotes1 = [Select Id, Has_Attachment__c from DE_Note__c where Id =:den.Id];
        System.assertEquals(True, lstDENotes1[0].Has_Attachment__c); 
        
        Delete att;
        
        List<DE_Note__c> lstDENotes2 = [Select Id, Has_Attachment__c from DE_Note__c where Id =:den.Id];
        System.assertEquals(True, lstDENotes2[0].Has_Attachment__c); 
        
        Delete att1;
        
        List<DE_Note__c> lstDENotes3 = [Select Id, Has_Attachment__c from DE_Note__c where Id =:den.Id];
        System.assertEquals(False, lstDENotes3[0].Has_Attachment__c);  
    }
}