@isTest
private class HardwareShipmentControllerTest {
	
	@TestSetup static void whenCreateTestData(){
		Account account = new Account();
		account.Name = 'Test Account';
		insert account;

		Opportunity opportunity = new Opportunity();
		opportunity.Name = 'Test Opportunity';
		opportunity.CloseDate = System.Today();
		opportunity.StageName = 'New';
		opportunity.AccountId = account.Id;
		insert opportunity;

		Order order = new Order();
		order.AccountId = account.Id;
		order.OpportunityId = opportunity.Id;
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		insert order;
	}

	@isTest static void whenTestWithZeroOrderProducts() {
		Order order = [SELECT Id, SBQQ__Quote__c FROM Order LIMIT 1];

		Test.startTest();
			ApexPages.currentPage().getParameters().put('id', order.id);
			ApexPages.StandardController stdOrder = new ApexPages.StandardController(order);
			HardwareShipmentController controller = new HardwareShipmentController(stdOrder);
			controller.rerenderForm();
			controller.returnToOrder();
			OrderShipmentHelper.getAllOrderFieldsAPINames();
		Test.stopTest();
	}

	@isTest static void whenTestWithOrderProducts(){
		Order order = [SELECT Id, SBQQ__Quote__c FROM Order LIMIT 1];

		Product2 product = new Product2();
		product.Name = 'EC-BASE-2Y';
		product.Family = 'Virtual Image';
		product.ProductCode = '300128-002';
		product.Model__c = 'EC-BASE-2Y';
		product.IsActive = true;
		insert product;

        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = product.Id;
        standardPrice.UnitPrice = 1000;
        standardPrice.IsActive = true;
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2();
        customPB.Name = 'Custom Pricebook';
        customPB.isActive = true;
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry();
        customPrice.Pricebook2Id = customPB.Id;
        customPrice.product2Id = product.Id;
        customPrice.UnitPrice = 2000;
        customPrice.IsActive = true; 
        insert customPrice;

        order.Pricebook2Id = customPB.Id;
        update order;

		OrderItem orderProduct = new OrderItem();
		orderProduct.PricebookEntryId = customPrice.Id;
		orderProduct.Product2Id = product.Id;
		orderProduct.Quantity = 1;
		orderProduct.OrderId = order.Id;
		orderProduct.UnitPrice = 1000;
		insert orderProduct;

		Test.startTest();
			ApexPages.currentPage().getParameters().put('id', order.id);
			ApexPages.StandardController stdOrder = new ApexPages.StandardController(order);
			HardwareShipmentController controller = new HardwareShipmentController(stdOrder);

			controller.csvFile.body = Blob.valueOf('300128-002,1111111111,2222222222');
			controller.applyCSVFile();

			controller.checkSerialNumberStatus();
			controller.saveAndShip();

		Test.stopTest();
	}
	

}