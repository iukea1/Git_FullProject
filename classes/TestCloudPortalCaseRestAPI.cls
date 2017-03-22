@Istest
public class TestCloudPortalCaseRestAPI {
    
    @Istest
    public static void TestCaseAPI_NoAsset()
    {
        CloudPortalCaseRestAPI.CaseData obj= new CloudPortalCaseRestAPI.CaseData();
        obj.subject='test';
        obj.description='test';
        obj.emailAddress='abc@abc.com';
        obj.priority='P3 - Normal';
        string jsonData=Json.serialize(obj);
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/CPCaseInfo';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonData);
        RestContext.request = req;
        RestContext.response= res;
        
        string resp=CloudPortalCaseRestAPI.CreateNewCase(obj); //Call the Method of the Class with Proper       Constructor 
        System.assert(resp!=null);//Assert that the Account is inserted and has Id        
        Test.stopTest();
    }
    @Istest
    public static void TestCaseAPI_Asset()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Account spacc = new Account(Name='Silver Peak Systems');
        insert spacc;
        Contact contact = new Contact(LastName='acme', AccountId=acc.Id);
        insert contact;
        Product2 product = new Product2(Name='EC-BASE-1Y', Family='Virtual Image', Product_Category__c='Subscription', IsActive=true);
        insert product;
        Asset asset1 = new Asset(Name='Test123', SerialNumber='Test123',AccountId=acc.Id,ContactId=contact.Id, Product2Id=product.Id);
        insert asset1;
        CloudPortalCaseRestAPI.CaseData obj= new CloudPortalCaseRestAPI.CaseData();
        obj.subject='test';
        obj.description='test';
        obj.emailAddress='abc@abc.com';
        obj.priority='P3 - Normal';
        obj.serialNumber=asset1.SerialNumber;
        string jsonData=Json.serialize(obj);
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/CPCaseInfo';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonData);
        RestContext.request = req;
        RestContext.response= res;
        
        string resp=CloudPortalCaseRestAPI.CreateNewCase(obj); //Call the Method of the Class with Proper       Constructor 
        System.assert(resp!=null);//Assert that the Account is inserted and has Id        
        Test.stopTest();
    }
    @Istest
    public static void TestCaseAPI_LicenseKey()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Account spacc = new Account(Name='Silver Peak Systems');
        insert spacc;
        Contact contact = new Contact(LastName='acme', AccountId=acc.Id);
        insert contact;
        Product2 product = new Product2(Name='EC-BASE-1Y', Family='Virtual Image', Product_Category__c='Subscription', IsActive=true);
        insert product;
        Asset asset1 = new Asset(Name='Test123', SerialNumber='Test123',AccountId=acc.Id,ContactId=contact.Id, Product2Id=product.Id);
        asset1.License_Key__c='test7777';
        insert asset1;
        CloudPortalCaseRestAPI.CaseData obj= new CloudPortalCaseRestAPI.CaseData();
        obj.subject='test';
        obj.description='test';
        obj.emailAddress='abc2323@abc.com';
        obj.priority='P3 - Normal';
        obj.serialNumber='9283932';
        obj.conFullName=contact.Name;
        obj.conPhoneNumber='2323232';
        obj.cpAccountKey='';
        obj.cpLicenseKey='test7777';
        string jsonData=Json.serialize(obj);
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/CPCaseInfo';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonData);
        RestContext.request = req;
        RestContext.response= res;
        
        string resp=CloudPortalCaseRestAPI.CreateNewCase(obj); //Call the Method of the Class with Proper       Constructor 
        System.assert(resp!=null);//Assert that the Account is inserted and has Id        
        Test.stopTest();
    }
    
      @Istest
    public static void TestCaseAPI_AccountKey()
    {
        Account acc = new Account(Name='acme',Cloud_Portal_Account_Key__c='Test233');
        insert acc;
        Account spacc = new Account(Name='Silver Peak Systems');
        insert spacc;
        Contact contact = new Contact(LastName='acme', AccountId=acc.Id);
        insert contact;
        Product2 product = new Product2(Name='EC-BASE-1Y', Family='Virtual Image', Product_Category__c='Subscription', IsActive=true);
        insert product;
        Asset asset1 = new Asset(Name='Test123', SerialNumber='Test123',AccountId=acc.Id,ContactId=contact.Id, Product2Id=product.Id);
        asset1.License_Key__c='test7777';
        insert asset1;
        CloudPortalCaseRestAPI.CaseData obj= new CloudPortalCaseRestAPI.CaseData();
        obj.subject='test';
        obj.description='test';
        obj.emailAddress='abc2323@abc.com';
        obj.priority='P3 - Normal';
        obj.serialNumber='9283932';
        obj.conFullName=contact.Name;
        obj.conPhoneNumber='2323232';
        obj.cpAccountKey='Test233';
        obj.cpLicenseKey='test3337777';
        string jsonData=Json.serialize(obj);
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/CPCaseInfo';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonData);
        RestContext.request = req;
        RestContext.response= res;
        
        string resp=CloudPortalCaseRestAPI.CreateNewCase(obj); //Call the Method of the Class with Proper       Constructor 
        System.assert(resp!=null);//Assert that the Account is inserted and has Id        
        Test.stopTest();
    }
    @Istest
    public static void TestS3FilesAPI()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Account spacc = new Account(Name='Silver Peak Systems');
        insert spacc;
        Contact contact = new Contact(LastName='acme', AccountId=acc.Id);
        insert contact;
        Product2 product = new Product2(Name='EC-BASE-1Y', Family='Virtual Image', Product_Category__c='Subscription', IsActive=true);
        insert product;
        Asset asset1 = new Asset(Name='Test123', SerialNumber='Test123',AccountId=acc.Id,ContactId=contact.Id, Product2Id=product.Id);
        insert asset1;
        Case case1= new Case(Subject='Test',Description='Test Data');
        insert case1;
        List<CloudPortalS3FileRestAPI.FileInfo> lstData= new List<CloudPortalS3FileRestAPI.FileInfo>();
        CloudPortalS3FileRestAPI.FileInfo obj= new CloudPortalS3FileRestAPI.FileInfo();
        obj.sfCaseId=case1.Id;
        obj.fileName='test';
        obj.fileKey='Test';
        obj.fileSize=289;
        lstData.add(obj);
        string jsonData=Json.serialize(obj);
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/CPFileInfo';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonData);
        RestContext.request = req;
        RestContext.response= res;
        
        string resp=CloudPortalS3FileRestAPI.UploadFilesToCase(lstData); //Call the Method of the Class with Proper       Constructor 
        System.assert(resp!=null);//Assert that the Account is inserted and has Id    
        System.assert(resp=='Files are created successfully.');
        Test.stopTest();
    }
}