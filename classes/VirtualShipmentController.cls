public with sharing class VirtualShipmentController {

	public Order order {get;set;}
    public List<OrderItem> orderProducts {get;set;} 

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

        //this.orderProducts = OrderShipmentHelper.queryForOrderProducts(this.order.Id);
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