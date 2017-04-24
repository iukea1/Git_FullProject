@isTest
public class EmailNotificationOnCapCommentsTest {

    @isTest static void NoCapComments(){
     Account acc  = new Account();
     acc.Name     = 'Hybrid Technologies';
     acc.Type     = 'Prospect'; 
     insert acc;  
     
     Cap__c cap = new Cap__c();
     cap.Account_Name__c = acc.Id;
     cap.Status__c = 'Open';
     cap.Cap_Comments_Recipients__c= 'pmusunuru@silver-peak.com';
     insert cap;
        
     cap.Cap_Comments__c = '';
     update cap;         
    } 
    
    @isTest static void CapCommentsSame(){
     Account acc  = new Account();
     acc.Name     = 'Xyz Technologies';
     acc.Type     = 'Prospect'; 
     insert acc;  
     
     Cap__c cap = new Cap__c();
     cap.Account_Name__c = acc.Id;
     cap.Status__c = 'Open';
     cap.Cap_Comments__c = 'Test Comments';
     cap.Cap_Comments_Recipients__c= 'pmusunuru@silver-peak.com';
     insert cap;
        
     cap.Cap_Comments__c = 'Test Comments';
     update cap;
    }
    
     @isTest static void InvalidEmail(){
     Account acc  = new Account();
     acc.Name     = 'abc Technologies';
     acc.Type     = 'Prospect'; 
     insert acc;  
     
     Cap__c cap = new Cap__c();
     cap.Account_Name__c = acc.Id;
     cap.Status__c = 'Open';
     cap.Cap_Comments__c = 'Test Comments';
     cap.Cap_Comments_Recipients__c= '<pmusunuru@silver-peak.com>,<musunuru.p@gmailcom>';
     insert cap;
        
     cap.Cap_Comments__c = 'Test Comments.Plz Ignore!';
      
         try{
              update cap;
         }
         catch(Exception e){
            System.assert(e.getMessage().contains('Invalid Email Format. Please check following emails:'));
         }
    } 
    
     @isTest static void ValidEmail(){
     Account acc  = new Account();
     acc.Name     = 'Red Technologies';
     acc.Type     = 'Prospect'; 
     insert acc;  
     
     Cap__c cap = new Cap__c();
     cap.Account_Name__c = acc.Id;
     cap.Status__c = 'Open';
     cap.Cap_Comments__c = 'Test Comments';
     cap.Cap_Comments_Recipients__c= '<pmusunuru@silver-peak.com> , <musunuru.p@gmail.com> ';
     insert cap;
        
     cap.Cap_Comments__c = 'Test Comments. Plz Ignore!';
     update cap;
    }
    
    
}