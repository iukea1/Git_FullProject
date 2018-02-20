@isTest
private class SubscriptionTriggerTest {
	
	@TestSetup static void whenCreateTestData(){
		Account account = new Account();
		account.Name = 'Test Account';
		insert account;

		Account spAccount = new Account();
		spAccount.Name = 'Silver Peak Systems';
		insert spAccount;

		Opportunity opportunity = new Opportunity();
		opportunity.Name = 'Test Opportunity';
		opportunity.CloseDate = System.Today();
		opportunity.StageName = 'New';
		opportunity.AccountId = account.Id;
		insert opportunity;

		SBQQ__Quote__c quote = new SBQQ__Quote__c();
		quote.SBQQ__Opportunity2__c = opportunity.Id;
		insert quote;

		//Test.getStandardPricebookId()

		Product2 product = new Product2();
		product.Name = 'Test HW Product';
		product.ProductCode = '123456';
		product.SBQQ__AssetConversion__c = 'One per quote line';
		product.Family = 'Product';
		product.isQuotable__c = true;
		insert product;

		SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
		quoteLine.SBQQ__Quote__c = quote.Id;
		quoteLine.SBQQ__Product__c = product.Id;
		quoteLine.SBQQ__Quantity__c = 1;
		insert quoteLine;
		
	}

	@isTest static void whenTestInsertSubscriptionWithRelatedAsset() {
		SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
		Opportunity opportunity = [Select Id, Name FROM Opportunity Where Name = 'Test Opportunity' Limit 1];
		Account account = [SELECT Id, Name FROM Account Where Name = 'Test Account' LIMIT 1];
		Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Test HW Product'];
		SBQQ__QuoteLine__c hwQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Product__c = :product.Id LIMIT 1];

		Product2 subscriptionProduct = new Product2();
		subscriptionProduct.Name = 'Test Subscription Product';
		subscriptionProduct.ProductCode = '654321';
		subscriptionProduct.isQuotable__c = true;
		subscriptionProduct.Family = 'Service';
		subscriptionProduct.Product_Category__c = 'Maintenance-1 Year';
		insert SubscriptionProduct;

		Order order = new Order();
		order.AccountId = account.Id;
		order.OpportunityId = opportunity.Id;
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		order.Pricebook2Id = Test.getStandardPricebookId();
		insert order;

		Test.startTest();

			SBQQ__QuoteLine__c subscriptionQuoteLine = new SBQQ__QuoteLine__c();
			subscriptionQuoteLine.SBQQ__Quote__c = quote.Id;
			subscriptionQuoteLine.SBQQ__Product__c = subscriptionProduct.Id;
			subscriptionQuoteLine.SBQQ__Quantity__c = 1;
			subscriptionQuoteLine.SBQQ__RequiredBy__c = hwQuoteLine.Id;
			insert subscriptionQuoteLine;
 
			Id pricebookId = Test.getStandardPricebookId();
        
	        // 1. Insert a price book entry for the standard price book.
	        // Standard price book entries require the standard price book ID we got earlier.
	        PricebookEntry standardPriceHWProduct = new PricebookEntry();
	        standardPriceHWProduct.Pricebook2Id = pricebookId;
	        standardPriceHWProduct.Product2Id = product.Id;
	        standardPriceHWProduct.UnitPrice = 1000;
	        standardPriceHWProduct.IsActive = true;
	        insert standardPriceHWProduct;

			OrderItem orderProduct = new OrderItem();
			orderProduct.PricebookEntryId = standardPriceHWProduct.Id;
			orderProduct.Product2Id = product.Id;
			orderProduct.Quantity = 1;
			orderProduct.OrderId = order.Id;
			orderProduct.UnitPrice = 1000;
			insert orderProduct;

