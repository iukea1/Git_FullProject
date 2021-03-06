@IsTest
public class TestRMAItemTriggerHandler {
    @isTest
    static void testChangeRMAItemProductAndUpdateRMAStatus()
    {
        List<Product2> prods = new List<Product2> { 
            new Product2(Name='acme1', ProductCode='pcode1'),
                new Product2(Name='acme2') };
                    insert prods;
        Product2 prod = new Product2(Name='acme', ProductCode='pcode', RMA_Alternate_1__c=prods[0].Id, RMA_Alternate_2__c=prods[1].Id,Product_Category__c='Appliance');
        insert prod;
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Account spAccount= new Account(Name='Silver Peak Systems');
        insert spAccount;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        insert con;
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00, Status='Conditional PO', Product2Id=prod.Id, AccountId=acc.Id, ContactId=con.Id);
        insert asset;
        RMA__c rma = new RMA__c(Status__c='Initiated', Account__c=acc.Id);
        insert rma;
        RMA_Item__c item = new RMA_Item__c(RMA__c=rma.Id, Product2__c=prod.Id, Asset__c=asset.Id, Ship_To_Contact__c=con.Id, Ship_to_address__c='acme', Contact_Phone__c='12345678', Contact_Email__c='acme@acme.com');
        insert item;
        rma.Note_Loc_1__c = 'Part Number Not Active';
        rma.Status__c = 'Dispatch Rejected';
        update rma;
        rma.Note_Loc_1__c = 'Part Number Not Active';
        rma.Status__c = 'Dispatch Rejected';
        update rma;
    }
    
    @isTest
    static void testChangeRMAItemProduct()
    {
        Account spAccount= new Account(Name='Silver Peak Systems');
        insert spAccount;
        Product2 productA = new Product2(Name='A', ProductCode='A', IsActive=true,Product_Category__c='Appliance');
        Product2 productB = new Product2(Name='B', ProductCode='B', IsActive=true,Product_Category__c='Appliance');
        Product2 productC = new Product2(Name='C', ProductCode='C', IsActive=true,Product_Category__c='Appliance');
        Product2 productD = new Product2(Name='D', ProductCode='D', IsActive=true,Product_Category__c='Appliance');
        Product2 productE = new Product2(Name='E', ProductCode='E', IsActive=true,Product_Category__c='Appliance');
        Product2 productF = new Product2(Name='F', ProductCode='F', IsActive=true,Product_Category__c='Appliance');
        Product2 productG = new Product2(Name='G', ProductCode='G', IsActive=true,Product_Category__c='Appliance');
        Product2 productH = new Product2(Name='H', ProductCode='H', IsActive=true,Product_Category__c='Appliance');
        List<Product2> products = new List<Product2> { productA, productB, productC, productD, productE, productF, productG, productH };
            insert products;
        //productA.ReplaceableHDD__c = productB.Id;
        productB.RMA_Primary_Replacement__c = productC.Id;
        productB.RMA_Alternate_1__c = productD.Id;
        productB.RMA_Alternate_2__c = productE.Id;
        productA.RMA_Primary_Replacement__c = productF.Id;
        productA.RMA_Alternate_1__c = productG.Id;
        productA.RMA_Alternate_2__c = productH.Id;
        update products;
        
        //replaccement path should be C->D->E
        
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        Asset assetX = new Asset(Name='acme', AccountId=acc.Id, ContactId=ct.Id, Product2Id=productA.Id);
        insert assetX;
        
        RMA__c rma = new RMA__c(Type__c='Return for Repair');
        insert rma;
        RMA_Item__c item = new RMA_Item__c(RMA__c=rma.Id, Type__c='Return - Repair and Return', Asset__c=assetX.Id, Product2__c=productC.Id, AltProdPreviouslyOrdered__c=productB.Id);
        insert item;
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('D', item.Product2__r.Name);
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('E', item.Product2__r.Name);
    }
    
    @isTest
    static void testChangeRMAItemProduct2()
    {
        Account spAccount= new Account(Name='Silver Peak Systems');
        insert spAccount;
        Product2 productA = new Product2(Name='A', ProductCode='A', IsActive=true,Product_Category__c='Appliance');
        Product2 productB = new Product2(Name='B', ProductCode='B', IsActive=true,Product_Category__c='Appliance');
        Product2 productC = new Product2(Name='C', ProductCode='C', IsActive=true,Product_Category__c='Appliance');
        Product2 productD = new Product2(Name='D', ProductCode='D', IsActive=true,Product_Category__c='Appliance');
        Product2 productE = new Product2(Name='E', ProductCode='E', IsActive=true,Product_Category__c='Appliance');
        Product2 productF = new Product2(Name='F', ProductCode='F', IsActive=true,Product_Category__c='Appliance');
        Product2 productG = new Product2(Name='G', ProductCode='G', IsActive=true,Product_Category__c='Appliance');
        Product2 productH = new Product2(Name='H', ProductCode='H', IsActive=true,Product_Category__c='Appliance');
        List<Product2> products = new List<Product2> { productA, productB, productC, productD, productE, productF, productG, productH };
            insert products;
        //productA.ReplaceableHDD__c = productB.Id;
        productB.Family = 'Accessory';
        productB.Use_System_Alternative__c = true;
        productB.RMA_Primary_Replacement__c = null;
        productB.RMA_Alternate_1__c = productD.Id;
        productB.RMA_Alternate_2__c = productE.Id;
        productA.RMA_Primary_Replacement__c = productF.Id;
        productA.RMA_Alternate_1__c = productG.Id;
        productA.RMA_Alternate_2__c = productH.Id;
        update products;
        
        //replaccement path should be B->F->G->H
        
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        Asset assetX = new Asset(Name='acme', AccountId=acc.Id, ContactId=ct.Id, Product2Id=productA.Id);
        insert assetX;
        
        RMA__c rma = new RMA__c(Type__c='Return for Repair');
        insert rma;
        RMA_Item__c item = new RMA_Item__c(RMA__c=rma.Id, Type__c='Return - Repair and Return', Asset__c=assetX.Id, Product2__c=productB.Id);
        insert item;
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('F', item.Product2__r.Name);
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('G', item.Product2__r.Name);
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('H', item.Product2__r.Name);
    }
    
    @isTest
    static void testChangeRMAItemProduct3()
    {
        Account spAccount= new Account(Name='Silver Peak Systems');
        insert spAccount;
        Product2 productA = new Product2(Name='A', ProductCode='A', IsActive=true,Product_Category__c='Appliance');
        Product2 productB = new Product2(Name='B', ProductCode='B', IsActive=true,Product_Category__c='Appliance');
        Product2 productC = new Product2(Name='C', ProductCode='C', IsActive=true,Product_Category__c='Appliance');
        Product2 productD = new Product2(Name='D', ProductCode='D', IsActive=true,Product_Category__c='Appliance');
        Product2 productE = new Product2(Name='E', ProductCode='E', IsActive=true,Product_Category__c='Appliance');
        Product2 productF = new Product2(Name='F', ProductCode='F', IsActive=true,Product_Category__c='Appliance');
        Product2 productG = new Product2(Name='G', ProductCode='G', IsActive=true,Product_Category__c='Appliance');
        Product2 productH = new Product2(Name='H', ProductCode='H', IsActive=true,Product_Category__c='Appliance');
        List<Product2> products = new List<Product2> { productA, productB, productC, productD, productE, productF, productG, productH };
            insert products;
        //productA.ReplaceableHDD__c = productB.Id;
        productB.Family = 'Accessory';
        productB.Use_System_Alternative__c = true;
        productB.RMA_Primary_Replacement__c = productC.Id;
        productB.RMA_Alternate_1__c = productD.Id;
        productB.RMA_Alternate_2__c = productE.Id;
        productA.RMA_Primary_Replacement__c = null;
        productA.RMA_Alternate_1__c = productG.Id;
        productA.RMA_Alternate_2__c = productH.Id;
        update products;
        
        //replaccement path should be C->A->G->H
        
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        Asset assetX = new Asset(Name='acme', AccountId=acc.Id, ContactId=ct.Id, Product2Id=productA.Id);
        insert assetX;
        
        RMA__c rma = new RMA__c(Type__c='Return for Repair');
        insert rma;
        RMA_Item__c item = new RMA_Item__c(RMA__c=rma.Id, Type__c='Return - Repair and Return', Asset__c=assetX.Id, Product2__c=productC.Id, AltProdPreviouslyOrdered__c=productB.Id);
        insert item;
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('A', item.Product2__r.Name);
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('G', item.Product2__r.Name);
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('H', item.Product2__r.Name);
    }
    @isTest
    static void testAfterRMAItemReceived()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 nxSub= new Product2(Name='NX-1700 Sub',IsActive=true,Model__c='NX-1700 MAINT CONTRACT',Product_Category__c='Subscription',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert nxSub;
        Product2 nxProd= new Product2(Name='NX-1700',IsActive=true,Model__c='NX-1700',Product_Category__c='Appliance',Family='Product', PRoduct_Type__c='NX/VX');
        insert nxProd;
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=nxProd.Id,Status='Customer Owned');
        insert asset1;
        Contract con= new Contract(AccountId=acc.Id);
        insert con;
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=nxSub.Id);
        insert sub;
        
        asset1.SBQQ__CurrentSubscription__c=sub.Id;
        update asset1;
        
        SBQQ__SubscribedAsset__c sub1 = new SBQQ__SubscribedAsset__c(SBQQ__Subscription__c=sub.Id,SBQQ__Asset__c=asset1.Id,SBQQ__Active__c=true);
        insert sub1;
        
        
        RMA__c testRMA = TestUtilities.createTestRMA(acc.Id, null, null);
        RMA_Item__c testRMAItem = TestUtilities.createTestRMAItem(testRma.Id, asset1.Id, nxProd.Id);
        
        testRMAItem.Status__c = 'Received';
        update testRMAItem;
        
        Asset testAsset = [select AccountId, Status from Asset where Id = :asset1.Id];
        system.assertEquals('Silver Peak Inventory', testAsset.Status);
        
        SBQQ__SubscribedAsset__c subAsset=[Select Id,SBQQ__Active__c from SBQQ__SubscribedAsset__c where SBQQ__Subscription__c=:sub.Id];
        system.assert(subAsset.SBQQ__Active__c==false);
    }
}