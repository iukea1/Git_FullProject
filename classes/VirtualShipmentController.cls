public with sharing class VirtualShipmentController {

    public Order order {get;set;}
    public List<Order> orderList {get;set;}
    public List<OrderItem> orderProducts {get;set;}
    public List<OrderItem> orderItems {get;set;}
    public OrderItem orderItem {get;set;}
    
    public Boolean hasSmartHands;
    public Boolean isDuplicateECProd;
    public Boolean orderProductQuantityIsNotEqual;
    public Boolean orderIsActivated {get;set;}
    public Boolean notRenewal {get;set;}
    
    public Boolean orderItemsQuantityIsNotEqual;
    
    public List<SBQQ__SubscribedAsset__c> oldSubscriptionAndAsset {get;set;}
    public List<Asset> assetToUpdate {get;set;}
    
    public List<SBQQ__Subscription__c> existingSubscription;
    public List<SBQQ__Subscription__c> displaySubscription {get;set;}
    public List<SBQQ__Subscription__c> displayAmendedSubscription {get;set;}

    public Map<Id, List<SBQQ__SubscribedAsset__c>> subscriptionToSubscribedAsset {get;set;}
    public Map<Id, List<OrderItem>> orderToOrderItemQuantity {get;set;}
    
    public List<SBQQ__SubscribedAsset__c> previousSubAsset {get;set;}
    public List<Asset> assetUpdate {get;set;}
    
    
    public List<SBQQ__Subscription__c> amendedSubscription {get;set;}
    public List<SBQQ__Subscription__c> updateAmendedSubscription {get;set;}
    public Map<Id, List<SBQQ__SubscribedAsset__c>> amendedsubToSubscribedAssetMap {get;set;}
    public Map<Id, OrderItem> orderToItemQuantityMap {get;set;}
    public Map<Id, String> orderItemNameMap {get;set;}
    public Map<Id, String> orderItemAmendmentNameMap {get;set;}
    
    public Boolean isRenewal {get;set;}
    public Boolean isAmendment {get;set;}
    
    Set<Id> renewalOrderIds = new Set<Id>();
    Set<Id> amendedOrderIds = new Set<Id>();
    
    Set<Id> amendedContractIds = new Set<Id>();
    Set<Id> assetsToRenewed = new Set<Id>();
    
    Set<Id> renewalContractIds = new Set<Id>(); 
    Set<Id> selectedAssetIds = new Set<Id>();
    
    Set<String> serialStrings = new Set<String>();
    
    
    
    public VirtualShipmentController(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            //stdController.addFields(OrderShipmentHelper.getAllOrderFieldsAPINames());
        }

        this.order = [SELECT Id, SBQQ__Quote__c, Status, Type, OrderNumber, SerialNumberApplied__c  FROM Order WHERE Id = :stdController.getRecord().Id LIMIT 1];

        SBQQ__Quote__c parentQuote = [SELECT Id, Serial_Number_Notes__c FROM SBQQ__Quote__c WHERE Id = :order.SBQQ__Quote__C];

        if(parentQuote != null && parentQuote.Serial_Number_Notes__c != null && !order.SerialNumberApplied__c) {
            for(String s : parentQuote.Serial_Number_Notes__c.split(',')) {
                serialStrings.add(s.trim());
            }
        }

        this.orderIsActivated = OrderShipmentHelper.determineIsOrderActivated(this.order);

        if(this.orderIsActivated){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Virtual Shipment details Cannot be applied to active orders.');
            ApexPages.addMessage(myMsg);
            return;
        }
        
        
        
        //TODO - check if this is correct
        if(this.order.Type != 'Renewal' && this.order.Type != 'Amendment'){
            notRenewal = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Virtual Shipment details can be only applied to Renewals / Amendments');
            ApexPages.addMessage(myMsg);
            return;
        }
        
        // Determine first if the order is renewal
        // If renewal, then query the related opportunity and the renewed contract. 
        // From the renewed contract, get the subscsription, and get the subscribed asset list. 
        
      /*  if(this.order.Type == 'Renewal'){
            List<Order> renewalOrders = [SELECT Id, Opportunity.SBQQ__RenewedContract__c FROM Order WHERE Id =: this.order.Id AND Opportunity.SBQQ__RenewedContract__c NOT IN ('', NULL) LIMIT 1];
            for(Order renewalOrder: renewalOrders){
                renewalContractIds.add(renewalOrder.Opportunity.SBQQ__RenewedContract__c);
                renewalOrderIds.add(renewalOrder.Id);
            } 
            
           
        orderProducts = [SELECT Id, OrderId, Quantity, SBQQ__QuotedQuantity__c, PricebookEntry.Product2.Name FROM OrderItem WHERE OrderId IN: renewalOrderIds];
            orderItemNameMap = new Map<Id, String>();
            
            for(OrderItem oItem: orderProducts){
                orderItemNameMap.put(oItem.Id, oItem.PricebookEntry.Product2.Name);
            }
            
            //oldSubscriptionAndAsset = [SELECT Id, SBQQ__Subscription__r.SBQQ__Contract__c, SBQQ__Asset__r.Name, SBQQ__Asset__r.SerialNumber, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN : renewalContractIds];
            //parentOfSubscriptionAndAsset = [SELECT Id, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN : renewalContractIds LIMIT 1];
            existingSubscription = [SELECT Id, SBQQ__Product__r.Name, SBQQ__ProductName__c, SBQQ__Quantity__c, Quoted_Quantity__c, SBQQ__Contract__c, (SELECT Id, SBQQ__Asset__r.Name, SBQQ__Asset__r.SerialNumber, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c FROM SBQQ__SubscribedAssets__r) FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: renewalContractIds];
            
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
            for(SBQQ__Subscription__c sub: existingSubscription){
               for(OrderItem oiRec: orderProducts){
                   
                   System.debug('orderItemNameMap.get(oiRec.Id) : ' + orderItemNameMap.get(oiRec.Id));
                   System.debug('sub.SBQQ__ProductName__c : ' + sub.SBQQ__ProductName__c);
                   
                   System.debug('orderItemNameMap.get(oiRec.Id) 1 : ' + orderItemNameMap.get(oiRec.Id).substring(0,5));
                   System.debug('sub.SBQQ__ProductName__c 1: ' + sub.SBQQ__ProductName__c.substring(0,5));
                   
                   if(orderItemNameMap.get(oiRec.Id).substring(0,5) == sub.SBQQ__ProductName__c.substring(0,5)){
                       
                       System.debug('orderItemNameMap.get(oiRec.Id) 2 : ' + orderItemNameMap.get(oiRec.Id).substring(0,5));
                       System.debug('sub.SBQQ__ProductName__c 2: ' + sub.SBQQ__ProductName__c.substring(0,5));
                        sub.Quoted_Quantity__c = oiRec.SBQQ__QuotedQuantity__c;  
                        subList.add(sub);
                   }
                   
                } 
            }
      
        if(subList.size()>0){
            update subList;
        }
        
        displaySubscription = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Quantity__c, Quoted_Quantity__c, SBQQ__Contract__c, (SELECT Id, SBQQ__Asset__r.Name, SBQQ__Asset__r.SerialNumber, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c FROM SBQQ__SubscribedAssets__r) FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: renewalContractIds];
        
            isRenewal = true;
            
        } */
        // else if
        /*
        if(this.order.Type == 'Amendment'){
            List<Order> amendmentOrders = [SELECT Id, Opportunity.SBQQ__AmendedContract__c FROM Order WHERE Id =: this.order.Id AND Opportunity.SBQQ__AmendedContract__c NOT IN ('', NULL) LIMIT 1];
            
            for(Order amendmentOrder: amendmentOrders){
                amendedContractIds.add(amendmentOrder.Opportunity.SBQQ__AmendedContract__c);
                amendedOrderIds.add(amendmentOrder.Id);
            }
            
            orderItems = [SELECT Id, OrderId, Quantity FROM OrderItem WHERE OrderId IN: amendedOrderIds];
            
            amendedSubscription = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Quantity__c, SBQQ__Contract__c, 
                                  (SELECT Id, SBQQ__Asset__r.Name, SBQQ__Asset__r.SerialNumber, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c 
                                   FROM SBQQ__SubscribedAssets__r) FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: amendedContractIds];
            
            for(OrderItem oi: orderItems){
                for(SBQQ__Subscription__c s: amendedSubscription){
                    
                }
            }
            isAmendment = true;
        }
        */
        /*
        else{
            orderProducts = OrderShipmentHelper.queryForOrderProducts(this.order.Id, OrderShipmentHelper.PRODUCT_CATEGORY_HARDWARE_VIRTUAL);
            System.debug('Order Products: ' + orderProducts);
            isRenewal = false;
            
            if(orderProducts == null || orderProducts.size() == 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'There are no order products available. The forecast category must contain virtual.');
            ApexPages.addMessage(myMsg);
            return;
            }
        }    
        */
    }
    
    public PageReference constructor(){
        orderItemAmendmentNameMap = new Map<Id, String>();
        updateAmendedSubscription = new List<SBQQ__Subscription__c>();
        Set<Id> amendmentUpdates = new Set<Id>();
        
        if(this.order.Type == 'Renewal'){
            
            List<Order> renewalOrders = [SELECT Id, Opportunity.SBQQ__RenewedContract__c FROM Order WHERE Id =: this.order.Id AND Opportunity.SBQQ__RenewedContract__c NOT IN ('', NULL) LIMIT 1];
            for(Order renewalOrder: renewalOrders){
                renewalContractIds.add(renewalOrder.Opportunity.SBQQ__RenewedContract__c);
                renewalOrderIds.add(renewalOrder.Id);
            } 
            
           
            orderProducts = [SELECT Id, OrderId, Quantity, SBQQ__QuotedQuantity__c, PricebookEntry.Product2.Name FROM OrderItem WHERE OrderId IN: renewalOrderIds];
            orderItemNameMap = new Map<Id, String>();
            
            for(OrderItem oItem: orderProducts){
                orderItemNameMap.put(oItem.Id, oItem.PricebookEntry.Product2.Name);
            }
            
            //oldSubscriptionAndAsset = [SELECT Id, SBQQ__Subscription__r.SBQQ__Contract__c, SBQQ__Asset__r.Name, SBQQ__Asset__r.SerialNumber, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN : renewalContractIds];
            //parentOfSubscriptionAndAsset = [SELECT Id, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN : renewalContractIds LIMIT 1];
            existingSubscription = [SELECT Id, SBQQ__Product__r.Name, SBQQ__ProductName__c, SBQQ__Quantity__c, Quoted_Quantity__c, SBQQ__Contract__c, 
                (SELECT Id, SBQQ__Asset__r.Name, SBQQ__Asset__r.SerialNumber, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c FROM SBQQ__SubscribedAssets__r) 
                FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: renewalContractIds];
            
            subscriptionToSubscribedAsset = new Map<Id, List<SBQQ__SubscribedAsset__c>>();
            Map<Id, SBQQ__Subscription__c> subList = new Map<Id, SBQQ__Subscription__c>();
            
            for(SBQQ__Subscription__c sub: existingSubscription){
                subscriptionToSubscribedAsset.put(sub.Id, sub.SBQQ__SubscribedAssets__r);
                for(SBQQ__SubscribedAsset__c sa : sub.SBQQ__SubscribedAssets__r) {
                    sa.SBQQ__Asset__r.Is_Selected_For_Renewal__c = true;
                }
                for(OrderItem oiRec: orderProducts){
                   if(orderItemNameMap.get(oiRec.Id).substring(0,7) == sub.SBQQ__ProductName__c.substring(0,7)){          
                        sub.Quoted_Quantity__c = oiRec.Quantity;                 
                        subList.put(sub.Id, sub);
                   }
                } 
            }
            
            if(subList == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'There are no renewal subscription available.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            
            if(subList.size()>0){
                update subList.values();
            
            }
    
            displaySubscription = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Quantity__c, Quoted_Quantity__c, SBQQ__Contract__c, (SELECT Id, SBQQ__Asset__r.Name, SBQQ__Asset__r.SerialNumber, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c FROM SBQQ__SubscribedAssets__r) FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: renewalContractIds];
            
                for(SBQQ__Subscription__c s: displaySubscription ){
                    for(SBQQ__SubscribedAsset__c sa : s.SBQQ__SubscribedAssets__r) {
                        sa.SBQQ__Asset__r.Is_Selected_For_Renewal__c = serialStrings.contains(sa.SBQQ__Asset__r.SerialNumber) || sa.SBQQ__Asset__r.Is_Selected_For_Renewal__c;
                    }
                }
            
            isRenewal = true;
                
        } else if(this.order.Type == 'Amendment') {
            
            List<Order> amendmentOrders = [SELECT Id, Opportunity.SBQQ__AmendedContract__c FROM Order WHERE Id =: this.order.Id AND Opportunity.SBQQ__AmendedContract__c NOT IN ('', NULL) LIMIT 1];
            
            for(Order amendmentOrder: amendmentOrders){
                amendedContractIds.add(amendmentOrder.Opportunity.SBQQ__AmendedContract__c);
                amendedOrderIds.add(amendmentOrder.Id);
            }
            
            orderItems = [SELECT Id, OrderId, Quantity, PricebookEntry.Product2.Name FROM OrderItem WHERE OrderId IN: amendedOrderIds];
            
            for(OrderItem orderItem: orderItems){
            //System.assertEquals('', ' ' + orderItem.PricebookEntry.Product2);
                orderItemAmendmentNameMap.put(orderItem.Id, orderItem.PricebookEntry.Product2.Name);
            }
            
            amendedSubscription = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Quantity__c, SBQQ__Contract__c, Quoted_Quantity__c, SBQQ__ProductName__c,
                                   (SELECT Id, SBQQ__Asset__r.Name, SBQQ__Asset__r.SerialNumber, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c 
                                    FROM SBQQ__SubscribedAssets__r) FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: amendedContractIds];
            
            for(OrderItem oi: orderItems){
                for(SBQQ__Subscription__c s: amendedSubscription){
                    for(SBQQ__SubscribedAsset__c sa : s.SBQQ__SubscribedAssets__r) {
                        sa.SBQQ__Asset__r.Is_Selected_For_Renewal__c = serialStrings.contains(sa.SBQQ__Asset__r.SerialNumber);
                    }
                    if(!amendmentUpdates.contains(s.Id)) {
                        if(orderItemAmendmentNameMap.get(oi.Id) != null && s.SBQQ__ProductName__c != null){
                            if(orderItemAmendmentNameMap.get(oi.Id).substring(0,7) == s.SBQQ__ProductName__c.substring(0,7)){
                                s.Quoted_Quantity__c = oi.Quantity;
                                updateAmendedSubscription.add(s);
                                amendmentUpdates.add(s.Id);
                            }
                        }
                    }
                }
            }
            
            if(updateAmendedSubscription.isEmpty()){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'There are no amended subscription available.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            
            if(updateAmendedSubscription.size()>0){
                update updateAmendedSubscription;
            }
            
            displayAmendedSubscription =  [SELECT Id, SBQQ__Product__r.Name, SBQQ__Quantity__c, SBQQ__Contract__c, Quoted_Quantity__c,
                                          (SELECT Id, SBQQ__Asset__r.Name, SBQQ__Asset__r.SerialNumber, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c 
                                           FROM SBQQ__SubscribedAssets__r) FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: amendedContractIds];
            isAmendment = true;
        }
        
        return null;
    }
    
    public PageReference saveOrder(){
        
        //check if order records related quote has the boolean field 'SBCF_Evaluation_Quote__c' equal to FALSE
        //checking also if there's a EC Products and EC-AAS-ORCH that was included in the quote line.
         
        Order orderRec = [SELECT Id, SBQQ__Quote__r.SBCF_Evaluation_Quote__c, SBQQ__Quote__r.Serial_Number_Notes__c , SBQQ__Contracted__c, Type, (SELECT Id, Quantity, OrderId FROM OrderItems) FROM Order WHERE Id =: this.order.Id LIMIT 1];
        orderRec.SerialNumberApplied__c = true;
        //In this controller of VF page, there is two layout, one is for first order, and 2nd is the renewal of order. 
        //Check first the Order Status, so that you could Identify which save functionality will be done from your vf page.  
        /*if(orderRec.Type != 'Renewal'){
            if(orderRec.SBQQ__Quote__r.SBCF_Evaluation_Quote__c == False){
                    
                isDuplicateECProd = OrderShipmentHelper.queryForOrderProductsVirtualShipment(this.order.Id, OrderShipmentHelper.PRODUCT_CATEGORY_HARDWARE_VIRTUAL);
                        
                if(isDuplicateECProd == true){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: Only one can be choose between EC Products and EC-ORCH-AAS'));
                    return null;
                }
                
                hasSmartHands = OrderShipmentHelper.queryOrderProdIfContainsSmartHands(this.order.Id, OrderShipmentHelper.PRODUCT_CATEGORY_HARDWARE_VIRTUAL);
                
                if(hasSmartHands == true){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Smart Hands Products are existing.'));
                    return null;
                }
                        
            }
                
            
            try{
                 if(orderProducts.size() > 0){
                     update orderProducts;
                 } 
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
                return null;
            }
                
                
            PageReference page = new PageReference('/' + this.order.Id);
            page.setRedirect(true);
            return page;
            
        }*/
        
        //else if(orderRec.Type == 'Renewal'){
        if(orderRec.Type == 'Renewal'){
            // On the order shipment handler, create another helper class, that will query the order product's quantity,
            // after getting the quantity of order product, compare it to the size of the selected asset on VF page.
        
        
           
        orderToOrderItemQuantity = new Map<Id, List<OrderItem>>();
        /*    
        for(OrderItem orderItem: orderRec.OrderItems){
            if(orderToOrderItemQuantity.containsKey(orderItem.OrderId)){
                List<OrderItem> orderItemList = orderToOrderItemQuantity.get(orderItem.OrderId);
                orderItemList.add(orderItem);
                orderToOrderItemQuantity.put(orderItem.OrderId, orderItemList);
            }
            else{
                orderToOrderItemQuantity.put(orderItem.OrderId, new List<OrderItem>{orderItem});
            }
        }    
        */    
            for(SBQQ__Subscription__c existingSubs: displaySubscription){
            
                oldSubscriptionAndAsset = new List<SBQQ__SubscribedAsset__c>();
                subscriptionToSubscribedAsset = new Map<Id, List<SBQQ__SubscribedAsset__c>>();
                
                for(SBQQ__SubscribedAsset__c subsAsset: existingSubs.SBQQ__SubscribedAssets__r){
                    if(subsAsset.SBQQ__Asset__r.Is_Selected_For_Renewal__c){
                        if(subscriptionToSubscribedAsset.containsKey(existingSubs.Id)){
                            List<SBQQ__SubscribedAsset__c> subAssetInSubscription = subscriptionToSubscribedAsset.get(existingSubs.Id);
                            subAssetInSubscription.add(subsAsset);
                            subscriptionToSubscribedAsset.put(existingSubs.Id, subAssetInSubscription);
                        }
                        else{
                            subscriptionToSubscribedAsset.put(existingSubs.Id, new List<SBQQ__SubscribedAsset__c>{subsAsset});
                        }
                    }
                        
                                        
                    List<SBQQ__SubscribedAsset__c> selectedAsset = subscriptionToSubscribedAsset.get(existingSubs.Id);
                    if(selectedAsset == null) selectedAsset = new List<SBQQ__SubscribedAsset__c>();
                    
                    assetToUpdate = new List<Asset>();
                    //loop order item
                    for(SBQQ__SubscribedAsset__c asset: selectedAsset){
                        
                        //if(asset.SBQQ__Asset__r.Is_Selected_For_Renewal__c){
                            Asset updateAsset = new Asset();
                            updateAsset.Id = asset.SBQQ__Asset__c;
                            updateAsset.Is_Selected_For_Renewal__c = true;
                            assetToUpdate.add(updateAsset);
                        //}
                        
                    }
                    
                    if(existingSubs.Quoted_Quantity__c != assetToUpdate.size()){
                        orderProductQuantityIsNotEqual = true;
                    }
                    
                    else if(existingSubs.Quoted_Quantity__c == selectedAsset.size()){
                        orderProductQuantityIsNotEqual = false;
                    }
                    update assetToUpdate;
                }
             }
         
            if(orderProductQuantityIsNotEqual){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: The Order for Product quantity must equal to all of your selected asset'));
               return null;
            }
            else {
                if(assetToUpdate.size() > 0) {
                    update assetToUpdate;
                }
            }
            
        } else if(orderRec.Type == 'Amendment'){
            
            for(SBQQ__Subscription__c amendedSub: displayAmendedSubscription){
                
                previousSubAsset = new List<SBQQ__SubscribedAsset__c>();
                amendedsubToSubscribedAssetMap = new Map<Id, List<SBQQ__SubscribedAsset__c>>();
                
                for(SBQQ__SubscribedAsset__c amendedSA: amendedSub.SBQQ__SubscribedAssets__r) {
                    
                    if(amendedSA.SBQQ__Asset__r.Is_Selected_For_Renewal__c) {
                        //Mapping for Subscription to Subscribed Asset
                        if(amendedsubToSubscribedAssetMap.containsKey(amendedSub.Id)) {
                            List<SBQQ__SubscribedAsset__c> subAssetInAmendedSub = amendedsubToSubscribedAssetMap.get(amendedSub.Id);
                            subAssetInAmendedSub.add(amendedSA);
                            amendedsubToSubscribedAssetMap.put(amendedSub.Id, subAssetInAmendedSub);
                        } else{
                            amendedsubToSubscribedAssetMap.put(amendedSub.Id, new List<SBQQ__SubscribedAsset__c>{amendedSA});
                        }
                        // end of mapping
                    }
                                        
                    //OrderItem orderItemQuantity = orderToItemQuantityMap.get(orderRec.Id);
                    List<SBQQ__SubscribedAsset__c> assetSelected = amendedsubToSubscribedAssetMap.get(amendedSub.Id);
                    
                    assetUpdate = new List<Asset>();
                    
                    if(assetSelected != null && !assetSelected.isEmpty()) {
                        for(SBQQ__SubscribedAsset__c asset: assetSelected) {
                            //if(asset.SBQQ__Asset__r.Is_Selected_For_Renewal__c) {
                                Asset updateAsset = new Asset(Id = asset.SBQQ__Asset__c, Is_Selected_For_Renewal__c = true);
                                assetUpdate.add(updateAsset);
                            //}
                        }
                    }
                    
                    if(amendedSub.Quoted_Quantity__c != assetUpdate.size()) {
                        orderItemsQuantityIsNotEqual = true;
                    }
                    
                    else if(amendedSub.Quoted_Quantity__c == assetUpdate.size()) {
                        orderItemsQuantityIsNotEqual = false;
                    }
                    
                    if(orderItemsQuantityIsNotEqual) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: The Order Product quantity must equal to all of your selected asset'));
                        return null;
                    } else {
                        if(assetUpdate.size() > 0) {
                            update assetUpdate;
                        }
                    }
                }
            }
            
            
        }
        update orderRec;
        PageReference page = new PageReference('/' + this.order.Id);
        page.setRedirect(true);
        return page;
    }

    public PageReference returnToOrder(){
        PageReference page = new PageReference('/' + this.order.Id);
        page.setRedirect(true);
        return page;
    }
    
    /*
    public PageReference action(){
        subscriptionToNumberOfSelected = new Map<Id, Integer>();
        return null;
    }
    */
    

   
    
    
}