public with sharing class VirtualShipmentController {

    public Order order {get;set;}
    public List<Order> orderList {get;set;}
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
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'There are no order products available where the forecast category contains virtual.');
            ApexPages.addMessage(myMsg);
            return;
        }
    }
    
    
    
    public PageReference saveOrder(){
        
        //check if order records related quote has the boolean field 'SBCF_Evaluation_Quote__c' equal to FALSE
        //orderRecs will be the storage of the orders that has been activated. 
        List<Order> orderRecs = new List<Order>();
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
        	//query the order record           
            // update the field to be activated
            orderRec.SBQQ__Contracted__c = true;
            orderRec.Status = 'Activated'; 
            orderRecs.add(orderRec);
            if(orderRecs.size()>0){
                update orderRecs;
            }
            
            
            // query contracts under the order (parent)
            Set<Id> contractIds = new Set<Id>();
            List<Contract> contractList = [SELECT Id, Name, SBQQ__Order__c, SBQQ__Order__r.Status, SBQQ__Order__r.SBQQ__Contracted__c FROM Contract WHERE SBQQ__Order__c =: this.order.Id];
            for(Contract cont: contractList){
            	 contractIds.add(cont.Id);
            } 
			List<SBQQ__Subscription__c> subsList = [SELECT Id, Name, SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractIds];
			
            
            Set<id> accountIds = new Set<Id>();
            List<Asset> assetlist = [SELECT Id, Name, License_Key__c, AccountId FROM Asset WHERE AccountId IN (SELECT AccountId FROM Order WHERE Id =: this.order.Id)];
            //List<Account> accList = [SELECT Id, Name, Order FROM Account];
            // Order -> Account -> Asset
            
            
            
            // fill-in the license key for assets and subscription using the 2 apex classes given in SDD
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
    
     private List<Contract> queryForRelatedContract(){
        
        List<Contract> contractList = new List<Contract>();
         
        try{
            contractList = [SELECT Id, Name, SBQQ__Order__c FROM Contract WHERE SBQQ__Order__c =: this.order.Id];
        }   
        catch(QueryException qe){
            System.debug(qe.getMessage());
        }

        return contractList;
    }

}