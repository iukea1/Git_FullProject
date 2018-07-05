@isTest
private class QuoteExtControllerTests {
    
    testMethod static void testSubmit() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', quote.ApprovalStatus__c);
    }
    testMethod static void testSubmit_HardwareExtension() {
       	Account acc = new Account(Name='Test');
        insert acc;
        Product2 nxProd= new Product2(Name='NX-1700', Family='Product',IsActive=true);
        insert nxProd;
        Opportunity opp= new Opportunity(Name='test opp',AccountId=acc.Id, POC_Opportunity__c=true,StageName='New',CloseDate=Date.today());
        insert opp;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id);
        insert quote;
        SBQQ__QuoteLine__c qla= new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id, SBQQ__Product__c=nxProd.Id);
        insert qla;
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        Boolean messageFound = false;

        for(ApexPages.Message message : ApexPages.getMessages()) {
            System.debug(message.getDetail());
             System.debug(message.getSummary());
            if(message.getSummary().startsWith('The address has not been associated with the hardware products in the quote. Please go to the Quote Address section and add shipping quantities.')
               && message.getSeverity() == ApexPages.Severity.Error) {
                   messageFound = true;        
               }
        }
        System.assert(messageFound);

        Test.stopTest();
        
       
    }
    testMethod static void testRecall() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecall();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Recalled', quote.ApprovalStatus__c);
    }
    testMethod static void testPreview() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onPreview();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals(null, quote.ApprovalStatus__c);
    }
}