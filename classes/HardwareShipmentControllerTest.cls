@isTest
private class HardwareShipmentControllerTest {
	
	@TestSetup static void whenCreateTestData(){
		Account spAccount = new Account();
		spAccount.Name = 'Silver Peak Systems';
		insert spAccount;

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
		Order order = [SELECT Id, SBQQ__Quote__c, Status FROM Order LIMIT 1];

		Test.startTest();
			ApexPages.currentPage().getParameters().put('id', order.id);
			ApexPages.StandardController stdOrder = new ApexPages.StandardController(order);
			HardwareShipmentController controller = new HardwareShipmentController(stdOrder);
			controller.rerenderForm();
			controller.returnToOrder();
			Boolean testBoolean = controller.displayErrorOnly;
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
		product.Forecast_Category__c = 'Physical';
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
        order.Sales_Order_Number__c = 'SO034507';
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

			controller.csvFile.body = Blob.valueOf('No.,SHO,Customer Name,Req#,Request Type,OEM CUST Name,Item#,S/N,LOCID,Location Type,Qty,Shipped Date,Ship Method,Tracking#,Ref PO#,RMA#,RMA Received Date,Contact,Phone Number,Address 1,Address 2,Address 3,City,State/Province,Zip/Postal Code,Country,1,CSHO-99999999,SILVERPEAK,SO034507,SP-SOLD,Blood Systems,300128-002_500190-001,001BBC199D5A,SP-SHIPD-SOLD,VIRTUALPOOL,1,2/13/2018,Test Line,"425428745952, 425428745963, 425428745974, 425428745985, 425428745996, 425428746000, ",PO999999,,,Drew Justus,Test,Test,Test,,Test,n.a,99999,USA');
			controller.applyCSVFile();

			controller.checkSerialNumberStatus();
			controller.copySerialNumberOrderProductId = orderProduct.Id;
			controller.updateCopySerialNumberView();

			controller.csvFile.body = null;
			controller.applyCSVFile();

			controller.save();

		Test.stopTest();
	}

	@isTest static void whenTestWithExistingOrderProductItems(){
		Order order = [SELECT Id, SBQQ__Quote__c FROM Order LIMIT 1];

		Product2 product = new Product2();
		product.Name = 'EC-BASE-2Y';
		product.Family = 'Virtual Image';
		product.ProductCode = '300128-002';
		product.Model__c = 'EC-BASE-2Y';
		product.IsActive = true;
		product.Forecast_Category__c = 'Physical';
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
        order.Sales_Order_Number__c = 'SO034507';
        update order;

		OrderItem orderProduct = new OrderItem();
		orderProduct.PricebookEntryId = customPrice.Id;
		orderProduct.Product2Id = product.Id;
		orderProduct.Quantity = 1;
		orderProduct.OrderId = order.Id;
		orderProduct.UnitPrice = 1000;
		insert orderProduct;

		Order_Product_Item__c testOrderProductItem = new Order_Product_Item__c();
		testOrderProductItem.Order_Product__c = orderProduct.Id;
		testOrderProductItem.Serial_Number__c = 'testSN';
		testOrderProductItem.Part_Number__c = 'test PN';
		testOrderProductItem.Status__c = 'Customer Owned';
		insert testOrderProductItem;

		Test.startTest();
			ApexPages.currentPage().getParameters().put('id', order.id);
			ApexPages.StandardController stdOrder = new ApexPages.StandardController(order);
			HardwareShipmentController controller = new HardwareShipmentController(stdOrder);

			controller.csvFile.body = Blob.valueOf('No.,SHO,Customer Name,Req#,Request Type,OEM CUST Name,Item#,S/N,LOCID,Location Type,Qty,Shipped Date,Ship Method,Tracking#,Ref PO#,RMA#,RMA Received Date,Contact,Phone Number,Address 1,Address 2,Address 3,City,State/Province,Zip/Postal Code,Country,1,CSHO-99999999,SILVERPEAK,SO034507,SP-SOLD,Blood Systems,300128-002_500190-001,001BBC199D5A,SP-SHIPD-SOLD,VIRTUALPOOL,1,2/13/2018,Test Line,"425428745952, 425428745963, 425428745974, 425428745985, 425428745996, 425428746000, ",PO999999,,,Drew Justus,Test,Test,Test,,Test,n.a,99999,USA');
			controller.applyCSVFile();

			controller.checkSerialNumberStatus();
			controller.copySerialNumberOrderProductId = orderProduct.Id;
			controller.updateCopySerialNumberView();

			controller.save();

			//controller = new HardwareShipmentController(stdOrder);

			// When test OrderShipmentHelper component

			//List<Order_Product_Item__c> existingOrderProductItems = new List<Order_Product_Item__c>();
			
			//Order_Product_Item__c testOrderProductItem = new Order_Product_Item__c();
			//testOrderProductItem.Order_Product__c = orderProduct.Id;
			//testOrderProductItem.Serial_Number__c = 'testSN';
			//insert testOrderProductItem;

			//existingOrderProductItems.add(testOrderProductItem);

			//OrderShipmentHelper.buildOrderProductItemWrappersFromExistingOrderProductItems(existingOrderProductItems);

		Test.stopTest();
	}

