public class AssetTriggerHandler implements ITriggerHandler {
    public static final Datetime THIRTY_SECONDS_AGO = System.now().addSeconds(-30);
    Id silverpeakSystemsId='00130000007mEjX';// production Id
    Set<Id> lstHWCPAccount {get;set;} //Provision Decommission Account
    Set<Id> lstSWCPAccount {get;set;} //Provision Decommission Account
    Set<Id> lstTACAccount {get;set;}//ActiveAssetCount
    Map<Id,Account> lstCustomerDateAccount {get;set;} // Customer Date Account
    
    
    public AssetTriggerHandler()
    {
        if(!SilverPeakUtils.IsProduction())
        {
            List<Account> spAccount=[select Id from Account where Name='Silver Peak Systems'];
            System.debug('SilverPeakId'+ spAccount );
            if(spAccount!=null)
            {
                silverpeakSystemsId=spAccount[0].Id;
            }
        }
        System.debug('silverpeakSystemsId'+silverpeakSystemsId);
        lstHWCPAccount= new Set<Id>();
        lstSWCPAccount= new Set<Id>();
        lstTACAccount= new Set<Id>();
        lstCustomerDateAccount= new Map<Id,Account>();
    }
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        System.debug('Before Insert');
        Map<Id,Account> cloudPortalAccs= new Map<Id,Account>();
        List<Asset> lstAsset= new List<Asset>();
        if(newItems!=null && newItems.size()>0)
        {
            List<Asset> lstNewAssets=(List<Asset>)newItems;
            for(Asset newAsset:lstNewAssets)
            {
                if(newAsset.End_of_Maintenance__c== null && newAsset.Product_Quote_Type__c=='NX/VX')
                {
                    lstAsset.add(newAsset);
                }
                if(newAsset.AccountId!=null && newAsset.Status!='Customer Evaluation')
                {
                    newAsset.Is_Customer_Asset__c=true;
                }
                //provision asset
                System.debug('silverpeakSystemsId'+silverpeakSystemsId);
                if(newAsset.AccountId!=silverpeakSystemsId && (newAsset.Product_Quote_Type__c=='EDGECONNECT'|| newAsset.Product_Quote_Type__c=='EC-SP-Term'|| newAsset.Product_Quote_Type__c=='EC-SP-Perpetual'|| newAsset.Product_Quote_Type__c=='EC-SP-Metered') && newAsset.Product_Family__c=='Product')
                {
                    if(newAsset.status !='Owned Eval/NFR' && newAsset.status !='Silver Peak Inventory' && newAsset.status !='Write-Off'&& newAsset.status !='Obsolete RMA Unit–Supp Transferred–WO')
                    { 
                        newAsset.Cloud_Portal_Sync_Status__c='Pending';
                        newAsset.Sync_With_Cloud_Portal__c=true;
                    }
                }
            }
            UpdateEOMDate(lstAsset);
            MakeFinalUpdateToAccount();
            //populateAssetFields(newItems);
            groupAssetsByOrderProduct(lstAsset);
        }
        
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        System.debug('BeforeUpdate');
        List<Asset> lstAsset= new List<Asset>();
        Map<Id,Account> cloudPortalAccs= new Map<Id,Account>();
        if(newItems!=null && newItems.size()>0)
        {
            for(Id assetId:newItems.keyset())
            {
                Asset newAsset=(Asset)newItems.get(assetId);
                Asset oldAsset=(Asset)oldItems.get(assetId);
                if(oldAsset.Ship_Date__c!=newAsset.Ship_Date__c && newAsset.Product_Quote_Type__c=='NX/VX')
                {
                    lstAsset.add(newAsset);
                }
                //decommission asset
                if(newAsset.AccountId == silverpeakSystemsId && oldAsset.AccountId != newAsset.AccountId)
                {
                    if(oldAsset.AccountId!=null)
                    {
                        if(!lstHWCPAccount.contains(oldAsset.AccountId))
                        {
                            lstHWCPAccount.add(oldAsset.AccountId);
                        }
                    }
                } 
                //Trigger Active Asset Count and calculate EC and WAN Op Customer Dates
                if(newAsset.Status!='Customer Evaluation' )
                {
                    if(oldAsset.Contract_Number__c != newAsset.Contract_Number__c || oldAsset.Status != newAsset.Status)
                    {
                        newAsset.Is_Customer_Asset__c=true;
                    }
                    if(oldAsset.AccountId!=newAsset.AccountId )
                    {
                        if( newAsset.AccountId != null)
                        {
                            newAsset.Is_Customer_Asset__c=true;
                        }
                    }
                } 
                //provision an existing asset to another account
                if(oldAsset.AccountId != newAsset.AccountId && oldAsset.AccountId == silverpeakSystemsId && oldAsset.Status =='Silver Peak Inventory')
                {
                    if(newAsset.AccountId!=null && (newAsset.Product_Quote_Type__c=='EDGECONNECT'|| newAsset.Product_Quote_Type__c=='EC-SP-Term'|| newAsset.Product_Quote_Type__c=='EC-SP-Perpetual'|| newAsset.Product_Quote_Type__c=='EC-SP-Metered') && newAsset.Product_Family__c=='Product')
                    {
                        if(newAsset.status !='Owned Eval/NFR' && newAsset.status !='Silver Peak Inventory' && newAsset.status !='Write-Off'&& newAsset.status !='Obsolete RMA Unit–Supp Transferred–WO')
                        { 
                            newAsset.Cloud_Portal_Sync_Status__c='Pending';
                            newAsset.Sync_With_Cloud_Portal__c=true;
                        }
                    }
                }
            }
            UpdateEOMDate(lstAsset);
            MakeFinalUpdateToAccount();
            
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
        if(oldItems.size()>0)
        {
            for(Id assetId:oldItems.keySet())
            {
                
            }
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        System.debug('After Insert' + newItems);
        
        Map<Id,Asset> hardwareECAssetIds= new  Map<Id,Asset>();
        Map<Id,Asset> softwareECBaseAssetIds= new  Map<Id,Asset>();
        Set<Id> setAccIds=new Set<Id>();
        Set<Id> setECAcctIds= new Set<Id>();
        Set<Id> setWanOpAcctIds= new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id assetId : newItems.keyset())
            {
                Asset newAsset= (Asset)newItems.get(assetId);
                if(newAsset.Product_Quote_Type__c=='EDGECONNECT' && newAsset.Product_Family__c=='Product' && (newAsset.Status=='Customer Evaluation' || newAsset.Status=='Customer Owned'))
                {
                    hardwareECAssetIds.put(newAsset.Id,newAsset);
                    setAccIds.add(newAsset.AccountId);
                }
                if(newAsset.Product_Quote_Type__c=='EDGECONNECT' && newAsset.Model__c.startsWith('EC-BASE' ) && newAsset.Product_Family__c=='Virtual Image' && (newAsset.Status=='Customer Evaluation' || newAsset.Status=='Customer Subscription Active'))
                {
                    softwareECBaseAssetIds.put(newAsset.Id,newAsset);
                    setAccIds.add(newAsset.AccountId);
                }
            }
            AddActiveECBaseLicense(hardwareECAssetIds,softwareECBaseAssetIds,setAccIds);
            MakeFinalUpdateToAccount();
             
        }
        //populateAssetFields(newItems.values());
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        System.debug('After Update');
        Map<Id,Asset> hardwareECAssetIds= new  Map<Id,Asset>();
        Map<Id,Asset> softwareECBaseAssetIds= new  Map<Id,Asset>();
        Set<Id> setAccIds=new Set<Id>();
        Set<Id> setECAcctIds= new Set<Id>();
        Set<Id> setWanOpAcctIds= new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id assetId : newItems.keyset())
            {
                Asset newAsset=(Asset)newItems.get(assetId);
                Asset oldAsset=(Asset)oldItems.get(assetId);
                if(oldAsset.AccountId!=newAsset.AccountId || oldAsset.Status!=newAsset.Status)
                {
                    if(newAsset.Product_Quote_Type__c=='EDGECONNECT' && newAsset.Product_Family__c=='Product' && (newAsset.Status=='Customer Evaluation' || newAsset.Status=='Customer Owned'))
                    {
                        hardwareECAssetIds.put(newAsset.Id,newAsset);
                        setAccIds.add(newAsset.AccountId);
                    }
                    
                    if(newAsset.Product_Quote_Type__c=='EDGECONNECT' && newAsset.Model__c.startsWith('EC-BASE' )&& newAsset.Product_Family__c=='Virtual Image' && (newAsset.Status=='Customer Evaluation' || newAsset.Status=='Customer Subscription Active'))
                    {
                        softwareECBaseAssetIds.put(newAsset.Id,newAsset);
                        setAccIds.add(newAsset.AccountId);
                    }
                }
            }
            AddActiveECBaseLicense(hardwareECAssetIds,softwareECBaseAssetIds,setAccIds);
            MakeFinalUpdateToAccount();
            //populateAssetFields(newItems.values());
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        Map<Id,Account> lstCPAcctIds= new Map<Id,Account>();
        for(Id assetId : oldItems.keySet())
        {
            Asset oldAsset=(Asset)oldItems.get(assetId);
            if(oldAsset.Status=='Customer Evaluation' && oldAsset.Model__c.startsWith('EC') && oldAsset.Product_Family__c=='Virtual Image')
            {
                if(!lstSWCPAccount.contains(oldAsset.AccountId))
                {
                    lstSWCPAccount.add(oldAsset.AccountId);
                }
            }  
        }
        MakeFinalUpdateToAccount();
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
        if(newItems!=null)
        {
            for(Id assetId : newItems.keySet())
            {
            }
        }
        MakeFinalUpdateToAccount(); 
    }
    
    
    
    private void MakeFinalUpdateToAccount()
    {
        Set<Id> acctIds= new Set<Id>();
        acctIds.addAll(lstHWCPAccount);
        acctIds.addAll(lstSWCPAccount);
        acctIds.addAll(lstTACAccount);
        acctIds.addAll(lstCustomerDateAccount.keySet());
        List<Account> lstAccountToUpdate = new List<Account>();
        if(acctIds.size()>0)
        {
            for(Id accountId :acctIds)
            {
                Account accountInfo=new Account(Id=accountId);
                if(lstHWCPAccount!=null && lstHWCPAccount.contains(accountId))
                {
                    accountInfo.Sync_with_Cloud_Portal__c=true;
                }
                if(lstSWCPAccount!=null && lstSWCPAccount.contains(accountId))
                {
                    accountInfo.Sync_Virtual_Assets_with_CP__c=true;
                }   
                if(lstTACAccount!=null && lstTACAccount.contains(accountId))
                {
                    accountInfo.Trigger_Active_Asset_Count__c=true;
                }   
                if(lstCustomerDateAccount!=null && lstCustomerDateAccount.containsKey(accountId))
                {
                    Account accData= lstCustomerDateAccount.get(accountId);
                    if(accData.EC_Customer_Date__c!=null)
                    {
                        accountInfo.EC_Customer_Date__c=accData.EC_Customer_Date__c;
                    }
                    if(accData.WAN_OP_Customer_Date__c!=null)
                    {
                        accountInfo.WAN_OP_Customer_Date__c=accData.WAN_OP_Customer_Date__c;
                    }
                }
                lstAccountToUpdate.add(accountInfo);
            }
        }
        if(lstAccountToUpdate.size()>0)
        {
            update lstAccountToUpdate;
        }
    }
    private void AddActiveECBaseLicense(Map<Id,Asset> hardwareECAssetIds,Map<Id,Asset> softwareECBaseAssetIds, Set<Id> setAccIds)
    {
        Map<string,Id> firstECBaseLicense= new  Map<string,Id>();
        List<Asset> lstHardwareAssetToUpdate=new List<Asset>();
        if(hardwareECAssetIds.size()>0)
        {
            List<Asset> lstBaseLicenses=[Select Id,AccountId,Status from Asset where AccountId in:setAccIds and Product2.Family='Virtual Image' and Status in('Customer Subscription Active','Customer Evaluation') and Product2.Name like 'EC-BASE-%' and Product2.Product_Type__c ='EDGECONNECT'];
            if(lstBaseLicenses!=null && lstBaseLicenses.size()>0)
            {
                for(Asset item: lstBaseLicenses)
                {
                    firstECBaseLicense.put(item.AccountId+'|'+item.Status,item.Id);
                }
            }
            for(Id assetId :hardwareECAssetIds.keySet())
            {
                Asset assetData=hardwareECAssetIds.get(assetId);
                string status=assetData.Status=='Customer Evaluation'?'Customer Evaluation':'Customer Subscription Active';
                if(firstECBaseLicense.containsKey(assetData.AccountId+'|'+status))
                {
                    Id baseLicense= firstECBaseLicense.get(assetData.AccountId+'|'+status);
                    Asset hardwareAssetToUpdate = new Asset(Id=assetId,Active_EC_Base_License__c=baseLicense);
                    lstHardwareAssetToUpdate.add(hardwareAssetToUpdate);
                }
            }
        }
        if(softwareECBaseAssetIds.size()>0)
        {
            for(Id assetId : softwareECBaseAssetIds.keySet())
            {
                Asset assetData=softwareECBaseAssetIds.get(assetId);
                string status='Customer Owned';
                if(assetData.Status=='Customer Evaluation')
                    status='Customer Evaluation';
                Set<Id> ids = (new Map<Id, Asset>([Select Id from Asset where AccountId=:assetData.AccountId and Product2.Family='Product' and Status=:status and Product2.Product_Type__c like 'EDGECONNECT' order by CreatedDate desc])).keySet();
                if(ids!=null && ids.size()>0)
                {
                    for(Id hardWareId : ids)
                    {
                        Asset hardwareAssetToUpdate = new Asset(Id=hardWareId,Active_EC_Base_License__c=assetId);
                        lstHardwareAssetToUpdate.add(hardwareAssetToUpdate);
                    }
                    
                }
            }
        }
        if(lstHardwareAssetToUpdate.size()>0)
        {
            update lstHardwareAssetToUpdate;
        }
    }
    private void UpdateEOMDate(List<Asset> lstAssets)
    {
        if(lstAssets!=null && lstAssets.size()>0)
        {
            List<EOMDate__c> EOMDates = [select Model__c, EOMDate__c, ShipDate__c from EOMDate__c];
            for(Asset asset : lstAssets)
            {
                Date minEomDate = Date.newInstance(3000, 01, 01);
                List<EOMDate__c> assetEOMs = new List<EOMDate__c>();
                for(EOMDate__c eom : EOMDates)
                {
                    if(asset.Model__c == eom.Model__c && asset.Ship_Date__c < eom.ShipDate__c)
                    {
                        if(minEomDate > eom.EOMDate__c)
                        {
                            minEomDate = eom.EOMDate__c;
                        }
                    }
                }
                asset.End_of_Maintenance__c = (minEomDate == Date.newInstance(3000, 01, 01) ? null : minEomDate);
            }
        }
    }
    
    
 // Author : Ronald Pascual
 // Date: March 26, 2018
 // Description : To Pull the Status, Part Number, and Serial Number from the Order Product Items to Asset. 
 // -------------------------------------------------------------------------------------------------------
 
 // START of Activation Order task -------@@ 
 // Before Insert Trigger 
	
    private static void populateAssetFields(List<Asset> incomingAssets){
        List<Asset> updateAsset = populateStatusPartAndSerialNumberToAsset(incomingAssets);    
        System.debug('update asset ------ : ' + updateAsset);
        
        if(updateAsset.size()>0){
            update updateAsset;
         }
        
    }
    
    private static List<Asset> populateStatusPartAndSerialNumberToAsset(List<Asset> asset){
        
        List<Asset> AssetList = new List<Asset>();
        
        Set<Id> assetProductEqualToPhysical = assetsWithForecastCategoryEqualToPhysical(asset);        
        System.debug('@@--------   assetProductEqualToPhysical : ' + assetProductEqualToPhysical);
        
        List<Asset> generatedAsset = assetGenerated(assetProductEqualToPhysical);
        System.debug('@@------------ generatedAsset ' + generatedAsset);
        
        for(Asset genAsset: generatedAsset){
            System.debug('asset order product : ' + genAsset.SBQQ__OrderProduct__c);
        }
        
        
        Map<Id, List<Asset>> orderProductToAssets = groupAssetsByOrderProduct(generatedAsset);
        System.debug('@@ -------- orderProductToAssets ' + orderProductToAssets);
    
        Set<Id> orderProductFromAsset =  orderProductToAssets.keySet();
        System.debug('@@------- orderProductFromAsset :' + orderProductFromAsset);
    
        List<Order_Product_Item__c> orderProductItemRelatedToAsset = getAllOrderProductItemsRelatedToOrderProduct(orderProductFromAsset);
        System.debug('@@------- orderProductItemRelatedToAsset :' + orderProductItemRelatedToAsset);

        List<Asset> updateAssets = updateAssetRelatedToOrderProduct(orderProductItemRelatedToAsset, orderProductToAssets);
        System.debug('@@ ----- Asset to update :  ' + updateAssets);
    
        //if(updateAssets.size()>0){
        //    update updateAssets;
        //}
        
        //List<Order_Product_Item__c> updateOrderProductItem = updateOrderProductRelatedToAsset(orderProductItemRelatedToAsset, updateAssets);
    	//System.debug('@@--------- updateOrderProductItem : ' + updateOrderProductItem);
        
        //if(updateOrderProductItem.size()>0){
        //    update updateOrderProductItem;
        //}
        
        //return updateAssets;
        return AssetList;

    }
    
    private static Set<Id> assetsWithForecastCategoryEqualToPhysical(List<Asset> incomingAsset){
    //private static List<Asset> assetsWithForecastCategoryEqualToPhysical(List<Asset> incomingAsset){
        List<Asset> assetProductEqualToPhysical = new List<Asset>();
 		Set<Id> assetIds = new Set<Id>();
     
            
        for(Asset asset: incomingAsset){
            //if(asset.Product2.Forecast_Category__c == 'Physical'){
            	System.debug('Assets -------@@:' + asset);
            	System.debug('Assets product forecast category :' + asset.Product2.Forecast_Category__c);
                assetProductEqualToPhysical.add(asset);
            	assetIds.add(asset.Id);
            //}	
            // 
        }
       
        return assetIds;	
    }
    
    private static List<Asset> assetGenerated(Set<Id> assetId){
        List<Asset> generatedAsset = new List<Asset>();
        try {
            generatedAsset = [SELECT Id, SBQQ__OrderProduct__c FROM Asset WHERE Id IN: assetId];
        }
        catch(QueryException qe){
            System.debug(qe.getMessage());
        }
        return generatedAsset;
    }
    
    //Map<Id, List<Asset>> orderProductToAssets = groupAssetsByOrderProduct(assetProductEqualToPhysical);
    
    private static Map<Id, List<Asset>> groupAssetsByOrderProduct(List<Asset> assetProductEqualToPhysical){
         Map<Id, List<Asset>> orderProductToAssets = new Map<Id, List<Asset>>();
         //Map<Id, Asset> QuoteLinetoAssetMap = new Map<Id, Asset>();
         Map<String, Asset> SerialNumtoAssetMap = new Map<String, Asset>();
         List<Asset> assetRelatedToOrderProducts = new List<Asset>();
         Set<Id> AssetQuoteLineIds = new Set<Id>();
         Set<Id> OrderItemIds = new Set<Id>();
         Set<Id> OrderProductItemIds = new Set<Id>();
         /*
         for(Asset asset: assetProductEqualToPhysical){
            System.debug('@@----- asset.SBQQ__OrderProduct__c :' + asset.SBQQ__OrderProduct__c);
             
            if(asset.SBQQ__OrderProduct__c == null){
                continue;
            }
    
            List<Asset> assetRelatedToOrderProducts = orderProductToAssets.get(asset.SBQQ__OrderProduct__c);
    
            if(assetRelatedToOrderProducts == null){
                assetRelatedToOrderProducts = new List<Asset>();
                orderProductToAssets.put(asset.SBQQ__OrderProduct__c, assetRelatedToOrderProducts);
            }
    
            assetRelatedToOrderProducts.add(asset);
    
         }
        */
        
        //Loop through the Assets
        for(Asset a: assetProductEqualToPhysical){
            
            //assetRelatedToOrderProducts = new List<Asset>();
            orderProductToAssets.put(a.SBQQ__QuoteLine__c, assetRelatedToOrderProducts);
            
            //Get Quote Line Ids
            if(a.SBQQ__QuoteLine__c != NULL){
                AssetQuoteLineIds.add(a.SBQQ__QuoteLine__c);
            }
            
            //Query Order Products where Quote Line Ids
            for(OrderItem oi: [SELECT Id, SBQQ__QuoteLine__c FROM OrderItem WHERE SBQQ__QuoteLine__c =: AssetQuoteLineIds]){
                OrderItemIds.add(oi.id);
            }
            
            //Query Order Product Items, order by created by
            for(Order_Product_Item__c op: [SELECT Id, Status__c, Part_Number__c, Serial_Number__c FROM Order_Product_Item__c WHERE Order_Product__c =: OrderItemIds ORDER BY CreatedDate DESC ]){
                //Put in list
                //Loop through Asset again and populate
                /*
                a.Status = op.Status__c;
                a.Part_Number__c = op.Part_Number__c;
                a.SerialNumber = op.Serial_Number__c;
                assetRelatedToOrderProducts.add(a);
                
                SerialNumtoAssetMap.put(op.Serial_Number__c, op);
                */
            }
            
            /*
            if(a.Serial_Number__c == SerialNumtoAssetMap.get(a.Serial_Number__c).Serial_Number__c){
                
            }
            */
            
            
        }
        
         return orderProductToAssets;
    }
        
    private static List<Order_Product_Item__c> getAllOrderProductItemsRelatedToOrderProduct(Set<Id> orderProductFromAsset){
        List<Order_Product_Item__c> orderProductItemsRelatedToOrderProduct = new List<Order_Product_Item__c>();
        
        try{
            orderProductItemsRelatedToOrderProduct = [SELECT Id, Status__c, Serial_Number__c, Part_Number__c, Order_Product__c FROM  Order_Product_Item__c WHERE Order_Product__c IN : orderProductFromAsset];
        }
        catch(QueryException qe){
            System.debug(qe.getMessage());
        }
    
        return orderProductItemsRelatedToOrderProduct;
    }    
    
    //List<Asset> updateAssets = updateAssetRelatedToOrderProduct(orderProductItemRelatedToAsset, orderProductToAssets);
    
    private static List<Asset> updateAssetRelatedToOrderProduct(List<Order_Product_Item__c> orderProductItemRelatedToAsset, Map<Id, List<Asset>> orderProductToAssets){
    
        List<Asset> updateAssets = new List<Asset>();
    
        for(Order_Product_Item__c orderProdItem: orderProductItemRelatedToAsset){
            
            List<Asset> assetList = orderProductToAssets.get(orderProdItem.Order_Product__c);            
            System.debug('Assets related to Order Product : ' + assetList);
            
             for(Asset asset: assetList){
                asset.SerialNumber = orderProdItem.Serial_Number__c;
                asset.Part_Number__c = orderProdItem.Part_Number__c;
                asset.Status = orderProdItem.Status__c;
                updateAssets.add(asset);
             }		 
            
        }
    
        return updateAssets;
    }   
     
    private static List<Order_Product_Item__c> updateOrderProductRelatedToAsset(List<Order_Product_Item__c> orderProductItemRelatedToAsset, List<Asset> updatedAssets){
    
        List<Order_Product_Item__c> updateOrderProductItem = new List<Order_Product_Item__c>();
    
        for(Order_Product_Item__c orderProdItem: orderProductItemRelatedToAsset){
            System.debug('Assets related to Order Product : ' + updatedAssets);
             for(Asset asset: updatedAssets){
                orderProdItem.Asset__c = asset.Id;
                updateOrderProductItem.add(orderProdItem);
             }		 
        }
    
        return updateOrderProductItem;
    }
    
    // ------------- Asset override method ---------------//
    
    
    
    private static void updateTheExistingAsset(List<Asset> incomingAssets){
        List<Asset> deleteAssets = new LIst<Asset>();
		Set<Id> generatedAssetSetOfIds =  generatedAssetIds(incomingAssets);
        
        if(generatedAssetSetOfIds == null){
            System.debug('There are no asset generated upon activation of order' + generatedAssetSetOfIds);
            return;
        }
        List<Asset> generatedAssetToBeDeleted = generatedAssetToDelete(incomingAssets);
        List<Asset> assetToOverride = overrideAsset(generatedAssetSetOfIds);
        
        if(assetToOverride.size()>0){
            update assetToOverride;
            
            for(Asset assetOverride: assetToOverride){
                for(Asset generatedAsset: generatedAssetToBeDeleted){
                    if(generatedAsset.Part_Number__c == assetOverride.Part_Number__c && 
                       generatedAsset.SerialNumber == assetOverride.SerialNumber && 
                       generatedAsset.Status == assetOverride.Status){

                       deleteAssets.add(generatedAsset);
                    }
                }
        	}
            
            System.debug('delete Asset : ' + deleteAssets);
            
        }
        
        
        
        
    }
    
    private static Set<Id> generatedAssetIds(List<Asset> incomingAssets){
        //List<Asset> assetToDelete = new List<Asset>();
        Set<Id> generatedAssetSetOfIds = new Set<Id>();
        //List<Asset> updatedAssetsRelatedToOrderProdItems = populateStatusPartAndSerialNumberToAsset(incomingAssets);
        
        if(incomingAssets == null){
            System.debug('There are no incoming asset that was related to order product item. ');
        }
        
        for(Asset updatedAssets: incomingAssets){
            generatedAssetSetOfIds.add(updatedAssets.Id);
        }
        
        return generatedAssetSetOfIds;
    }
    
    private static List<Asset> generatedAssetToDelete(List<Asset> incomingAssets){
        List<Asset> assetToDelete = new List<Asset>();
        List<Asset> updatedAssetsRelatedToOrderProdItems = populateStatusPartAndSerialNumberToAsset(incomingAssets);
        
        if(updatedAssetsRelatedToOrderProdItems == null){
            System.debug('There are no incoming asset that was related to order product item. ');
        }
        
        for(Asset updatedAssets: updatedAssetsRelatedToOrderProdItems){
            assetToDelete.add(updatedAssets);
        }
        
        return assetToDelete;
    }
    
    private static List<Asset> overrideAsset(Set<Id> orderProductAsset){
        
        List<Asset> updateExistingAssetList = new List<Asset>();
    
        for(Order_Product_Item__c orderProdItem: [SELECT Id, Existing_Asset__c, 
                                                    Asset__r.Part_Number__c,
                                                    Asset__r.SerialNumber,
                                                    Asset__r.Status
                                                    FROM Order_Product_Item__c
                                                    WHERE Asset__c IN: orderProductAsset]){
    		
            System.debug('Order Product Item with Existing Asset : ' +  orderProdItem);
                                                        
            if(orderProdItem.Existing_Asset__c != null){
                Asset existingAsset = new Asset();
                existingAsset.Id = orderProdItem.Existing_Asset__c;
                existingAsset.Part_Number__c = orderProdItem.Asset__r.Part_Number__c;
                existingAsset.SerialNumber = orderProdItem.Asset__r.SerialNumber;
                existingAsset.Status = orderProdItem.Asset__r.Status;
                updateExistingAssetList.add(existingAsset);
                
                System.debug('Updated Existing Asset : ' +  updateExistingAssetList);
            }
            
        }
    
            if(!updateExistingAssetList.isEmpty()){
                update updateExistingAssetList;
            }
        
            return updateExistingAssetList;
	}
    
}