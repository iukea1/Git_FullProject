public class ContractTestClassHelper {
    static Map<String, Product2> productMap = new Map<String, Product2>();
    public static void createTestProducts() {
        Test.loadData(Pricebook2.sObjectType, 'test_data_pricebook2');
        Test.loadData(Product2.sObjectType, 'test_data_product2');
        //Test.loadData(PricebookEntry.sObjectType, 'test_data_pricebookentry');
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
            AccountId = aList[1].Id
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
    public static SBQQ__Quote__c createQuote(String productType, Id oppId) { return createQuote(productType, oppId, false); }
    public static SBQQ__Quote__c createQuote(String productType, Id oppId, Boolean runInsert) {
        RecordType recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Standard_Draft_Quote' LIMIT 1];
        SBQQ__Quote__c qItm = new SBQQ__Quote__c(
            Product_Type__c = productType,
            SBQQ__Opportunity2__c = oppId,
            SBQQ__Status__c = 'Draft',
            ApprovalStatus__c = 'Draft',
            SBQQ__PaymentTerms__c = 'Net 30',
            RecordTypeId = recId.Id
        );
        
        if(runInsert) insert qItm;
        return qItm;
    }
    public static List<OrderItem> setQuoteLines(Id quoteId, Map<String, Integer> productItems) {
        if(productMap.isEmpty()) {
            //for([SELECT Id, Name FROM Product2])
        }
        return null;
    }
    
    
    
    
    public static Order createOrder(Id accountId, Id qId, Date orderDate) { return createOrder(accountId, qId, orderDate); }
    public static Order createOrder(Id accountId, Id qId, Date orderDate, Boolean runInsert) {
        Order oItm = new Order(
            AccountId = accountId,
            EffectiveDate = orderDate == null? Date.today() : orderDate,
            Status = 'Draft',
            SBQQ__Quote__c = qId
        );
        if(runInsert) insert oItm;
        return oItm;
    }
    
    
}