@isTest
public class SummaryQuoteLineGroupTest {
    @isTest
    static void testCreateQuoteLine()
    {
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test');
        insert con;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Type__c = 'Renewal', SBQQ__PrimaryContact__c = con.Id, Prepared_For__c = con.Id );
        insert quote;
        
        SBQQ__QuoteLineGroup__c  lineGroup = new SBQQ__QuoteLineGroup__c (Name = 'Test', SBQQ__Quote__c = quote.Id);
        insert lineGroup;
        
        Product2 product = new Product2(Name = 'Test');
        insert product;
        
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        lines.add(TestUtilities.createQuoteLine(quote.Id, lineGroup.Id, product.Id));
        lines.add(TestUtilities.createQuoteLine(quote.Id, lineGroup.Id, product.Id));
		Test.startTest();
        insert lines;
        Test.stopTest();

        lineGroup = [select Id, SBQQ__ListTotal__c, SBQQ__NetTotal__c, SBQQ__CustomerTotal__c from SBQQ__QuoteLineGroup__c where Id = :lineGroup.Id];
System.debug(lineGroup);		
        //System.assert(lineGroup.SBQQ__CustomerTotal__c == 60);
        //System.assert(lineGroup.SBQQ__NetTotal__c == 40);
        //System.assert(lineGroup.SBQQ__ListTotal__c == 0);
    }
    
    @isTest
    static void testUpdateQuoteLine1()
    {
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test');
        insert con;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Type__c = 'Renewal', SBQQ__PrimaryContact__c = con.Id, Prepared_For__c = con.Id );
        insert quote;
        
        SBQQ__QuoteLineGroup__c  lineGroup1 = new SBQQ__QuoteLineGroup__c (Name = 'Test', SBQQ__Quote__c = quote.Id);
        insert lineGroup1;
        
        SBQQ__QuoteLineGroup__c  lineGroup2 = new SBQQ__QuoteLineGroup__c (Name = 'Test', SBQQ__Quote__c = quote.Id);
        insert lineGroup2;
        
        Product2 product = new Product2(Name = 'Test');
        insert product;
        
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c line1 = TestUtilities.createQuoteLine(quote.Id, lineGroup1.Id, product.Id);
        SBQQ__QuoteLine__c line2 = TestUtilities.createQuoteLine(quote.Id, lineGroup1.Id, product.Id);
        lines.add(line1);
        lines.add(line2);
        insert lines;
        
        Test.startTest();
        line1.SBQQ__Group__c = lineGroup2.Id;
        update line1;
        Test.stopTest();

        SBQQ__QuoteLineGroup__c lineGroup = [select Id, SBQQ__ListTotal__c, SBQQ__NetTotal__c, SBQQ__CustomerTotal__c from SBQQ__QuoteLineGroup__c where Id = :lineGroup1.Id];
System.debug(lineGroup);		
        //System.assert(lineGroup.SBQQ__CustomerTotal__c == 30);
        //System.assert(lineGroup.SBQQ__NetTotal__c == 20);
        //System.assert(lineGroup.SBQQ__ListTotal__c == 0);
    }
    
    @isTest
    static void testUpdateQuoteLine2()
    {
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test');
        insert con;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Type__c = 'Renewal', SBQQ__PrimaryContact__c = con.Id, Prepared_For__c = con.Id );
        insert quote;
        
        SBQQ__QuoteLineGroup__c  lineGroup = new SBQQ__QuoteLineGroup__c (Name = 'Test', SBQQ__Quote__c = quote.Id);
        insert lineGroup;
        
        Product2 product = new Product2(Name = 'Test');
        insert product;
        
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c line1 = TestUtilities.createQuoteLine(quote.Id, lineGroup.Id, product.Id);
        SBQQ__QuoteLine__c line2 = TestUtilities.createQuoteLine(quote.Id, lineGroup.Id, product.Id);
        lines.add(line1);
        lines.add(line2);
        insert lines;
        
        Test.startTest();
        line1.SBQQ__NetPrice__c = 50.00;
        update line1;
        Test.stopTest();

        lineGroup = [select Id, SBQQ__ListTotal__c, SBQQ__NetTotal__c, SBQQ__CustomerTotal__c from SBQQ__QuoteLineGroup__c where Id = :lineGroup.Id];
System.debug(lineGroup);		
        //System.assert(lineGroup.SBQQ__CustomerTotal__c == 60);
        //System.assert(lineGroup.SBQQ__NetTotal__c == 70);
        //System.assert(lineGroup.SBQQ__ListTotal__c == 0);
    }
    
    @isTest
    static void testDeleteQuoteLine()
    {
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test');
        insert con;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Type__c = 'Renewal', SBQQ__PrimaryContact__c = con.Id, Prepared_For__c = con.Id );
        insert quote;
        
        SBQQ__QuoteLineGroup__c  lineGroup = new SBQQ__QuoteLineGroup__c (Name = 'Test', SBQQ__Quote__c = quote.Id);
        insert lineGroup;
        
        Product2 product = new Product2(Name = 'Test');
        insert product;
        
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c line1 = TestUtilities.createQuoteLine(quote.Id, lineGroup.Id, product.Id);
        SBQQ__QuoteLine__c line2 = TestUtilities.createQuoteLine(quote.Id, lineGroup.Id, product.Id);
        lines.add(line1);
        lines.add(line2);
        insert lines;
        
        Test.startTest();
        delete line1;
        Test.stopTest();

        lineGroup = [select Id, SBQQ__ListTotal__c, SBQQ__NetTotal__c, SBQQ__CustomerTotal__c from SBQQ__QuoteLineGroup__c where Id = :lineGroup.Id];
System.debug(lineGroup);		
        //System.assert(lineGroup.SBQQ__CustomerTotal__c == 30);
        //System.assert(lineGroup.SBQQ__NetTotal__c == 20);
        //System.assert(lineGroup.SBQQ__ListTotal__c == 0);
    }
}