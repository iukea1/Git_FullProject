public with sharing class VirtualShipmentController {

    public Order order {get;set;}
    public List<Order> orderList {get;set;}
    public List<OrderItem> orderProducts {get;set;} 
    public Boolean isDuplicateECProd;
    public Boolean orderIsActivated {get;set;}
    public List<SBQQ__SubscribedAsset__c> oldSubscriptionAndAsset {get;set;}
    public List<SBQQ__SubscribedAsset__c> parentOfSubscriptionAndAsset {get;set;}
    public List<SBQQ__Subscription__c> existingSubscription {get;set;}
    
    public Boolean isRenewal {get;set;}
    
    Set<Id> renewalContractIds = new Set<Id>(); 
    Set<Id> selectedAssetIds = new Set<Id>();

    public VirtualShipmentController(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            stdController.addFields(OrderShipmentHelper.getAllOrderFieldsAPINames());
        }

        this.order = (Order)stdController.getRecord();

        this.orderIsActivated = OrderShipmentHelper.determineIsOrderActivated(this.order);

        if(this.orderIsActivated){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Virtual Shipment details Cannot be applied to active orders.');
            ApexPages.addMessage(myMsg);
            return;
        }
        
        // Determine first if the order is renewal
        // If renewal, then query the related opportunity and the renewed contract. 
        // From the renewed contract, get the subscsription, and get the subscribed asset list. 
        
        if(this.order.Type == 'Renewal'){
            List<Order> renewalOrders = [SELECT Id, Opportunity.SBQQ__RenewedContract__c FROM Order WHERE Id =: this.order.Id AND Opportunity.SBQQ__RenewedContract__c NOT IN ('', NULL) LIMIT 1];
            for(Order renewalOrder: renewalOrders){
                renewalContractIds.add(renewalOrder.Opportunity.SBQQ__RenewedContract__c);
            } 
            
            oldSubscriptionAndAsset = [SELECT Id, SBQQ__Subscription__r.SBQQ__Contract__c, SBQQ__Asset__r.Name, SBQQ__Asset__r.SerialNumber, SBQQ__Asset__r.Is_Selected_For_Renewal__c, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN : renewalContractIds];
        	parentOfSubscriptionAndAsset = [SELECT Id, SBQQ__Subscription__r.SBQQ__Product__r.Name, SBQQ__Subscription__r.SBQQ__Quantity__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN : renewalContractIds LIMIT 1];
            existingSubscription = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Quantity__c,(SELECT Id, SBQQ__Asset__r.Name, SBQQ__Asset__r.SerialNumber, SBQQ__Asset__r.Is_Selected_For_Renewal__c FROM SBQQ__SubscribedAssets__r) FROM SBQQ__Subscription__c];
            isRenewal = true;
        }
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
    }
    
    
    
    public PageReference saveOrder(){
        
        //check if order records related quote has the boolean field 'SBCF_Evaluation_Quote__c' equal to FALSE
        //checking also if there's a EC Products and EC-AAS-ORCH that was included in the quote line.
         
        Order orderRec = [SELECT Id, SBQQ__Quote__r.SBCF_Evaluation_Quote__c, SBQQ__Contracted__c, Status FROM Order WHERE Id =: this.order.Id LIMIT 1];
        //In this controller of VF page, there is two layout, one is for first order, and 2nd is the renewal of order. 
        //Check first the Order Status, so that you could Identify which save functionality will be done from your vf page.  
        if(orderRec.Status != 'Renewal'){
            if(orderRec.SBQQ__Quote__r.SBCF_Evaluation_Quote__c == False){
                    isDuplicateECProd = OrderShipmentHelper.queryForOrderProductsVirtualShipment(this.order.Id, OrderShipmentHelper.PRODUCT_CATEGORY_HARDWARE_VIRTUAL);
                        if(isDuplicateECProd == true){
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: Only one can be choose between EC Products and EC-ORCH-AAS'));
                        }
            }
                
            if(isDuplicateECProd == true){
                return null;
            }
            else {
                
                if(orderProducts.size() > 0){
                    update orderProducts;
                }
                PageReference page = new PageReference('/' + this.order.Id);
                page.setRedirect(true);
                return page;
            }
        }
        
        else if(orderRec.Status == 'Renewal'){
            // On the order shipment handler, create another helper class, that will query the order product's quantity,
            // after getting the quantity of order product, compare it to the size of the selected asset on VF page. 
            for(SBQQ__SubscribedAsset__c subscribeAsset: oldSubscriptionAndAsset){
                if(subscribeAsset.SBQQ__Asset__r.Is_Selected_For_Renewal__c == true){
                    selectedAssetIds.add(subscribeAsset.SBQQ__Asset__c);
                }
            }
            //return null;
        }
                
        PageReference page = new PageReference('/' + this.order.Id);
        page.setRedirect(true);
        return page;
        
    }

    public PageReference returnToOrder(){
        PageReference page = new PageReference('/' + this.order.Id);
        page.setRedirect(true);
        return page;
    }
}