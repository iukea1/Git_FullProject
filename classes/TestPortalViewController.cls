@IsTest
public class TestPortalViewController {
    
    @IsTest
    public static void TestViewController_WanOp()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 vxSub= new Product2(Name='VX-1000 Sub ',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxSub;
        Product2 vxProd= new Product2(Name='VX-1000 Sub(Asset)',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxProd;
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=vxProd.Id,Status='Customer Owned');
        insert asset1;
        Contract con= new Contract(AccountId=acc.Id,StartDate=Date.today(),EndDate=Date.today().addYears(1));
        insert con;
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=vxSub.Id);
        insert sub;
        
        asset1.SBQQ__CurrentSubscription__c=sub.Id;
        update asset1;
        
        SBQQ__SubscribedAsset__c subAsset= new SBQQ__SubscribedAsset__c();
        subAsset.SBQQ__Asset__c=asset1.Id;
        subAsset.SBQQ__Subscription__c=sub.Id;
        subAsset.SBQQ__Active__c=true;
        
        insert subAsset;
        PortalViewController_WanOp portal1= new PortalViewController_WanOp();
        portal1.sortTable();
        System.assert(portal1.lstResults.size()>0);
        
    }
    
    @IsTest
    public static void TestViewController_WanOp_Search()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 vxSub= new Product2(Name='VX-1000 Sub ',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxSub;
        Product2 vxProd= new Product2(Name='VX-1000 Sub(Asset)',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxProd;
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=vxProd.Id,Status='Customer Owned');
        insert asset1;
        Contract con= new Contract(AccountId=acc.Id,StartDate=Date.today(),EndDate=Date.today().addYears(1));
        insert con;
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=vxSub.Id);
        insert sub;
        
        asset1.SBQQ__CurrentSubscription__c=sub.Id;
        update asset1;
        
        SBQQ__SubscribedAsset__c subAsset= new SBQQ__SubscribedAsset__c();
        subAsset.SBQQ__Asset__c=asset1.Id;
        subAsset.SBQQ__Subscription__c=sub.Id;
        subAsset.SBQQ__Active__c=true;
        
        insert subAsset;
        PortalViewController_WanOp portal1= new PortalViewController_WanOp();
        portal1.SearchParameter='VX-1000';
        portal1.IsSearchForActive=true;
        portal1.searchAssets();
        System.assert(portal1.lstResults.size()>0);
        portal1.lstResults[0].CustomerNotes='test';
        portal1.saveAsset();
        portal1.sendListToCurrentUser();
        
        
    }
    @IsTest
    public static void TestViewController_EC()
    {
        Account acc= new Account(Name='Test',Cloud_Portal_Account_Key__c='test',Cloud_Portal_Account_Name__c='test',Cloud_Portal_Account_Id__c='test' );
        insert acc;
        Contact cont= new Contact(LastName='prane',email='prane@silver-peak.com',AccountId=acc.Id);
        insert cont;
        Profile prof = [SELECT Id FROM Profile WHERE Name='12-SP Portal']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, ContactId=cont.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 ecBase= new Product2(Name='EC-BASE-1Y ',Model__c='EC-BASE-1Y',Family='Virtual Image', PRoduct_Type__c='EDGECONNECT');
        insert ecBase;
        Product2 ecplus= new Product2(Name='EC-PLUS-1Y ',Model__c='EC-PLUS-1Y',Family='Virtual Image', PRoduct_Type__c='EDGECONNECT');
        insert ecplus;
        Product2 ecBoost= new Product2(Name='EC-BOOST-1Y ',Model__c='EC-BOOST-1Y',Family='Virtual Image', PRoduct_Type__c='EDGECONNECT');
        insert ecBoost;
        Product2 ecMini= new Product2(Name='EC-MINI-1Y ',Model__c='EC-MINI-1Y',Family='Virtual Image', PRoduct_Type__c='EDGECONNECT');
        insert ecMini;
        Product2 ecHW= new Product2(Name='EC-XS-1Y',Model__c='EC-XS-1Y',Family='Product', PRoduct_Type__c='EDGECONNECT');
        insert ecHW;
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=ecHW.Id,Status='Customer Owned');
        insert asset1;
        SBQQ__Quote__c objQuote= new SBQQ__Quote__c(Product_Type__c='EDGECONNECT',SBQQ__StartDate__c=Date.today());
        insert objQuote;
        Contract con= new Contract(AccountId=acc.Id,StartDate=Date.today(),EndDate=Date.today().addYears(1));
        insert con;
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub1= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=ecBase.Id);
        insert sub1;
        System.debug('SBCF_Subscription_Status__c'+sub1.SBCF_Subscription_Status__c);
        SBQQ__Subscription__c sub2= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=ecPlus.Id);
        insert sub2;
        SBQQ__Subscription__c sub3= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=ecBoost.Id);
        insert sub3;
        SBQQ__Subscription__c sub4= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=ecMini.Id);
        insert sub4;
        System.runAs(usr)
        {
            PortalViewController_SDWAN portal1= new PortalViewController_SDWAN();
            System.debug('portal1.lstResults' + portal1.lstResults);
            System.assert(portal1.lstResults.size()==5);
            portal1.SearchParameter='EC-BASE';
            portal1.IsSearchForActive=true;
            portal1.searchAssets();
            System.assert(portal1.lstResults.size()==1);
            portal1.sendListToCurrentUser();
        }
        
        
    }
    @IsTest
    public static void TestViewController_SP()
    {
        Account acc= new Account(ECSP__c=true,Service_Provider_Account_Type__c='EC-SP-Metered',Unity_Orch_Location__c=null,Service_Provider_Admin_User__c='abc@silver-peak.com',Name='Test',Cloud_Portal_Account_Key__c='test',Cloud_Portal_Account_Name__c='test',Cloud_Portal_Account_Id__c='test' );
        insert acc;
        Contact cont= new Contact(LastName='prane',email='prane@silver-peak.com',AccountId=acc.Id);
        insert cont;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 mainSub= new Product2(Name='EC-L-SP-MAINT-1Y',Model__c='EC-L-SP-MAINT-1Y',Family='Virtual Image', PRoduct_Type__c='EC-SP-Metered');
        insert mainSub;
        Product2 ecHW= new Product2(Name='EC-L-SP',Model__c='EC-L-SP',Family='Product', PRoduct_Type__c='EC-SP-Metered');
        insert ecHW;
        Contract con= new Contract(AccountId=acc.Id,StartDate=Date.today(),EndDate=Date.today().addYears(1));
        insert con;
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=mainSub.Id,SBQQ__RequiredByProduct__c=mainSub.Id);
        insert sub;
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=ecHW.Id,Status='Customer Owned',SBQQ__CurrentSubscription__c=sub.Id);
        insert asset1;
        SBQQ__SubscribedAsset__c subAsset= new SBQQ__SubscribedAsset__c();
        subAsset.SBQQ__Asset__c=asset1.Id;
        subAsset.SBQQ__Subscription__c=sub.Id;
        subAsset.SBQQ__Active__c=true;
        insert subAsset;
        PortalViewController_SP portal1= new PortalViewController_SP();
        System.debug('portal1.lstResults' + portal1.lstResults);
        System.assert(portal1.lstResults.size()==1);
        portal1.SearchParameter='EC-L';
        portal1.IsSearchForActive=true;
        portal1.searchAssets();
        System.assert(portal1.lstResults.size()==1);
        
    }
    @IsTest
    public static void TestViewController_NXVX()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Contact cont= new Contact(LastName='prane',email='prane@silver-peak.com',AccountId=acc.Id);
        insert cont;
        CmaProductMapping__c obj= new CmaProductMapping__c(Name='test',NX__c='NX-1700');
        insert obj;
        
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 mainSub= new Product2(Name='NX-1700 - MAINT CONTRACT',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert mainSub;
        Product2 nxHW= new Product2(Name='NX-1700',Model__c='NX-1700',Family='Product', PRoduct_Type__c='NX/VX');
        insert nxHW;
        SBQQ__Quote__c objQuote= new SBQQ__Quote__c(Product_Type__c='NX/VX',SBQQ__StartDate__c=Date.today());
        insert objQuote;
        SBQQ__QuoteLine__c objQuoteL= new SBQQ__QuoteLine__c(SBQQ__Quote__c=objQuote.Id,SBQQ__Product__c=nxHW.Id,SBQQ__Quantity__c=1);
        insert objQuoteL;
        SBQQ__QuoteLine__c objQuoteL2= new SBQQ__QuoteLine__c(SBQQ__Quote__c=objQuote.Id,SBQQ__Product__c=mainSub.Id,SBQQ__Quantity__c=1);
        insert objQuoteL2;
        Contract con= new Contract(AccountId=acc.Id,StartDate=Date.today(),EndDate=Date.today().addYears(1));
        insert con;
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=mainSub.Id,SBQQ__RequiredByProduct__c=mainSub.Id);
        insert sub;
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=nxHW.Id,Status='Customer Owned',SBQQ__CurrentSubscription__c=sub.Id,SBQQ__QuoteLine__c=objQuoteL.Id);
        insert asset1;
        SBQQ__SubscribedAsset__c subAsset= new SBQQ__SubscribedAsset__c();
        subAsset.SBQQ__Asset__c=asset1.Id;
        subAsset.SBQQ__Subscription__c=sub.Id;
        subAsset.SBQQ__Active__c=true;
        insert subAsset;
        PortalViewController_NXVX portal1= new PortalViewController_NXVX();
        System.debug('portal1.lstResults' + portal1.lstResults.size());
        System.assert(portal1.lstResults.size()==1);
        portal1.SearchParameter='NX-1700';
        portal1.IsSearchForActive=true;
        portal1.searchAssets();
        boolean hasNext=portal1.HasNext;
        portal1.next();
        portal1.previous();
        System.debug('portal1.lstResults' + portal1.lstResults.size());
        System.assert(portal1.lstResults.size()==1);
        
    }
    
    @IsTest
    public static void TestViewController_Sort()
    {
        List<PortalDataWrapper> lstData= new List<PortalDataWrapper>();
        PortalDataWrapper portalData1= new PortalDataWrapper();
        portalData1.AccountName='XYZ';
        portalData1.ProductName='EC-PLUS-1Y';
        portalData1.SerialNumber='234243243';
        portalData1.CustomerNotes='test122';
        portalData1.Quantity=10;
        portalData1.LicenseKey='23232';
        portalData1.LicenseEndDate=Date.today().addDays(20);
        portalData1.WarrantyStartDate=Date.today().addDays(20);
        portalData1.WarrantyEndDate=Date.today().addDays(20);
        portalData1.ContractEndDate=Date.today().addDays(20);
        portalData1.ShipDate=Date.today().addDays(20);
        portalData1.EndOfMaintenance=Date.today().addDays(20);
        lstData.add(portalData1);
        PortalDataWrapper portalData2= new PortalDataWrapper();
        portalData2.AccountName='ABC';
        portalData2.ProductName='EC-BASE-1Y';
        portalData2.SerialNumber='001BBC222111';
        portalData2.CustomerNotes='abc';
        portalData2.Quantity=20;
        portalData2.LicenseKey='123333';
        portalData2.LicenseEndDate=Date.today().addDays(21);
        portalData2.WarrantyStartDate=Date.today().addDays(21);
        portalData2.WarrantyEndDate=Date.today().addDays(21);
        portalData2.ContractEndDate=Date.today().addDays(21);
        portalData2.EndOfMaintenance=Date.today().addDays(21);
        portalData2.ShipDate=Date.today().addDays(21);
        lstData.add(portalData2);
        PortalDataWrapper.sortableField='AccountName';
        PortalDataWrapper.sortOrder='asc';
        lstData.sort();
        PortalDataWrapper.sortableField='ProductName';
        PortalDataWrapper.sortOrder='asc';
        lstData.sort();
        PortalDataWrapper.sortableField='ShipDate';
        PortalDataWrapper.sortOrder='asc';
        lstData.sort();
        PortalDataWrapper.sortableField='SerialNumber';
        PortalDataWrapper.sortOrder='asc';
        lstData.sort();
        PortalDataWrapper.sortableField='ContractEndDate';
        PortalDataWrapper.sortOrder='asc';
        lstData.sort();
        PortalDataWrapper.sortableField='LicenseKey';
        PortalDataWrapper.sortOrder='asc';
        lstData.sort();
        PortalDataWrapper.sortableField='WarrantyStartDate';
        PortalDataWrapper.sortOrder='asc';
        lstData.sort();
        PortalDataWrapper.sortableField='WarrantyEndDate';
        PortalDataWrapper.sortOrder='asc';
        lstData.sort();
        PortalDataWrapper.sortableField='EndOfMaintenance';
        PortalDataWrapper.sortOrder='asc';
        lstData.sort();
        PortalDataWrapper.sortableField='LicenseEndDate';
        PortalDataWrapper.sortOrder='asc';
        lstData.sort();
        PortalDataWrapper.sortableField='CustomerNotes';
        PortalDataWrapper.sortOrder='asc';
        lstData.sort();
        PortalDataWrapper.sortableField='Quantity';
        PortalDataWrapper.sortOrder='asc';
        lstData.sort();
        
        PortalDataWrapper.sortableField='AccountName';
        PortalDataWrapper.sortOrder='desc';
        lstData.sort();
        PortalDataWrapper.sortableField='ProductName';
        PortalDataWrapper.sortOrder='desc';
        lstData.sort();
        PortalDataWrapper.sortableField='ShipDate';
        PortalDataWrapper.sortOrder='desc';
        lstData.sort();
        PortalDataWrapper.sortableField='SerialNumber';
        PortalDataWrapper.sortOrder='desc';
        lstData.sort();
        PortalDataWrapper.sortableField='ContractEndDate';
        PortalDataWrapper.sortOrder='desc';
        lstData.sort();
        PortalDataWrapper.sortableField='LicenseKey';
        PortalDataWrapper.sortOrder='desc';
        lstData.sort();
        PortalDataWrapper.sortableField='WarrantyStartDate';
        PortalDataWrapper.sortOrder='desc';
        lstData.sort();
        PortalDataWrapper.sortableField='WarrantyEndDate';
        PortalDataWrapper.sortOrder='desc';
        lstData.sort();
        PortalDataWrapper.sortableField='EndOfMaintenance';
        PortalDataWrapper.sortOrder='desc';
        lstData.sort();
        PortalDataWrapper.sortableField='LicenseEndDate';
        PortalDataWrapper.sortOrder='desc';
        lstData.sort();
        PortalDataWrapper.sortableField='CustomerNotes';
        PortalDataWrapper.sortOrder='desc';
        lstData.sort();
        PortalDataWrapper.sortableField='Quantity';
        PortalDataWrapper.sortOrder='desc';
        lstData.sort();
        
    }
}