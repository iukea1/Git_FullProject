@isTest
public class AssetTriggerHandlerTest {
    @testsetup
    public static void setupTestData() {
        ContractTestClassHelper.createTestProducts();
        ContractTestClassHelper.createTestDataCustomer();
    }
    
    
    public testmethod static void testSoftware() {
        ContractTestClassHelper.load();
        SBQQ__Quote__c quoteRec = ContractTestClassHelper.createQuote('NX/VX', ContractTestClassHelper.opportunities[0].Id, true);
        List<SBQQ__QuoteLIne__c> qlins = ContractTestClassHelper.setQuoteLines(quoteRec.Id, new Map<String, Integer>{
           'VX-1000'=>3,
           'VX-1000'=>3
        });
        
        quoteRec.ApprovalStatus__c = 'Approved'; 
        quoteRec.SBQQ__Status__c = 'Approved';
        update quoteRec;
        Order o = ContractTestClassHelper.createOrder(ContractTestClassHelper.accounts[0].Id, quoteRec.Id, Date.today(), qlins, true);
        
        Test.startTest();
            ContractTestClassHelper.activateOrder(o.Id, ContractTestClassHelper.opportunities[0].Id, ContractTestClassHelper.contacts[0].Id);
            ContractTestClassHelper.contractActivation(quoteRec, o, ContractTestClassHelper.opportunities[0], [SELECT Id, Product2Id, SBQQ__QuoteLine__c, ServiceDate, EndDate, Quantity FROM OrderItem WHERE OrderId = :o.Id]);
        Test.stopTest();
        
    }
    
    public testmethod static void testSoftware2() {
        ContractTestClassHelper.load();
        SBQQ__Quote__c quoteRec = ContractTestClassHelper.createQuote('NX/VX', ContractTestClassHelper.opportunities[0].Id, true);
        List<SBQQ__QuoteLIne__c> qlins = ContractTestClassHelper.setQuoteLines(quoteRec.Id, new Map<String, Integer>{
           'VX-1000'=>3,
           'VX-1000'=>3
        });
        
        quoteRec.ApprovalStatus__c = 'Approved'; 
        quoteRec.SBQQ__Status__c = 'Approved';
        update quoteRec;
        Order o = ContractTestClassHelper.createOrder(ContractTestClassHelper.accounts[0].Id, quoteRec.Id, Date.today().addDays(3), qlins, true);
        
        Test.startTest();
            ContractTestClassHelper.activateOrder(o.Id, ContractTestClassHelper.opportunities[0].Id, ContractTestClassHelper.contacts[0].Id);
            ContractTestClassHelper.contractActivation(quoteRec, o, ContractTestClassHelper.opportunities[0], [SELECT Id, Product2Id, SBQQ__QuoteLine__c, ServiceDate, EndDate, Quantity FROM OrderItem WHERE OrderId = :o.Id]);
        Test.stopTest();
    }
    
    public testmethod static void testEc() {
        ContractTestClassHelper.load();
        SBQQ__Quote__c quoteRec = ContractTestClassHelper.createQuote('EDGECONNECT', ContractTestClassHelper.opportunities[1].Id, true);
        List<SBQQ__QuoteLIne__c> qlins = ContractTestClassHelper.setQuoteLines(quoteRec.Id, new Map<String, Integer>{
           'EC-BASE-PROMO-1MO'=>3,
           'EC-BASE-PROMO-3MO'=>3
        });
        
        quoteRec.ApprovalStatus__c = 'Approved'; 
        quoteRec.SBQQ__Status__c = 'Approved';
        update quoteRec;
        
        Test.startTest();
            OrderTriggerHandler.runRecalc = false;
            Order o = ContractTestClassHelper.createOrder(ContractTestClassHelper.accounts[1].Id, quoteRec.Id, Date.today(), qlins, true);
            ContractTestClassHelper.activateOrderSimple(o.Id, ContractTestClassHelper.opportunities[1].Id, ContractTestClassHelper.contacts[1].Id);
            Contract c = ContractTestClassHelper.contractActivation(quoteRec, o, ContractTestClassHelper.opportunities[1], [SELECT Id, Product2Id, SBQQ__QuoteLine__c, ServiceDate, EndDate, Quantity FROM OrderItem WHERE OrderId = :o.Id]);
            c.Status = 'Expired';
            update c;
        Test.stopTest();
    }
    
    
    public testmethod static void testPOC() {
        ContractTestClassHelper.load();
        SBQQ__Quote__c quoteRec = ContractTestClassHelper.createQuote('NX/VX', ContractTestClassHelper.opportunities[1].Id, true);
        List<SBQQ__QuoteLIne__c> qlins = ContractTestClassHelper.setQuoteLines(quoteRec.Id, new Map<String, Integer>{
           'VX-1000'=>3,
           'VX-1000'=>3
        });
        
        quoteRec.ApprovalStatus__c = 'Approved'; 
        quoteRec.SBQQ__Status__c = 'Approved';
        update quoteRec;
        
        Test.startTest();
            Order o = ContractTestClassHelper.createOrder(ContractTestClassHelper.accounts[1].Id, quoteRec.Id, Date.today(), qlins, true);
            ContractTestClassHelper.activateOrder(o.Id, ContractTestClassHelper.opportunities[1].Id, ContractTestClassHelper.contacts[1].Id);
            ContractTestClassHelper.contractActivation(quoteRec, o, ContractTestClassHelper.opportunities[1], [SELECT Id, Product2Id, SBQQ__QuoteLine__c, ServiceDate, EndDate, Quantity FROM OrderItem WHERE OrderId = :o.Id]);
            quoteRec.POC_Status__c = 'Closed - Denied';
            update quoteRec;
        Test.stopTest();
    }
    
    public testmethod static void testPOCextend() {
        ContractTestClassHelper.load();
        SBQQ__Quote__c quoteRec = ContractTestClassHelper.creatPocQuote('NX/VX', ContractTestClassHelper.opportunities[1].Id);
        List<SBQQ__QuoteLIne__c> qlins = ContractTestClassHelper.setQuoteLines(quoteRec.Id, new Map<String, Integer>{
           'VX-1000'=>3,
           'VX-1000'=>3
        });
        
        quoteRec.ApprovalStatus__c = 'Approved'; 
        quoteRec.SBQQ__Status__c = 'Approved';
        update quoteRec;
        
        Test.startTest();
            Order o = ContractTestClassHelper.createOrder(ContractTestClassHelper.accounts[1].Id, quoteRec.Id, Date.today(), qlins, true);
            ContractTestClassHelper.activateOrder(o.Id, ContractTestClassHelper.opportunities[1].Id, ContractTestClassHelper.contacts[1].Id);
            ContractTestClassHelper.contractActivation(quoteRec, o, ContractTestClassHelper.opportunities[1], [SELECT Id, Product2Id, SBQQ__QuoteLine__c, ServiceDate, EndDate, Quantity FROM OrderItem WHERE OrderId = :o.Id]);
            
            quoteRec.POC_Status__c = 'Shipped - Extended';
            update quoteRec;
        Test.stopTest();
    }
}