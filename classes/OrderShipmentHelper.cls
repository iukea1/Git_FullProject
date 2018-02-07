public with sharing class OrderShipmentHelper {
	
	public static List<OrderItem> queryForOrderProducts(String orderId){
        List<OrderItem> orderProducts = new List<OrderItem>();

        try{
            orderProducts = [SELECT Id, Product2.Name, Product2.ProductCode, Quantity, UnitPrice, TotalPrice, SBCF_Status__c, Serial_Number__c, Part_Number__c
                             FROM OrderItem WHERE OrderId = :orderId];
        }
        catch(QueryException qe){
            System.debug(qe.getMessage());
        }

        return orderProducts;
    }

    public static List<String> getAllOrderFieldsAPINames(){
        List<String> orderFieldAPINames = new List<String>();

        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Order.fields.getMap();
        
        system.debug('Order Fields: ' + schemaFieldMap.keySet());
        
        for(String fieldAPIName: schemaFieldMap.keySet()){
            orderFieldAPINames.add(fieldAPIName);
        }

        return orderFieldAPINames;
    }

    public static List<OrderProductWrapper> buildOrderProductWrappers(List<OrderItem> orderProducts){
        List<OrderProductWrapper> orderProductWrappers = new List<OrderProductWrapper>();

        for(OrderItem orderProduct: orderProducts){
            OrderProductWrapper wrapper = new OrderProductWrapper(orderProduct);
            orderProductWrappers.add(wrapper);
        }

        return orderProductWrappers;
    }

    public class OrderProductWrapper{

        public OrderItem orderProduct {get;set;}
        public String existingAssetId {get;set;}

        public OrderProductWrapper(OrderItem orderProduct){
            this.orderProduct = orderProduct;
        }
    }
}