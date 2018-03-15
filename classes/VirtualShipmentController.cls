public with sharing class VirtualShipmentController {

    public Order order {get;set;}
    public List<OrderItem> orderProducts {get;set;} 
    public Boolean isECProducts;
    public Boolean isDuplicateECProd;
    public Set<Id> orderProductSet;
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
            System.debug('There are no order products available.');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'There are no order products available.');
            ApexPages.addMessage(myMsg);
            return;
        }
       
        //String relatedQuoteStatus = getRelatedQuote();
        /*SBQQ__Quote__c quote = queryForRelatedQuote();
            if(quote.SBCF_Evaluation_Quote__c == False){
                for(OrderItem op: orderProducts){
                    
                }
            }
        */
    }
    
    // Helper Method

    private SBQQ__Quote__c queryForRelatedQuote(){
        
        SBQQ__Quote__c relatedQuote;

        if(this.order.SBQQ__Quote__c == null){
            // return null
            System.debug('SBQQ__Quote__c lookup field null');
            return relatedQuote;
        }
        
        try{
            relatedQuote = [SELECT SBCF_Evaluation_Quote__c, RecordType.Name FROM SBQQ__Quote__c WHERE Id = :order.SBQQ__Quote__c LIMIT 1];
        }   
        catch(QueryException qe){
            System.debug(qe.getMessage());
        }

        return relatedQuote;
    }
    
    public PageReference saveOrder(){
        
        //check if order records related quote has the boolean field 'SBCF_Evaluation_Quote__c' equal to FALSE
        //query order items including the orderProducts in constructor
        
        System.debug('Order Id ----> ' + this.order.id);
       
        List<OrderItem> orderProductList = OrderShipmentHelper.queryForOrderProducts(this.order.id, OrderShipmentHelper.PRODUCT_CATEGORY_HARDWARE_VIRTUAL);
        System.debug('order products test -------@@@@  ' + orderProductList);
        
      
        for(OrderItem oi: orderProducts){
            System.debug('------->Product Name<--------  ' + oi);
            //oi.Product2.Name = 'Sample ';
        }
        
        Order orderRec = [SELECT Id, SBQQ__Quote__r.SBCF_Evaluation_Quote__c FROM Order WHERE Id =: this.order.Id LIMIT 1];
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
            // query order record
            // update the field to be activated 
            // query contracts under the order (parent)
            // loop the contracts to see all the assets and subscription
            // fill-in the license key for assets and subscription using the 2 apex classes given in SDD
            this.orderIsActivated = true;
            PageReference page = new PageReference('/' + this.order.Id);
            page.setRedirect(true);
            return page;
        }
        
    }
    
    public PageReference activateOrder(){
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