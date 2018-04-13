public with sharing class VirtualShipmentController {

    public Order order {get;set;}
    public List<Order> orderList {get;set;}
    public List<OrderItem> orderProducts {get;set;} 
    public Boolean isDuplicateECProd;
    public Boolean orderIsActivated {get;set;}
    public List<SBQQ__SubscribedAsset__c> oldSubscriptionAndAsset {get;set;}
    
    public Boolean isRenewal {get;set;}
    
    Set<Id> renewalContractIds = new Set<Id>(); 

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
            List<Order> renewalOrders = [SELECT Id, Opportunity.SBQQ__RenewedContract__c FROM Order WHERE Opportunity.SBQQ__RenewedContract__c NOT IN ('', NULL) LIMIT 1];
            for(Order renewalOrder: renewalOrders){
                renewalContractIds.add(renewalOrder.Opportunity.SBQQ__RenewedContract__c);
            } 
            oldSubscriptionAndAsset = [SELECT Id, SBQQ__Subscription__r.SBQQ__Contract__c, SBQQ__Asset__c, SBQQ__Subscription__c, SBQQ__Subscription__r.SBQQ__Quantity__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN : renewalContractIds];
        	isRenewal = true;
        }
        else{
            orderProducts = OrderShipmentHelper.queryForOrderProducts(this.order.Id, OrderShipmentHelper.PRODUCT_CATEGORY_HARDWARE_VIRTUAL);
        	System.debug('Order Products: ' + orderProducts);
            isRenewal = false;
        }
            
        
		        
        
        
        
        
        if(orderProducts == null || orderProducts.size() == 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'There are no order products available. The forecast category must contain virtual.');
            ApexPages.addMessage(myMsg);
            return;
        }
    }
    
    
    
    public PageReference saveOrder(){
        
        //check if order records related quote has the boolean field 'SBCF_Evaluation_Quote__c' equal to FALSE
        //checking also if there's a EC Products and EC-AAS-ORCH that was included in the quote line. 
        Order orderRec = [SELECT Id, SBQQ__Quote__r.SBCF_Evaluation_Quote__c, SBQQ__Contracted__c, Status FROM Order WHERE Id =: this.order.Id LIMIT 1];      
        if(orderRec.SBQQ__Quote__r.SBCF_Evaluation_Quote__c == False){
            isDuplicateECProd = OrderShipmentHelper.queryForOrderProductsVirtualShipment(this.order.Id, OrderShipmentHelper.PRODUCT_CATEGORY_HARDWARE_VIRTUAL);
            System.debug('isDuplicateECProd' + isDuplicateECProd);
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

    public PageReference returnToOrder(){
        PageReference page = new PageReference('/' + this.order.Id);
        page.setRedirect(true);
        return page;
    }
}