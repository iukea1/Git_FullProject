trigger OrderProductItemTrigger on Order_Product_Item__c (after update) {
    AssetTriggerHandler.handleOpisOnAssetGenerate(Trigger.new, Trigger.oldMap);
}