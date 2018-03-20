public with sharing class VirtualShipmentController {

    public Order order {get;set;}
    public List<Order> orderList {get;set;}
    public List<OrderItem> orderProducts {get;set;} 
    public Boolean isDuplicateECProd;
    public Boolean orderIsActivated {get;set;}

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
        
        orderProducts = OrderShipmentHelper.queryForOrderProducts(this.order.Id, OrderShipmentHelper.PRODUCT_CATEGORY_HARDWARE_VIRTUAL);
        System.debug('Order Products: ' + orderProducts);
        
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