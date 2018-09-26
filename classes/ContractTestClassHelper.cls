public class ContractTestClassHelper {
    static Map<String, Product2> productMap = new Map<String, Product2>();
    public static void createTestProducts() {
        Test.loadData(Pricebook2.sObjectType, 'test_data_pricebook2');
        Test.loadData(Product2.sObjectType, 'test_data_product2');
        //Test.loadData(PricebookEntry.sObjectType, 'test_data_pricebookentry');
    }
    
    public static List<Account> accounts = new List<Account>();
    public static List<Contact> contacts = new List<Contact>();
    public static List<Opportunity> opportunities = new List<Opportunity>();
    public static Map<String, Product2> productsByName = new Map<String, Product2>();
    public static Map<String, PriceBookEntry> productPbE = new Map<String, PriceBookEntry>();
    private static Boolean isLoaded = false;
    
    public static Map<String, RecordType> rType = new Map<String, RecordType>();
    
    public static void load() {
        if(!isLoaded) {
            accounts = [SELECT Id, Name FROM Account WHERE Name != 'Silver Peak Systems'];
            contacts = [SELECT Id, FirstName, LastName, AccountId FROM Contact];
            opportunities = [SELECT Id, Name, POC_Type__c, POC_Start_Date__c, POC_Opportunity__c, AccountId FROM Opportunity];
            
            //Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE isStandard=true LIMIT 1];
            for(Product2 p : [SELECT Id, Name FROM Product2 LIMIT 3000]) {
                productsByName.put(p.Name, p);
                productPbE.put(p.Id, new PriceBookEntry(
                    Product2Id = p.Id,
                    Pricebook2Id = Test.getStandardPricebookId(),
                    UnitPrice = 100
                ));
            }
            insert productPbE.values();
            for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType]) {
                rType.put(rt.DeveloperName, rt);
            }
            isLoaded = true;
        }
    }
    
    public static void createTestDataCustomer() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer' and sObjectType = 'Account' LIMIT 1];
    
        List<Account> aList = new List<Account>();
        aList.add(new Account(
            Name = 'Account Test Class-1',
            Type = 'Customer',
            Payment_Terms__c = 'Net 30',
            Service_Provider_Type__c = 'Carrier MSP',
            SP_MKTG__c = true,
            SBQQ__RenewalModel__c = 'Contract Based',
            RecordTypeId = rt.Id
        ));
        aList.add(new Account(
            Name = 'Account Test Class-2',
            Type = 'Customer',
            Payment_Terms__c = 'Net 30',
            Service_Provider_Type__c = 'Carrier MSP',
            SP_MKTG__c = true,
            SBQQ__RenewalModel__c = 'Contract Based',
            RecordTypeId = rt.Id
        ));
        aList.add(new Account(
            Name = 'Account Test Class-3',
            Type = 'Customer',
            Payment_Terms__c = 'Net 30',
            Service_Provider_Type__c = 'Carrier MSP',
            SP_MKTG__c = true,
            SBQQ__RenewalModel__c = 'Contract Based',
            RecordTypeId = rt.Id
        ));
        aList.add(new Account(
            Name = 'Silver Peak Systems',
            Type = 'Customer',
            Payment_Terms__c = 'Net 30',
            Service_Provider_Type__c = 'Carrier MSP',
            SP_MKTG__c = true,
            SBQQ__RenewalModel__c = 'Contract Based',
            RecordTypeId = rt.Id
        ));
        insert aList;
        
        List<Contact> cList = new List<Contact>();
        cList.add(new Contact(
            AccountId = aList[0].Id,
            FirstName = 'TestContactFirstName_1',
            LastName = 'TestContactLastName_1',
            Lead_Status__c = 'Converted to New Opportunity',
            LeadSource = 'Sales'
        ));
        cList.add(new Contact(
            AccountId = aList[1].Id,
            FirstName = 'TestContactFirstName_2',
            LastName = 'TestContactLastName_2',
            Lead_Status__c = 'Converted to New Opportunity',
            LeadSource = 'Sales'
        ));
        cList.add(new Contact(
            AccountId = aList[2].Id,
            FirstName = 'TestContactFirstName_3',
            LastName = 'TestContactLastName_3',
            Lead_Status__c = 'Converted to New Opportunity',
            LeadSource = 'Sales'
        ));
        insert cList;
        
        
        List<Opportunity> oList = new List<Opportunity>();
        oList.add(new Opportunity(
            Name = 'TestOpportunity_1',
            Type = 'New Business',
            Deal_Type__c = 'WAN op',
            //SP_PreMQL_Agent_Notes__c = contact.ISR_Notes__c,
            StageName = 'New',
            CloseDate = Date.today().addDays(90),
            Trigger_Assignment__c = true,
            AccountId = aList[0].Id
        ));
        oList.add(new Opportunity(
            Name = 'TestOpportunity_2',
            Type = 'New Business',
            Deal_Type__c = 'WAN op',
            //SP_PreMQL_Agent_Notes__c = contact.ISR_Notes__c,
            StageName = 'New',
            CloseDate = Date.today().addDays(90),
            Trigger_Assignment__c = true,
            AccountId = aList[1].Id,
            POC_Opportunity__c = true
        ));
        oList.add(new Opportunity(
            Name = 'TestOpportunity_3',
            Type = 'New Business',
            Deal_Type__c = 'WAN op',
            //SP_PreMQL_Agent_Notes__c = contact.ISR_Notes__c,
            StageName = 'New',
            CloseDate = Date.today().addDays(90),
            Trigger_Assignment__c = true,
            AccountId = aList[2].Id
        ));
        insert oList;
    }
    
    public static SBQQ__Quote__c creatPocQuote(String productType, Id oppId) {
        SBQQ__Quote__c pocQ = createQuote(productType, oppId);
        pocQ.RecordTypeId = rType.get('POC_Quote').Id;
        pocQ.POC_Status__c = 'Shipped';
        insert pocQ;
        return pocQ;
    }
    public static SBQQ__Quote__c createQuote(String productType, Id oppId) { return createQuote(productType, oppId, false); }
    public static SBQQ__Quote__c createQuote(String productType, Id oppId, Boolean runInsert) {
        RecordType recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Standard_Draft_Quote' LIMIT 1];
        SBQQ__Quote__c qItm = new SBQQ__Quote__c(
            Product_Type__c = productType,
            SBQQ__Opportunity2__c = oppId,
            SBQQ__Status__c = 'Draft',
            ApprovalStatus__c = 'Draft',
            SBQQ__PaymentTerms__c = 'Net 30',
            RecordTypeId = recId.Id,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addYears(1),
            End_Date__c = Date.today().addYears(1),
            SBQQ__ContractingMethod__c = 'By Subscription End Date'
        );
        
        if(runInsert) insert qItm;
        return qItm;
    }
    public static List<SBQQ__QuoteLine__c> setQuoteLines(Id quoteId, Map<String, Integer> productItems) {
        if(productsByName.isEmpty()) {
            load();
        }
        List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c>();
        for(String s : productItems.keyset()) {
            qlines.add(
                new SBQQ__QuoteLine__c(
                    SBQQ__Quote__c = quoteId,
                    SBQQ__Product__c = productsByName.get(s).Id,
                    SBQQ__Quantity__c = productItems.get(s),
                    SBQQ__NetPrice__c = 1000,
                    SBQQ__StartDate__c = Date.today(),
                    SBQQ__EndDate__c = Date.today().addYears(1),
                    End_Date__c = Date.today().addYears(1)
                )
            );
        }
        insert qlines;
        return qlines;
    }
    
    
    
    
    public static Order createOrder(Id accountId, Id qId, Date orderDate, List<SBQQ__QuoteLine__c> qlines) { return createOrder(accountId, qId, orderDate, qlines); }
    public static Order createOrder(Id accountId, Id qId, Date orderDate, List<SBQQ__QuoteLine__c> qlines,  Boolean runInsert) {
        Order ord = new Order(
            AccountId = accountId,
            EffectiveDate = orderDate == null? Date.today() : orderDate,
            Status = 'Draft',
            SBQQ__Quote__c = qId,
            Pricebook2Id = Test.getStandardPricebookId()
        );
        if(runInsert) {
            insert ord;
            List<OrderItem> oitm = new List<OrderItem>();
            for(SBQQ__QuoteLine__c ql : qlines) {
                oitm.add(
                    new OrderItem(
                        OrderId = ord.Id,
                        Product2Id = ql.SBQQ__Product__c,
                        SBQQ__QuotedQuantity__c = ql.SBQQ__Quantity__c,
                        SBQQ__OrderedQuantity__c = ql.SBQQ__Quantity__c,
                        SBQQ__QuoteLine__c = ql.Id,
                        Quantity = 10,
                        PriceBookEntryId = productPbE.get(ql.SBQQ__Product__c).Id,
                        UnitPrice = ql.SBQQ__NetPrice__c,
                        ServiceDate = orderDate == null? ql.SBQQ__StartDate__c : orderDate, //ql.SBQQ__StartDate__c,
                        EndDate = ql.SBQQ__EndDate__c 
                    )
                );
            }
            insert oitm;
        }
        return ord;
    }
    
    public static void activateOrder(Id orderId, Id oppId, Id conId) {
        Purchase_Order__c po = new Purchase_Order__c(
            Order_Date__c = Date.today(),
            Email_Contact__c = conId,
            Opportunity__c = oppId
        );
        insert po;
        Order o = new Order(
            Id = orderId,
            PurchaseOrder__c = po.Id,
            Sales_Order_Number__c = '123',
            SBCF_Shipping_Address__c = 'test',
            SBQQ__ContractingMethod__c = 'By Subscription End Date'
        );
        
        PageReference pr = Page.ActivateOrderOverride;
        pr.getParameters().put('Id', o.Id);
        Test.setCurrentPage(pr);
        
        ActivateOrderController aoc = new ActivateOrderController(new ApexPages.StandardController(o));
        aoc.checkUpdate();
        aoc.returnToOrder();
        aoc.runSerialNumberPage();
        Test.setCurrentPage(pr);
        update o;
        ActivateOrderController aoc2 = new ActivateOrderController(new ApexPages.StandardController(o));
        aoc2.checkUpdate();
        ActivateOrderController aoc3 = new ActivateOrderController(new ApexPages.StandardController(o));
        aoc3.checkUpdate();
    }
    public static void activateOrderSimple(Id orderId, Id oppId, Id conId) {
        Purchase_Order__c po = new Purchase_Order__c(
            Order_Date__c = Date.today(),
            Email_Contact__c = conId,
            Opportunity__c = oppId
        );
        insert po;
        Order o = new Order(
            Id = orderId,
            PurchaseOrder__c = po.Id,
            Sales_Order_Number__c = '123',
            SBCF_Shipping_Address__c = 'test',
            SBQQ__ContractingMethod__c = 'By Subscription End Date',
            Status = 'Activated',
            SBQQ__Contracted__c = true
        );
        update o;
        
    }
    
    public static Contract contractActivation(SBQQ__Quote__c qRec, Order oRec, Opportunity opp, List<OrderItem> oitem) {
        //CheckRecursive.runOnce = false;
        Contract cr = new Contract(
            SBQQ__Opportunity__c = opp.Id,
            Status = 'Draft',
            AccountId = opp.AccountId,
            StartDate = qRec.SBQQ__StartDate__c,
            EndDate = qRec.SBQQ__EndDate__c,
            ContractTerm = 12,
            SBQQ__Quote__c = qRec.Id,
            SBQQ__Order__c = oRec.Id
        );
        insert cr;
        
        
        List<Asset> alist = new List<Asset>();
        List<SBQQ__Subscription__c> sublist = new List<SBQQ__Subscription__c>();
        for(OrderItem oi : oitem) {
            sublist.add(new SBQQ__Subscription__c(
                SBQQ__Product__c = oi.Product2Id,
                SBQQ__QuoteLine__c = oi.SBQQ__QuoteLine__c,
                SBQQ__OrderProduct__c = oi.Id,
                SBQQ__SubscriptionStartDate__c = oi.ServiceDate,
                SBQQ__SubscriptionEndDate__c= oi.EndDate,
                SBQQ__Contract__c = cr.Id,
                SBQQ__Account__c = opp.AccountId,
                SBQQ__Quantity__c = oi.Quantity
            ));
            alist.add(new Asset(
                Name=oi.Product2Id,
                Product2Id = oi.Product2Id,
                AccountId = opp.AccountId,
                SBQQ__QuoteLine__c = oi.SBQQ__QuoteLine__c,
                SBQQ__OrderProduct__c = oi.Id
            ));
        }
        insert sublist;
        insert alist;
        List<SBQQ__SubscribedAsset__c> salist = new List<SBQQ__SubscribedAsset__c>();
        for(Integer x = 0; x < sublist.size(); x+= 1) {
            salist.add(new SBQQ__SubscribedAsset__c(
                SBQQ__Subscription__c = sublist[x].Id,
                SBQQ__Asset__c = alist[x].Id,
                SBQQ__Active__c = true
            ));
        }
        insert salist;
        return cr;
    }
    
}