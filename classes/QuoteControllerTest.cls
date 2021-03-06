@isTest
public class QuoteControllerTest
{
    @isTest
    static void testEmptyQuote()
    {
        QuoteController controller = new QuoteController();
        controller.search();
        controller.editQuoteLinesPage();
        controller.add();
        controller.quickAddProducts();
        controller.cloneQuoteWithoutProducts();
    }
    
    @isTest(SeeAllData=true)
    static void testQuoteLines()
    {
        //Initial test parameters.
        //create opportunity, product, priceboock, pricebookentry, opportunitylineitem 
        Product2 prod = new product2(name='x', Product_Category__c = 'Subscription', isActive = true, isQuotable__c = true);
        insert prod;
        Product2 prod2 = new product2(name='y', Product_Category__c = 'Subscription', isActive = true, isQuotable__c = true);
        insert prod2;
        Pricebook2 stdPb = [select Id from Pricebook2 where IsStandard=true limit 1];
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod.id, unitprice=1.0, isActive=true);
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod2.id, unitprice=2.0, isActive=true);
        //creates a new pricebook with an entry for this product
        Pricebook2 book = new Pricebook2(name='test');
        insert book;
        PricebookEntry entry = new PricebookEntry(pricebook2id=book.id, product2id=prod.id, unitprice=1.0, isActive=true);
        insert entry;
        insert new PricebookEntry(pricebook2id=book.id, product2id=prod2.id, unitprice=1.0, isActive=true);
             
        //create opportunity and opportunity line item.
        Opportunity oppo = new Opportunity(name='test', pricebook2id=book.id, stageName='Discovery', CloseDate=Date.newInstance(2006,10,10));
        insert oppo;
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=oppo.id, pricebookentryid=entry.id, unitprice=1.5, quantity=2);
        insert oli;
        Quote__c qt = new Quote__c(Opportunity__c = oppo.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today());
        insert qt;     
        
        Test.startTest();
        //test constructor
        QuoteController controller = new QuoteController(new ApexPages.StandardController(qt));
        PageReference refer = new PageReference('/apex/EditQuoteLines');
        Test.setCurrentPage(refer);

        //copy line items from opportunity to quote
        ApexPages.currentPage().getParameters().put('reloadQuote', '1');
        controller.copy();
        System.assert([Select count() from Quote_Line__c where Quote__c = :qt.Id] == 1);
        ApexPages.currentPage().getParameters().remove('reloadQuote');
        
        //reload controller since copy line items from opportunity refreshs the quote's child records.
        controller = new QuoteController(new ApexPages.StandardController(qt));
        System.debug(controller.items.size());
        controller.getProductGroups();
        //search all products
        controller.add();
        controller.searchKeyword = '';
        controller.getFilterValues();
        controller.filterValue = 'all';
        controller.search();  
        System.debug(controller.searchResults);
        System.debug(controller.items.size());
        System.assert(controller.searchResults.size() >= 2);
        
        //search and add products
        controller.add();
        controller.filterValue = 'Subscription';
        controller.search();
        controller.selectedProds = controller.searchResults[0].Id + ';' + controller.searchResults[1].Id + ';' ;
        controller.addProducts();
        controller.getPricebooks();
        controller.add();
        controller.reset();
        
        controller.add();
        controller.filterValue = 'Subscription';
        controller.search();
        controller.selectedProds = controller.searchResults[0].Id + ';' + controller.searchResults[1].Id + ';' ;
        controller.addProducts();
        Quote_Line__c line = controller.items[1].record;
        line.Quantity__c = 2;
        line.Discount_Percent__c = 50;        
        String cf = controller.CurrencyFormat;
        String qd = controller.QuoteDate;
        String vu = controller.validUntil;
        String ta = controller.totalAmount;
        Boolean sa = controller.showVirtualAlternative;
        Quote__c q = controller.getQuote();
        List<QuoteController.LineItem> its = controller.getItems();
        Quote_Line__c line2 = controller.items[2].record;
        line2.Quantity__c = 2;
        line2.Discount_Percent__c = 20; 

        System.assert(controller.items.size() == 3);     
        controller.asyncUpdatePrice();
        
        //delete the first line
        ApexPages.currentPage().getParameters().put('delIndex', '0');
        controller.del();
        //calculate discount by price
        controller.items[1].record.Unit_Price__c = 0.75;
        controller.asyncUpdateProduct();
                       
        controller.save();       
                
        System.assert(controller.items.size() == 2);        
        controller.attachQuote();
        controller.cloneQuoteWithProducts();
                                   
        //copy line items from quote to opportunity
        ApexPages.currentPage().getParameters().put('reloadOppo', '1');
        controller.copy();
        System.assert([Select count() From OpportunityLineItem where OpportunityId = :qt.Opportunity__c] == 2);
        ApexPages.currentPage().getParameters().remove('reloadOppo');       
        System.debug(controller.items.size());
        
        //search different conditions        
        controller.search();        
        System.debug(controller.searchResults);
        controller.filterValue = 'test category 1';
        controller.search();        
        System.debug(controller.searchResults);
        controller.searchKeyword = 'test category*';
        controller.filterValue = 'all';
        controller.search();        
        System.debug(controller.searchResults);
        controller.searchKeyword = 'category*';
        controller.filterValue = 'test category 2';
        controller.search();        
        System.debug(controller.searchResults);
        
        Test.stopTest();
    }
}