			PricebookEntry standardPriceSubscriptionProduct = new PricebookEntry();
	        standardPriceSubscriptionProduct.Pricebook2Id = pricebookId;
	        standardPriceSubscriptionProduct.Product2Id = subscriptionProduct.Id;
	        standardPriceSubscriptionProduct.UnitPrice = 1000;
	        standardPriceSubscriptionProduct.IsActive = true;
	        insert standardPriceSubscriptionProduct;
			
			OrderItem orderProduct2 = new OrderItem();
			orderProduct2.PricebookEntryId = standardPriceSubscriptionProduct.Id;
			orderProduct2.Product2Id = subscriptionProduct.Id;
			orderProduct2.Quantity = 1;
			orderProduct2.OrderId = order.Id;
			orderProduct2.UnitPrice = 1000;
			insert orderProduct2;
			
			order.Status = 'Activated';
			order.SBQQ__Contracted__c = true;
			order.SBQQ__PriceCalcStatus__c = 'Completed';
			update order;

			Asset asset = new Asset();
			asset.Name = 'Test HW Product';
			asset.AccountId = account.Id;
			asset.Product2Id = product.Id;
			asset.Quantity = 1;
			asset.SBQQ__QuoteLine__c = hwQuoteLine.Id;
			insert asset;

			SBQQ__Subscription__c subscription = new SBQQ__Subscription__c();
			subscription.SBQQ__Quantity__c = 1;
			subscription.SBQQ__Product__c = subscriptionProduct.Id;
			subscription.SBQQ__Account__c = account.Id;
			subscription.SBQQ__QuoteLine__c = subscriptionQuoteLine.Id;
			insert subscription;

		Test.stopTest();

		List<Asset> assets = [SELECT Id, Name, Smart_Hands_Subscription__c, SBCF_Subscription__c FROM Asset];
		List<SBQQ__Subscription__c> subscriptions = [SELECT Id, Name FROM SBQQ__Subscription__c];

		System.assertEquals(1, assets.size(), 'One Asset should exist.');
		System.assertEquals(1, subscriptions.size(), 'One Subscription should exist.');

