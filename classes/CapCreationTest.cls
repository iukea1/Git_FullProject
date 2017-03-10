@isTest
private class CapCreationTest {
   @isTest static void TestcapCreation() {  
       //Create New Account
       Account acc  = new Account();
       acc.Name     = 'Hybrid Technologies';
       acc.Type     = 'Prospect';
       acc.IsCap__c = FALSE; 
       insert acc;
       
       //Create a new Contact and associate with the Account
       Contact con   = new Contact();
       con.FirstName = 'John';
       con.LastName  = 'Doe';
       con.AccountId = acc.Id;
       insert con;
       
       //Create a new Case of Technical Support RecordType
       Case case1         = new Case();
       case1.Subject      = 'Test Cap Creation for Account';
       case1.AccountId    = acc.Id;
       case1.ContactId    = con.Id;
       case1.RecordTypeId = '012500000005Aui';
       case1.Priority     = 'P4 - Low';
       case1.Status       = 'Unassigned';
	   case1.Type         = 'Technical Support';
	   case1.Origin       = 'Web';
       insert case1;
       
       //Create a second new case of IT Help request recordtype
       Case case2         = new Case();
       case2.Subject      = 'Invalid Case for Cap Creation';
       case2.AccountId    = acc.Id;
       case2.ContactId    = con.Id;
       case2.RecordTypeId = '012500000005HNd';
       case2.Priority     = 'P4 - Low';
       case2.Status       = 'Closed';
	   case2.Type         = 'Customer Service';
	   case2.Origin       = 'Web';
       insert case2;
      
	   acc.IsCap__c = TRUE;
	   update acc;       
   }     
}