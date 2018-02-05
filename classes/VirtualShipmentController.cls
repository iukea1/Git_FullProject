public with sharing class VirtualShipmentController {

	public Order order {get;set;}
    public List<OrderItem> orderProducts {get;set;} 

    public VirtualShipmentController(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            stdController.addFields(OrderShipmentHelper.getAllOrderFieldsAPINames());
        }

        this.order = (Order)stdController.getRecord();
        this.orderProducts = OrderShipmentHelper.queryForOrderProducts(this.order.Id);
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