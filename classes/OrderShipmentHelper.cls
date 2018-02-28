/**************************************************************************************************************
* Created By: drew.justus@simplus.com
* Created Date: 02/05/2018
* Description: OrderShipmentHelper is a helper class utilized in the HardwareShipmentController and potentially
* the VirtualShipmentController. Some logic of the two pages looked to be the same, so some helper methods were
* extrated into this helper class to reduce code duplication. 
*
* @Test - HardwareShipmentControllerTest - 93%
***************************************************************************************************************/
public with sharing class OrderShipmentHelper {

    public static final Set<String> PRODUCT_CATEGORY_HARDWARE = new Set<String>{ 'Physical' };

    public static Boolean hasInsertedOrderProductItems = false;
	
    /*
    *   If order product items exist, creates order product item wrappers from existing order product item wrappers.
    *   If order product items do not exist, creates one order product wrapper for each Order Product quantity
    */
	public static List<OrderProductItemWrapper> buildOrderProductItemWrappers(List<Order_Product_Item__c> existingOrderProductItems, List<OrderItem> orderProducts){
        List<OrderProductItemWrapper> orderProductItemWrappers = new List<OrderProductItemWrapper>();

        System.debug('Build Order Product Item Wrappers.');

        if(existingOrderProductItems.size() > 0){
            System.debug('Existing Order Product Size is greater than 0. Building order product items wrappers from existing objects');
            orderProductItemWrappers.addAll(buildOrderProductItemWrappersFromExistingOrderProductItems(existingOrderProductItems));
            hasInsertedOrderProductItems = true;
        }
        else{
            System.debug('Existing Order Product Size is 0. Build order product item wrappers from quantity on Order Product.');
            orderProductItemWrappers.addAll(createOrderProductItemWrappersForEachOrderProductQuantity(orderProducts));
        }        

        return orderProductItemWrappers;
    } 

    private static List<OrderProductItemWrapper> createOrderProductItemWrappersForEachOrderProductQuantity(List<OrderItem> orderProducts){
        System.debug('Create Order Product Item Wrappers For Each Order Product Quantity.');
        System.debug('Order Products: ' + orderProducts);

        List<OrderProductItemWrapper> orderProductItemWrappers = new List<OrderProductItemWrapper>();

        for(OrderItem orderProduct: orderProducts){
            for(Integer i=0; i<orderProduct.Quantity; i++){
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
            orderProductItemWrappers.add(new OrderProductItemWrapper(orderProductItem, true, orderProductItem.Order_Product__c));
        }

        return orderProductItemWrappers;
    }

    public static List<Order_Product_Item__c> queryForOrderProductItems(List<OrderItem> orderProducts){
        List<Order_Product_Item__c> orderProductItems = new List<Order_Product_Item__c>();

        Set<Id> orderProductIds = getOrderProductIds(orderProducts);

        try{
            orderProductItems = [SELECT Id, Order_Product__c, Part_Number__c, Serial_Number__c, Status__c, Existing_Asset__c FROM Order_Product_Item__c WHERE Order_Product__c IN :orderProductIds];
        }
        catch(QueryException qe){
            System.debug(qe.getMessage());
        }

        return orderProductItems;
    }

    public static List<OrderItem> queryForOrderProducts(String orderId, Set<String> productForecastCategories){
        List<OrderItem> orderProducts = new List<OrderItem>();

        try{
            orderProducts = [SELECT Id, Product2.Name, Product2.ProductCode, Quantity, UnitPrice, TotalPrice, SBCF_Status__c
                             FROM OrderItem WHERE OrderId = :orderId AND Product2.Forecast_Category__c IN :productForecastCategories];
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

    public static List<OrderProductWrapper> buildOrderProductWrappers(List<OrderItem> orderProducts, List<OrderProductItemWrapper> orderProductItemWrappers){
        System.debug('buildOrderProductWrappers');

        List<OrderProductWrapper> orderProductWrappers = new List<OrderProductWrapper>();

        Map<Id, List<OrderProductItemWrapper>> orderProductIdToListOrderProductItemWrappers = buildOrderProductIdToListOrderProductItemWrappers(orderProductItemWrappers);
        
        for(OrderItem orderProduct: orderProducts){
            List<OrderProductItemWrapper> orderProductItemWrappersRelatedToOrder = orderProductIdToListOrderProductItemWrappers.get(orderProduct.Id);

            if(orderProductItemWrappersRelatedToOrder == null){
                // may want to throw exception
                System.debug('Order product item wrapper list null for order product id: ' + orderProduct.Id);
                orderProductItemWrappersRelatedToOrder = new List<OrderProductItemWrapper>();
            }

            OrderProductWrapper wrapper = new OrderProductWrapper(orderProduct, orderProductItemWrappersRelatedToOrder);
            orderProductWrappers.add(wrapper);
        }

        return orderProductWrappers;
    }

    private static Map<Id, List<OrderProductItemWrapper>> buildOrderProductIdToListOrderProductItemWrappers(List<OrderProductItemWrapper> orderProductItemWrappers){
        Map<Id, List<OrderProductItemWrapper>> orderProductIdToListOrderProductItemWrappers = new Map<Id, List<OrderProductItemWrapper>>();

        System.debug('Build Order Product Id To List Order Product Item Wrappers. ');

        for(OrderProductItemWrapper orderProductItemWrapper: orderProductItemWrappers){
            List<OrderProductItemWrapper> itemsRelatedToOrderProduct = orderProductIdToListOrderProductItemWrappers.get(orderProductItemWrapper.orderProductId);

            if(itemsRelatedToOrderProduct == null){
                itemsRelatedToOrderProduct = new List<OrderProductItemWrapper>();
                orderProductIdToListOrderProductItemWrappers.put(orderProductItemWrapper.orderProductId, itemsRelatedToOrderProduct);
            }

            itemsRelatedToOrderProduct.add(orderProductItemWrapper);
        }

        System.debug('orderProductIdToListOrderProductItemWrappers: ' + orderProductIdToListOrderProductItemWrappers);

        return orderProductIdToListOrderProductItemWrappers;
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

    public static List<Order_Product_Item__c> getOrderProductItemsFromWrappers(List<OrderProductWrapper> orderProductWrappers){
        List<Order_Product_Item__c> orderProductItemsFromWrappers = new List<Order_Product_Item__c>();

        // Precondition Check - orderProductItemWrappers == null
        if(orderProductWrappers == null){
            return orderProductItemsFromWrappers;
        }

        for(OrderProductWrapper orderProductWrapper: orderProductWrappers){
            if(orderProductWrapper.orderProductItems == null){
                continue;
            }

            for(OrderProductItemWrapper orderProductItemWrapper: orderProductWrapper.orderProductItems){
                if(orderProductItemWrapper.orderProductItem == null){
                    continue;
                }

                orderProductItemsFromWrappers.add(orderProductItemWrapper.orderProductItem);
            }
        }

        return orderProductItemsFromWrappers;
    }

    public static Boolean orderProductItemCountMatchesOrderProductQuantity(List<OrderProductWrapper> orderProductWrappers){
        System.debug('orderProductItemCountMatchesOrderProductQuantity');

        Integer orderProductQuantity = 0;
        Integer orderProductItemWrapperCount = 0;

        for(OrderProductWrapper orderProductWrapper: orderProductWrappers){
            if(orderProductWrapper.orderProduct != null && orderProductWrapper.orderProduct.Quantity != null){
                orderProductQuantity = orderProductQuantity + Integer.valueOf(orderProductWrapper.orderProduct.Quantity);
            }

            if(orderProductWrapper.orderProduct != null && orderProductWrapper.orderProductItems != null){
                orderProductItemWrapperCount = orderProductItemWrapperCount += orderProductWrapper.orderProductItems.size();
            }
        }

        System.debug('orderProductQuantity: ' + orderProductQuantity);
        System.debug('orderProductItemWrapperCount: ' + orderProductItemWrapperCount);
        System.debug('Quantity matches: ' + (orderProductQuantity == orderProductItemWrapperCount));

        if(orderProductQuantity == orderProductItemWrapperCount){
            return true;
        }

        return false;
    }

    public class OrderProductWrapper{

        public OrderItem orderProduct {get;set;}
        //public List<ExistingAssetWrapper> existingAssetWrappers {get;set;} // Going to be handled at the Order Product Item level now
        public List<OrderProductItemWrapper> orderProductItems {get;set;}

        public OrderProductWrapper(OrderItem orderProduct, List<OrderProductItemWrapper> orderProductItems){
            this.orderProduct = orderProduct;
            //this.existingAssetWrappers = new List<ExistingAssetWrapper>();
            this.orderProductItems = orderProductItems;
        }
    }

    public class OrderProductItemWrapper{
        public Id orderProductId {get;set;}
        public Order_Product_Item__c orderProductItem {get;set;}
        public Boolean isInserted {get;set;}
        //public Boolean multipleExistingAssetsFound {get;set;}
        //public List<Asset> multipleExistingAssets {get;set;}
        public Asset existingAsset {get;set;}

        public OrderProductItemWrapper(Order_Product_Item__c orderProductItem, Boolean isInserted, Id orderProductId){
            this.orderProductItem = orderProductItem;
            this.isInserted = isInserted;
            this.orderProductId = orderProductId;
        }
    }

    //public class ExistingAssetWrapper{
    //    public String id {get;set;}
    //    public String serialNumber {get;set;}
    //    public Asset existingAsset {get;set;}

    //    public ExistingAssetWrapper(String id, String serialNumber, Asset existingAsset){
    //        this.id = id;
    //        this.serialNumber = serialNumber;
    //        this.existingAsset = existingAsset;
    //    }
    //}
}