	@isTest static void whenTestWithExistingAsset(){
		Order order = [SELECT Id, SBQQ__Quote__c FROM Order LIMIT 1];
		Account account = [SELECT Id FROM Account LIMIT 1];

		Product2 product = new Product2();
		product.Name = 'EC-BASE-2Y';
		product.Family = 'Virtual Image';
		product.ProductCode = '300128-002';
		product.Model__c = 'EC-BASE-2Y';
		product.IsActive = true;
		product.Forecast_Category__c = 'Physical';
		insert product;

		Asset asset = new Asset();
		asset.Name = 'Test HW Product';
		asset.AccountId = account.Id;
		asset.Product2Id = product.Id;
		asset.Quantity = 1;
		asset.SerialNumber = '001BBC199D5A';
		insert asset;

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
        order.Sales_Order_Number__c = 'SO034507';
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

			controller.csvFile.body = Blob.valueOf('No.,SHO,Customer Name,Req#,Request Type,OEM CUST Name,Item#,S/N,LOCID,Location Type,Qty,Shipped Date,Ship Method,Tracking#,Ref PO#,RMA#,RMA Received Date,Contact,Phone Number,Address 1,Address 2,Address 3,City,State/Province,Zip/Postal Code,Country,1,CSHO-99999999,SILVERPEAK,SO034507,SP-SOLD,Blood Systems,300128-002_500190-001,001BBC199D5A,SP-SHIPD-SOLD,VIRTUALPOOL,1,2/13/2018,Test Line,"425428745952, 425428745963, 425428745974, 425428745985, 425428745996, 425428746000, ",PO999999,,,Drew Justus,Test,Test,Test,,Test,n.a,99999,USA');
			controller.applyCSVFile();

			controller.checkSerialNumberStatus();
			controller.copySerialNumberOrderProductId = orderProduct.Id;
			controller.updateCopySerialNumberView();

			controller.csvFile.body = null;
			controller.applyCSVFile();

			controller.save();

		Test.stopTest();
	}