		System.assertEquals(subscriptions[0].Id, assets[0].SBCF_Subscription__c, 'Asset subscription lookup should be subscription.');
		System.assertEquals(null, assets[0].Smart_Hands_Subscription__c, 'Asset smart hands subscription should be null.');
	}

	@isTest static void whenTestInsertSmartHandsSubscriptionWithRelatedAsset() {
		SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
		Opportunity opportunity = [Select Id, Name FROM Opportunity Where Name = 'Test Opportunity' Limit 1];
		Account account = [SELECT Id, Name FROM Account Where Name = 'Test Account' LIMIT 1];
		Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Test HW Product'];
		SBQQ__QuoteLine__c hwQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Product__c = :product.Id LIMIT 1];

		Product2 subscriptionProduct = new Product2();
		subscriptionProduct.Name = 'SMRT-HNDTest Subscription Product';
		subscriptionProduct.ProductCode = '654321';
		subscriptionProduct.isQuotable__c = true;
		subscriptionProduct.Family = 'Service';
		subscriptionProduct.Product_Category__c = 'Maintenance-1 Year';
		insert SubscriptionProduct;

		Order order = new Order();
		order.AccountId = account.Id;
		order.OpportunityId = opportunity.Id;
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		order.Pricebook2Id = Test.getStandardPricebookId();
		insert order;

		Test.startTest();

			SBQQ__QuoteLine__c subscriptionQuoteLine = new SBQQ__QuoteLine__c();
			subscriptionQuoteLine.SBQQ__Quote__c = quote.Id;
			subscriptionQuoteLine.SBQQ__Product__c = subscriptionProduct.Id;
			subscriptionQuoteLine.SBQQ__Quantity__c = 1;
			subscriptionQuoteLine.SBQQ__RequiredBy__c = hwQuoteLine.Id;
			insert subscriptionQuoteLine;
 
			Id pricebookId = Test.getStandardPricebookId();
        
	        // 1. Insert a price book entry for the standard price book.
	        // Standard price book entries require the standard price book ID we got earlier.
	        PricebookEntry standardPriceHWProduct = new PricebookEntry();
	        standardPriceHWProduct.Pricebook2Id = pricebookId;
	        standardPriceHWProduct.Product2Id = product.Id;
	        standardPriceHWProduct.UnitPrice = 1000;
	        standardPriceHWProduct.IsActive = true;
	        insert standardPriceHWProduct;

			OrderItem orderProduct = new OrderItem();
			orderProduct.PricebookEntryId = standardPriceHWProduct.Id;
			orderProduct.Product2Id = product.Id;
			orderProduct.Quantity = 1;
			orderProduct.OrderId = order.Id;
			orderProduct.UnitPrice = 1000;
			insert orderProduct;

			PricebookEntry standardPriceSubscriptionProduct = new PricebookEntry();
	        standardPriceSubscriptionProduct.Pricebook2Id = pricebookId;
	        standardPriceSubscriptionProduct.Product2Id = subscriptionProduct.Id;
	        standardPriceSubscriptionProduct.UnitPrice = 1000;
	        standardPriceSubscriptionProduct.IsActive = true;
	        insert standardPriceSubscriptionProduct;
			
			OrderItem orderProduct2 = new OrderItem();
			orderProduct2.PricebookEntryId = standardPriceSubscriptionProduct.Id;
			orderProduct2.Product2Id = subscriptionProduct.Id;
			orderProduct2.Quantity = 1;
			orderProduct2.OrderId = order.Id;
			orderProduct2.UnitPrice = 1000;
			insert orderProduct2;
			
			order.Status = 'Activated';
			order.SBQQ__Contracted__c = true;
			order.SBQQ__PriceCalcStatus__c = 'Completed';
			update order;

			Asset asset = new Asset();
			asset.Name = 'Test HW Product';
			asset.AccountId = account.Id;
			asset.Product2Id = product.Id;
			asset.Quantity = 1;
			asset.SBQQ__QuoteLine__c = hwQuoteLine.Id;
			insert asset;

			SBQQ__Subscription__c subscription = new SBQQ__Subscription__c();
			subscription.SBQQ__Quantity__c = 1;
			subscription.SBQQ__Product__c = subscriptionProduct.Id;
			subscription.SBQQ__Account__c = account.Id;
			subscription.SBQQ__QuoteLine__c = subscriptionQuoteLine.Id;
			insert subscription;

		Test.stopTest();

		List<Asset> assets = [SELECT Id, Name, Smart_Hands_Subscription__c, SBCF_Subscription__c FROM Asset];
		List<SBQQ__Subscription__c> subscriptions = [SELECT Id, Name FROM SBQQ__Subscription__c];

		System.assertEquals(1, assets.size(), 'One Asset should exist.');
		System.assertEquals(1, subscriptions.size(), 'One Subscription should exist.');

		System.assertEquals(null, assets[0].SBCF_Subscription__c, 'Asset subscription lookup should be null.');
		System.assertEquals(subscriptions[0].Id, assets[0].Smart_Hands_Subscription__c, 'Asset smart hands subscription should be the subscription.');
	}

	@isTest static void whenTestInsertSubscriptionWithoutRequiredByQuoteLinePopulated() {
		SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
		Opportunity opportunity = [Select Id, Name FROM Opportunity Where Name = 'Test Opportunity' Limit 1];
		Account account = [SELECT Id, Name FROM Account Where Name = 'Test Account' LIMIT 1];
		Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Test HW Product'];
		SBQQ__QuoteLine__c hwQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Product__c = :product.Id LIMIT 1];

		Product2 subscriptionProduct = new Product2();
		subscriptionProduct.Name = 'SMRT-HNDTest Subscription Product';
		subscriptionProduct.ProductCode = '654321';
		subscriptionProduct.isQuotable__c = true;
		subscriptionProduct.Family = 'Service';
		subscriptionProduct.Product_Category__c = 'Maintenance-1 Year';
		insert SubscriptionProduct;

		Order order = new Order();
		order.AccountId = account.Id;
		order.OpportunityId = opportunity.Id;
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		order.Pricebook2Id = Test.getStandardPricebookId();
		insert order;

		Test.startTest();

			SBQQ__QuoteLine__c subscriptionQuoteLine = new SBQQ__QuoteLine__c();
			subscriptionQuoteLine.SBQQ__Quote__c = quote.Id;
			subscriptionQuoteLine.SBQQ__Product__c = subscriptionProduct.Id;
			subscriptionQuoteLine.SBQQ__Quantity__c = 1;
			//subscriptionQuoteLine.SBQQ__RequiredBy__c = hwQuoteLine.Id;
			insert subscriptionQuoteLine;
 
			Id pricebookId = Test.getStandardPricebookId();
        
	        // 1. Insert a price book entry for the standard price book.
	        // Standard price book entries require the standard price book ID we got earlier.
	        PricebookEntry standardPriceHWProduct = new PricebookEntry();
	        standardPriceHWProduct.Pricebook2Id = pricebookId;
	        standardPriceHWProduct.Product2Id = product.Id;
	        standardPriceHWProduct.UnitPrice = 1000;
	        standardPriceHWProduct.IsActive = true;
	        insert standardPriceHWProduct;

			OrderItem orderProduct = new OrderItem();
			orderProduct.PricebookEntryId = standardPriceHWProduct.Id;
			orderProduct.Product2Id = product.Id;
			orderProduct.Quantity = 1;
			orderProduct.OrderId = order.Id;
			orderProduct.UnitPrice = 1000;
			insert orderProduct;

			PricebookEntry standardPriceSubscriptionProduct = new PricebookEntry();
	        standardPriceSubscriptionProduct.Pricebook2Id = pricebookId;
	        standardPriceSubscriptionProduct.Product2Id = subscriptionProduct.Id;
	        standardPriceSubscriptionProduct.UnitPrice = 1000;
	        standardPriceSubscriptionProduct.IsActive = true;
	        insert standardPriceSubscriptionProduct;
			
			OrderItem orderProduct2 = new OrderItem();
			orderProduct2.PricebookEntryId = standardPriceSubscriptionProduct.Id;
			orderProduct2.Product2Id = subscriptionProduct.Id;
			orderProduct2.Quantity = 1;
			orderProduct2.OrderId = order.Id;
			orderProduct2.UnitPrice = 1000;
			insert orderProduct2;
			
			order.Status = 'Activated';
			order.SBQQ__Contracted__c = true;
			order.SBQQ__PriceCalcStatus__c = 'Completed';
			update order;

			Asset asset = new Asset();
			asset.Name = 'Test HW Product';
			asset.AccountId = account.Id;
			asset.Product2Id = product.Id;
			asset.Quantity = 1;
			asset.SBQQ__QuoteLine__c = hwQuoteLine.Id;
			insert asset;

			SBQQ__Subscription__c subscription = new SBQQ__Subscription__c();
			subscription.SBQQ__Quantity__c = 1;
			subscription.SBQQ__Product__c = subscriptionProduct.Id;
			subscription.SBQQ__Account__c = account.Id;
			subscription.SBQQ__QuoteLine__c = subscriptionQuoteLine.Id;
			insert subscription;

		Test.stopTest();

		List<Asset> assets = [SELECT Id, Name, Smart_Hands_Subscription__c, SBCF_Subscription__c FROM Asset];
		List<SBQQ__Subscription__c> subscriptions = [SELECT Id, Name FROM SBQQ__Subscription__c];

		System.assertEquals(1, assets.size(), 'One Asset should exist.');
		System.assertEquals(1, subscriptions.size(), 'One Subscription should exist.');

		System.assertEquals(null, assets[0].SBCF_Subscription__c, 'Asset subscription lookup should be null.');
		System.assertEquals(null, assets[0].Smart_Hands_Subscription__c, 'Asset smart hands subscription should be null.');
	}

	@isTest static void whenTestInsertSubscriptionAndSmartHandsSubscriptionWithRelatedAsset() {
		SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
		Opportunity opportunity = [Select Id, Name FROM Opportunity Where Name = 'Test Opportunity' Limit 1];
		Account account = [SELECT Id, Name FROM Account Where Name = 'Test Account' LIMIT 1];
		Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Test HW Product'];
		SBQQ__QuoteLine__c hwQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Product__c = :product.Id LIMIT 1];

		Product2 smartHandsSubscriptionProduct = new Product2();
		smartHandsSubscriptionProduct.Name = 'SMRT-HNDTest Subscription Product';
		smartHandsSubscriptionProduct.ProductCode = '654321';
		smartHandsSubscriptionProduct.isQuotable__c = true;
		smartHandsSubscriptionProduct.Family = 'Service';
		smartHandsSubscriptionProduct.Product_Category__c = 'Maintenance-1 Year';
		insert smartHandsSubscriptionProduct;

		Product2 subscriptionProduct = new Product2();
		subscriptionProduct.Name = 'Test Subscription Product';
		subscriptionProduct.ProductCode = '65432198';
		subscriptionProduct.isQuotable__c = true;
		subscriptionProduct.Family = 'Service';
		subscriptionProduct.Product_Category__c = 'Maintenance-1 Year';
		insert SubscriptionProduct;

		Order order = new Order();
		order.AccountId = account.Id;
		order.OpportunityId = opportunity.Id;
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		order.Pricebook2Id = Test.getStandardPricebookId();
		insert order;

		Test.startTest();

			SBQQ__QuoteLine__c subscriptionQuoteLine = new SBQQ__QuoteLine__c();
			subscriptionQuoteLine.SBQQ__Quote__c = quote.Id;
			subscriptionQuoteLine.SBQQ__Product__c = subscriptionProduct.Id;
			subscriptionQuoteLine.SBQQ__Quantity__c = 1;
			subscriptionQuoteLine.SBQQ__RequiredBy__c = hwQuoteLine.Id;
			insert subscriptionQuoteLine;

			SBQQ__QuoteLine__c smartHandsSubscriptionQuoteLine = new SBQQ__QuoteLine__c();
			smartHandsSubscriptionQuoteLine.SBQQ__Quote__c = quote.Id;
			smartHandsSubscriptionQuoteLine.SBQQ__Product__c = smartHandsSubscriptionProduct.Id;
			smartHandsSubscriptionQuoteLine.SBQQ__Quantity__c = 1;
			smartHandsSubscriptionQuoteLine.SBQQ__RequiredBy__c = hwQuoteLine.Id;
			insert smartHandsSubscriptionQuoteLine;
 
			Id pricebookId = Test.getStandardPricebookId();
        
	        // 1. Insert a price book entry for the standard price book.
	        // Standard price book entries require the standard price book ID we got earlier.
	        PricebookEntry standardPriceHWProduct = new PricebookEntry();
	        standardPriceHWProduct.Pricebook2Id = pricebookId;
	        standardPriceHWProduct.Product2Id = product.Id;
	        standardPriceHWProduct.UnitPrice = 1000;
	        standardPriceHWProduct.IsActive = true;
	        insert standardPriceHWProduct;

			OrderItem orderProduct = new OrderItem();
			orderProduct.PricebookEntryId = standardPriceHWProduct.Id;
			orderProduct.Product2Id = product.Id;
			orderProduct.Quantity = 1;
			orderProduct.OrderId = order.Id;
			orderProduct.UnitPrice = 1000;
			insert orderProduct;

			PricebookEntry standardPriceSubscriptionProduct = new PricebookEntry();
	        standardPriceSubscriptionProduct.Pricebook2Id = pricebookId;
	        standardPriceSubscriptionProduct.Product2Id = subscriptionProduct.Id;
	        standardPriceSubscriptionProduct.UnitPrice = 1000;
	        standardPriceSubscriptionProduct.IsActive = true;
	        insert standardPriceSubscriptionProduct;
			
			OrderItem orderProduct2 = new OrderItem();
			orderProduct2.PricebookEntryId = standardPriceSubscriptionProduct.Id;
			orderProduct2.Product2Id = subscriptionProduct.Id;
			orderProduct2.Quantity = 1;
			orderProduct2.OrderId = order.Id;
			orderProduct2.UnitPrice = 1000;
			insert orderProduct2;
			
			PricebookEntry standardPriceSmartHandsSubscriptionProduct = new PricebookEntry();
	        standardPriceSmartHandsSubscriptionProduct.Pricebook2Id = pricebookId;
	        standardPriceSmartHandsSubscriptionProduct.Product2Id = smartHandsSubscriptionProduct.Id;
	        standardPriceSmartHandsSubscriptionProduct.UnitPrice = 1000;
	        standardPriceSmartHandsSubscriptionProduct.IsActive = true;
	        insert standardPriceSmartHandsSubscriptionProduct;
			
			OrderItem orderProductSmartHand = new OrderItem();
			orderProductSmartHand.PricebookEntryId = standardPriceSmartHandsSubscriptionProduct.Id;
			orderProductSmartHand.Product2Id = smartHandsSubscriptionProduct.Id;
			orderProductSmartHand.Quantity = 1;
			orderProductSmartHand.OrderId = order.Id;
			orderProductSmartHand.UnitPrice = 1000;
			insert orderProductSmartHand;

			order.Status = 'Activated';
			order.SBQQ__Contracted__c = true;
			order.SBQQ__PriceCalcStatus__c = 'Completed';
			update order;

			Asset asset = new Asset();
			asset.Name = 'Test HW Product';
			asset.AccountId = account.Id;
			asset.Product2Id = product.Id;
			asset.Quantity = 1;
			asset.SBQQ__QuoteLine__c = hwQuoteLine.Id;
			insert asset;

			List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();

			SBQQ__Subscription__c subscription = new SBQQ__Subscription__c();
			subscription.SBQQ__Quantity__c = 1;
			subscription.SBQQ__Product__c = subscriptionProduct.Id;
			subscription.SBQQ__Account__c = account.Id;
			subscription.SBQQ__QuoteLine__c = subscriptionQuoteLine.Id;

			subscriptions.add(subscription);

			SBQQ__Subscription__c smartHandsSubscription = new SBQQ__Subscription__c();
			smartHandsSubscription.SBQQ__Quantity__c = 1;
			smartHandsSubscription.SBQQ__Product__c = smartHandsSubscriptionProduct.Id;
			smartHandsSubscription.SBQQ__Account__c = account.Id;
			smartHandsSubscription.SBQQ__QuoteLine__c = smartHandsSubscriptionQuoteLine.Id;

			subscriptions.add(smartHandsSubscription);

			insert subscriptions;			

		Test.stopTest();

		List<Asset> assets = [SELECT Id, Name, Smart_Hands_Subscription__c, SBCF_Subscription__c FROM Asset];
		SBQQ__Subscription__c regularSubscription = [SELECT Id, Name FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.Name = 'Test Subscription Product' LIMIT 1];
		SBQQ__Subscription__c smartHandSubscription = [SELECT Id, Name FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.Name = 'SMRT-HNDTest Subscription Product' LIMIT 1];

		System.assertEquals(1, assets.size(), 'One Asset should exist.');

		System.assertEquals(regularSubscription.Id, assets[0].SBCF_Subscription__c, 'Asset subscription lookup should be regular subscription Id.');
		System.assertEquals(smartHandSubscription.Id, assets[0].Smart_Hands_Subscription__c, 'Asset smart hands subscription should be smart hand subscription Id.');
	}
	
}