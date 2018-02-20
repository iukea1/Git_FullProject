public with sharing class OrderShipmentHelper {
	
    /*
    *   If order product items exist, creates order product item wrappers from existing order product item wrappers.
    *   If order product items do not exist, creates one order product wrapper for each Order Product quantity
    */
	public static List<OrderProductItemWrapper> buildOrderProductItemWrappers(List<Order_Product_Item__c> existingOrderProductItems, List<OrderItem> orderProducts){
        List<OrderProductItemWrapper> orderProductItemWrappers = new List<OrderProductItemWrapper>();

        if(existingOrderProductItems.size() > 0){
            orderProductItemWrappers.addAll(buildOrderProductItemWrappersFromExistingOrderProductItems(existingOrderProductItems));
        }
        else{
            OrderProductItemWrappers.addAll(createOrderProductItemWrappersForEachOrderProductQuantity(orderProducts));
        }        

        return orderProductItemWrappers;
    } 

    private static List<OrderProductItemWrapper> createOrderProductItemWrappersForEachOrderProductQuantity(List<OrderItem> orderProducts){
        List<OrderProductItemWrapper> orderProductItemWrappers = new List<OrderProductItemWrapper>();

        for(OrderItem orderProduct: orderProducts){
            for(Integer i=0; i>orderProduct.Quantity; i++){
                Order_Product_Item__c orderProductItem = new Order_Product_Item__c();
                orderProductItem.Order_Product__c = orderProduct.Id;
                orderProductItemWrappers.add(new OrderProductItemWrapper(orderProductItem, false, orderProduct.Id));
            }            
        }

        return orderProductItemWrappers;
    } 

    private static List<OrderProductItemWrapper> buildOrderProductItemWrappersFromExistingOrderProductItems(List<Order_Product_Item__c> existingOrderProductItems){
        List<OrderProductItemWrapper> orderProductItemWrappers = new List<OrderProductItemWrapper>();

        for(Order_Product_Item__c orderProductItem: existingOrderProductItems){
            orderProductItemWrappers.add(new OrderProductItemWrapper(orderProductItem, true, orderProductItem.Id));
        }

        return orderProductItemWrappers;
    }

    public static List<Order_Product_Item__c> queryForOrderProductItems(List<OrderItem> orderProducts){
        List<Order_Product_Item__c> orderProductItems = new List<Order_Product_Item__c>();

        Set<Id> orderProductIds = getOrderProductIds(orderProducts);

        try{
            orderProductItems = [SELECT Id, Order_Product__c, Part_Number__c, Serial_Number__c, Status__c FROM Order_Product_Item__c WHERE Order_Product__c IN :orderProductIds];
        }
        catch(QueryException qe){
            System.debug(qe.getMessage());
        }

        return orderProductItems;
    }

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

    public static Boolean determineIsOrderActivated(Order order){
        if(HardwareShipmentController.ACTIVATED_ORDER_STATUS.equalsIgnoreCase(order.Status)){
            return true;
        }

        return false;
    }

    public static Set<Id> getOrderProductIds(List<OrderItem> orderProducts){
        Set<Id> orderProductIds = new Set<Id>();

        for(OrderItem orderProduct: orderProducts){
            if(orderProduct.Id != null){
                orderProductIds.add(orderProduct.Id);
            }
        }

        return orderProductIds;
    }

    public class OrderProductWrapper{

        public OrderItem orderProduct {get;set;}
        public List<ExistingAssetWrapper> existingAssetWrappers {get;set;}
        public List<Order_Product_Item__c> orderProductItems {get;set;}

        public OrderProductWrapper(OrderItem orderProduct){
            this.orderProduct = orderProduct;
            this.existingAssetWrappers = new List<ExistingAssetWrapper>();
        }
    }

    public class OrderProductItemWrapper{
        public Id orderProductId {get;set;}
        public Order_Product_Item__c orderProductItem {get;set;}
        public Boolean isInserted {get;set;}

        public OrderProductItemWrapper(Order_Product_Item__c orderProductItem, Boolean isInserted, Id orderProductId){
            this.orderProductItem = orderProductItem;
            this.isInserted = isInserted;
            this.orderProductId = orderProductId;
        }
    }

    public class ExistingAssetWrapper{
        public String id {get;set;}
        public String serialNumber {get;set;}
        public Asset existingAsset {get;set;}

        public ExistingAssetWrapper(String id, String serialNumber, Asset existingAsset){
            this.id = id;
            this.serialNumber = serialNumber;
            this.existingAsset = existingAsset;
        }
    }
}