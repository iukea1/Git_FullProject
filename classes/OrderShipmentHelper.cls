public with sharing class OrderShipmentHelper {
	
	public static List<OrderItem> queryForOrderProducts(String orderId){
        List<OrderItem> orderProducts = new List<OrderItem>();

        try{
            orderProducts = [SELECT Id, Product2.Name, Product2.ProductCode, Quantity, UnitPrice, TotalPrice FROM OrderItem WHERE OrderId = :orderId];
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
}