	@isTest static void whenTestCSVItemsDontMatchNumberOfOrderProducts(){
		Order order = [SELECT Id, SBQQ__Quote__c FROM Order LIMIT 1];

		Product2 product = new Product2();
		product.Name = 'EC-BASE-2Y';
		product.Family = 'Virtual Image';
		product.ProductCode = '300128-002';
		product.Model__c = 'EC-BASE-2Y';
		product.IsActive = true;
		product.Forecast_Category__c = 'Physical';
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
        order.Sales_Order_Number__c = 'SO034507';
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

			// No matching products
			controller.csvFile.body = Blob.valueOf('No.,SHO,Customer Name,Req#,Request Type,OEM CUST Name,Item#,S/N,LOCID,Location Type,Qty,Shipped Date,Ship Method,Tracking#,Ref PO#,RMA#,RMA Received Date,Contact,Phone Number,Address 1,Address 2,Address 3,City,State/Province,Zip/Postal Code,Country');
			controller.applyCSVFile();

			System.debug('Two matching products');

			// Two matching products
			controller.csvFile.body = Blob.valueOf('No.,SHO,Customer Name,Req#,Request Type,OEM CUST Name,Item#,S/N,LOCID,Location Type,Qty,Shipped Date,Ship Method,Tracking#,Ref PO#,RMA#,RMA Received Date,Contact,Phone Number,Address 1,Address 2,Address 3,City,State/Province,Zip/Postal Code,Country,1,CSHO-99999999,SILVERPEAK,SO034507,SP-SOLD,Blood Systems,300128-002_500190-001,001BBC199D5A,SP-SHIPD-SOLD,VIRTUALPOOL,1,2/13/2018,Test Line,"425428745952, 425428745963, 425428745974, 425428745985, 425428745996, 425428746000, ",PO999999,,,Drew Justus,Test,Test,Test,,Test,n.a,99999,USA,1,CSHO-99999999,SILVERPEAK,SO034507,SP-SOLD,Blood Systems,300128-002_500190-001,001BBC199D5A,SP-SHIPD-SOLD,VIRTUALPOOL,1,2/13/2018,Test Line,"425428745952, 425428745963, 425428745974, 425428745985, 425428745996, 425428746000, ",PO999999,,,Drew Justus,Test,Test,Test,,Test,n.a,99999,USA');
			controller.applyCSVFile();

		Test.stopTest();
	}

	@isTest static void whenTestCSVItemsDontMatchNumberOfOrderProducts2(){
		Order order = [SELECT Id, SBQQ__Quote__c FROM Order LIMIT 1];

		Product2 product = new Product2();
		product.Name = 'EC-BASE-2Y';
		product.Family = 'Virtual Image';
		product.ProductCode = '300128-002';
		product.Model__c = 'EC-BASE-2Y';
		product.IsActive = true;
		product.Forecast_Category__c = 'Physical';
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
        order.Sales_Order_Number__c = 'SO034507';
        update order;

		OrderItem orderProduct = new OrderItem();
		orderProduct.PricebookEntryId = customPrice.Id;
		orderProduct.Product2Id = product.Id;
		orderProduct.Quantity = 2;
		orderProduct.OrderId = order.Id;
		orderProduct.UnitPrice = 1000;
		insert orderProduct;

		Test.startTest();
			ApexPages.currentPage().getParameters().put('id', order.id);
			ApexPages.StandardController stdOrder = new ApexPages.StandardController(order);
			HardwareShipmentController controller = new HardwareShipmentController(stdOrder);

			// 1 matching product in file, product quantity 2 on order.
			controller.csvFile.body = Blob.valueOf('No.,SHO,Customer Name,Req#,Request Type,OEM CUST Name,Item#,S/N,LOCID,Location Type,Qty,Shipped Date,Ship Method,Tracking#,Ref PO#,RMA#,RMA Received Date,Contact,Phone Number,Address 1,Address 2,Address 3,City,State/Province,Zip/Postal Code,Country,1,CSHO-99999999,SILVERPEAK,SO034507,SP-SOLD,Blood Systems,300128-002_500190-001,001BBC199D5A,SP-SHIPD-SOLD,VIRTUALPOOL,1,2/13/2018,Test Line,"425428745952, 425428745963, 425428745974, 425428745985, 425428745996, 425428746000, ",PO999999,,,Drew Justus,Test,Test,Test,,Test,n.a,99999,USA');
			controller.applyCSVFile();

		Test.stopTest();
	}

}