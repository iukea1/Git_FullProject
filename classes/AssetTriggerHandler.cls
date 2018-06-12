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
        System.debug('Asset trigger : before insert ---------------> ' + newItems);
        if(newItems!=null && newItems.size()>0)
        {
            List<Asset> lstNewAssets=(List<Asset>)newItems;
            for(Asset newAsset:lstNewAssets)
            {
                if(newAsset.End_of_Maintenance__c== null && newAsset.Product_Quote_Type__c=='NX/VX' && newAsset.Product_Family__c=='Product')
                {
                    newAsset.End_of_Maintenance__c=newAsset.Ship_Date__c!=null?newAsset.Ship_Date__c.addYears(5):null;
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
            //UpdateEOMDate(lstAsset);
            MakeFinalUpdateToAccount();
            //populateAssetFields(newItems);
            System.debug('Asset trigger : before insert : lstAsset ---------------> ' + lstAsset);
            //groupAssetsByOrderProduct(lstAsset);
            updateAssetStatus((List<Asset>)newItems);
            retrieveAssetSerials(lstAsset);
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
                if(oldAsset.Ship_Date__c!=newAsset.Ship_Date__c && newAsset.Product_Quote_Type__c=='NX/VX' && newAsset.Product_Family__c=='Product')
                {
                    newAsset.End_of_Maintenance__c=newAsset.Ship_Date__c!=null?newAsset.Ship_Date__c.addYears(5):null;
                    //lstAsset.add(newAsset);
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
            //UpdateEOMDate(lstAsset);
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
        List<Asset> virtualAssets = new List<Asset>();
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
                
                if(newAsset.Product_Family__c=='Virtual Image') {
                    virtualAssets.add(newAsset);
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
        DeleteGeneratedAsset(newItems.values());
        populatePOCIdInAsset(newItems.values());
        generateVirtualSerialNumber(virtualAssets);

        System.debug('updateShipmentDateOfAsset --------------> ' + newItems.values());
        updateShipmentDateOfAsset(newItems.values());
        
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        System.debug('After Update');
        Map<Id,Asset> hardwareECAssetIds= new  Map<Id,Asset>();
        Map<Id,Asset> softwareECBaseAssetIds= new  Map<Id,Asset>();
        Set<Id> setAccIds=new Set<Id>();
        Set<Id> setECAcctIds= new Set<Id>();
        Set<Id> setWanOpAcctIds= new Set<Id>();
        List<Asset> lstLicenseAssets= new List<Asset>();
        List<Asset> virtualAssets = new List<Asset>();
        
        if(newItems!=null && newItems.size()>0)
        {
            for (Id assetId : newItems.keyset())
            {
                Asset newAsset=(Asset)newItems.get(assetId);
                Asset oldAsset=(Asset)oldItems.get(assetId);
                if(newAsset.Product_Family__c=='Virtual Image')
                {
                    if(newAsset.Status!=null && newAsset.Status=='Customer Owned' && newAsset.Status!=oldAsset.Status)
                        lstLicenseAssets.add(newAsset);
                    else if(newAsset.Status!=null && newAsset.SBQQ__CurrentSubscription__c!=null && (newAsset.Status!=oldAsset.Status || (newAsset.SBQQ__CurrentSubscription__c!=oldAsset.SBQQ__CurrentSubscription__c)) && (newAsset.Status=='Customer Evaluation'|| newAsset.Status=='Customer Subscription Active' || newAsset.Status=='Customer Subscription')) {
                        lstLicenseAssets.add(newAsset);
                    }
                    if(newAsset.Is_Selected_For_Renewal__c && !oldAsset.Is_Selected_For_Renewal__c) virtualAssets.add(newAsset);
                }
                    
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
            GenerateLicense(lstLicenseAssets);
            generateVirtualSerialNumber(virtualAssets);
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
    
    private void GenerateLicense(List<Asset> lstAssets)
    {
        List<License__c> licenses = new List<License__c>();
        Set<Id> assetIds= new Set<Id>();
        for(Asset asset:lstAssets)
        {
            // added a debug log for testing purposes @Ronald
            System.debug('asset.Product_Quote_Type__c : ' + asset.Product_Quote_Type__c);
            System.debug('asset.Model__c : ' + asset.Model__c);
            // ----------------- @@ 
            integer quantity=1;
            License__c lic =new License__c(AssetId__c=asset.Id,Start_Date__c=asset.Ship_Date__c,Model__c=asset.Model__c);
            if(asset.Model__c=='GX-V' || asset.Product_Category__c=='GMS')
                quantity=Integer.valueOf(asset.GMS_Nodes__c);
            lic.Quantity__c=quantity;
            if(asset.status=='Customer Owned')
            {
                lic.License_Expiration__c=null;
            }
            if(asset.status=='Customer Subscription Active' || asset.status=='Customer Subscription')
            {
                lic.License_Expiration__c=asset.Subscription_End_Date__c;
            }
            // added the not equal to null condition @Ronald
            if(asset.Model__c != null){
              if(asset.Product_Quote_Type__c=='NX/VX' && !asset.Model__c.startsWith('UNITY CLOUD') ) 
                    assetIds.add(asset.id);
                licenses.add(lic);  
            }
                
        }
        if(licenses.size()>0)
        {
           insert licenses; 
           System.debug('licenses ' +licenses);
           List<Id> licenseIds = new  List<Id>();
          
           for(License__c lic:licenses)
           {
               if(assetIds.size()>0 && assetIds.contains(lic.AssetId__c))
                   licenseIds.add(lic.Id);
           }
           VirtualAssetManager.encryptLicenses(licenseIds);
        }
            
        
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
    /*private void UpdateEOMDate(List<Asset> lstAssets)
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
    }*/
    
    
 // Author : Ronald Pascual
 // Date: March 26, 2018
 // Description : To Pull the Status, Part Number, and Serial Number from the Order Product Items to Asset. 
 // -------------------------------------------------------------------------------------------------------
 
 // START of Activation Order task -------@@ 
 // Before Insert Trigger 
    private static void populatePOCIdInAsset(List<Asset> assets){
        
        Set<Id> assetIds = new Set<Id>();
        List<Asset> assetWithPocId = new List<Asset>();
        
        for(Asset asset: assets){
            assetIds.add(asset.id);
        }
        
        List<Asset> assetToUpdate = [SELECT Id, Name, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.POC_ID__c FROM Asset WHERE Id IN: assetIds];
        
        for(Asset a: assetToUpdate){
            if(a.SBQQ__QuoteLine__r.POC_ID__c != null){
                a.POC_ID__c = a.SBQQ__QuoteLine__r.POC_ID__c;
                assetWithPocId.add(a);
            }
        }
        
        if(assetWithPocId.size()>0){
            update assetWithPocId;
        }
        
    }
    
    
    //Map<Id, List<Asset>> orderProductToAssets = groupAssetsByOrderProduct(assetProductEqualToPhysical);
    
    private static Map<Id, List<Asset>> groupAssetsByOrderProduct(List<Asset> assetProductEqualToPhysical){
         Map<Id, List<Asset>> orderProductToAssets = new Map<Id, List<Asset>>();
         //Map<Id, Asset> QuoteLinetoAssetMap = new Map<Id, Asset>();
         Map<Integer, Order_Product_Item__c> NumtoOrderProductItemMap = new Map<Integer, Order_Product_Item__c>();
         List<Asset> assetRelatedToOrderProducts = new List<Asset>();
         List<Order_Product_Item__c> OrderProductItemstoUpdate = new List<Order_Product_Item__c>();
         Set<Id> AssetQuoteLineIds = new Set<Id>();
         Set<Id> OrderItemIds = new Set<Id>();
         Set<Id> OrderProductItemIds = new Set<Id>();
         Set<Order_Product_Item__c> OrderProductItemstoUpdateSet = new Set<Order_Product_Item__c>();
         Integer OrderQuantity;
         Integer counter = 1;
         Integer counter2 = 1;
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
            for(OrderItem oi: [SELECT Id, SBQQ__QuoteLine__c, Quantity FROM OrderItem WHERE SBQQ__QuoteLine__c =: AssetQuoteLineIds]){
                OrderItemIds.add(oi.id);
                OrderQuantity = Integer.valueOf(oi.Quantity);
            }
            
            //Query Order Product Items, order by created by
            for(Order_Product_Item__c op: [SELECT Id, Status__c, Part_Number__c, Serial_Number__c, Asset__c FROM Order_Product_Item__c WHERE Order_Product__c =: OrderItemIds ORDER BY CreatedDate DESC ]){
                //Put in list
                //Loop through Asset again and populate
                
                //counter = 1;
                NumtoOrderProductItemMap.put(counter, op);
                counter++;
                /*
                a.Status = op.Status__c;
                a.Part_Number__c = op.Part_Number__c;
                a.SerialNumber = op.Serial_Number__c;
                assetRelatedToOrderProducts.add(a);
                */
                
                //SerialNumtoAssetMap.put(op.Serial_Number__c, op);
                //op.Asset__c = a.id;
                //OrderProductItemstoUpdateSet.add(op);
                
            }
            
            //System.debug('OrderProductItemstoUpdateSet values = ' + OrderProductItemstoUpdateSet);
            
            System.debug('NumtoOrderProductItemMap values = ' + NumtoOrderProductItemMap);
            /*
            if(a.Serial_Number__c == SerialNumtoAssetMap.get(a.Serial_Number__c).Serial_Number__c){
                
            }
            */
            
            
        }
        
        //Loop on Asset again
        for(Asset a: assetProductEqualToPhysical){
            //counter2 = 1;
            System.debug('counter2 value = ' + counter2);
            if(!NumtoOrderProductItemMap.isEmpty()){
                
                if(counter2 <= OrderQuantity){
                a.Status = NumtoOrderProductItemMap.get(counter2).Status__c;
                a.Part_Number__c = NumtoOrderProductItemMap.get(counter2).Part_Number__c;
                a.SerialNumber = NumtoOrderProductItemMap.get(counter2).Serial_Number__c;
                assetRelatedToOrderProducts.add(a);
                counter2++;
                }
            }

            
        }
        
        if(!OrderProductItemstoUpdateSet.isEmpty()){
            update new List<Order_Product_Item__c>(OrderProductItemstoUpdateSet);
        }
        
        System.debug('assetRelatedToOrderProducts values = ' + assetRelatedToOrderProducts);
        
        return orderProductToAssets;
    }
    
    /*
    Method to Delete the newly generated Asset if there is already an existing Asset on the Order Product Item
    */
    
    private static void DeleteGeneratedAsset (List<Asset> AssetList){
        
        System.debug('DeleteGeneratedAsset List = ' + AssetList);
        
        List<Asset> ToDeleteAssets = new List<Asset>();
        Set<Id> AssetQuoteLineIds = new Set<Id>();
        Set<Id> OrderItemIds = new Set<Id>();
        Set<Id> OrderProductItemIds = new Set<Id>();
        Set<Id> ExistingAssetIds = new Set<Id>();
        Set<Id> toDeleteAssetIds = new Set<Id>();
        Map<Id, Order_Product_Item__c> ExistingAssetOrderProductMap = new Map<Id, Order_Product_Item__c>();
        List<Asset> toUpdateExistingAsset = new List<Asset>();
        List<Order_Product_Item__c> OrderProductItemstoUpdate = new List<Order_Product_Item__c>();
        Set<Order_Product_Item__c> OrderProductItemstoUpdateSet = new Set<Order_Product_Item__c>();
        Map<Id, Order_Product_Item__c> ToUpdateOrderProductsMap = new Map<Id, Order_Product_Item__c>();
        Map<Id, Order_Product_Item__c> ToExistingUpdateOrderProductsMap = new Map<Id, Order_Product_Item__c>();
        Map<Id, Asset> toUpdateExistingAssetMap = new Map<Id, Asset>();
        Map<Id, Asset> ToDeleteAssetsMap = new Map<Id, Asset>();
        
        
        
        //Loop through the Assets
        for(Asset a: AssetList){
            
            //Get Quote Line Ids
            if(a.SBQQ__QuoteLine__c != NULL){
                AssetQuoteLineIds.add(a.SBQQ__QuoteLine__c);
            }
            
            //Query Order Products where Quote Line Ids
            for(OrderItem oi: [SELECT Id, SBQQ__QuoteLine__c, Quantity FROM OrderItem WHERE SBQQ__QuoteLine__c =: AssetQuoteLineIds]){
                OrderItemIds.add(oi.id);
            }
            
            for(Order_Product_Item__c op: [SELECT Id, Status__c, Part_Number__c, Serial_Number__c, Asset__c, Existing_Asset__c FROM Order_Product_Item__c WHERE Order_Product__c =: OrderItemIds]){
                
                if(op.Existing_Asset__c != NULL){
                        
                    //Get the Existing Assets and Map with the Order Product Item
                    ExistingAssetOrderProductMap.put(op.Existing_Asset__c, op);
                    toDeleteAssetIds.add(op.Asset__c);
                    op.Asset__c = NULL;
                    ToExistingUpdateOrderProductsMap.put(op.id, op);
                }
                
                if(op.Asset__c == NULL && op.Existing_Asset__c == NULL){
                    op.Asset__c = a.id;
                    //OrderProductItemstoUpdateSet.add(op);
                    ToUpdateOrderProductsMap.put(op.id, op);
                }
            }
            
            //Query for the Existing Assets and update the Part Number, Serial Number and Status fields with values from Order Product Item
            for(Asset AssetEx: [SELECT Id, Part_Number__c, SerialNumber, Status FROM Asset WHERE Id =: ExistingAssetOrderProductMap.keySet()]){
                
                //Populate the Part Number, Serial Number and Status fields
                AssetEx.Status = ExistingAssetOrderProductMap.get(AssetEx.id).Status__c;
                AssetEx.Part_Number__c = ExistingAssetOrderProductMap.get(AssetEx.id).Part_Number__c;
                AssetEx.SerialNumber = ExistingAssetOrderProductMap.get(AssetEx.id).Serial_Number__c;
                //toUpdateExistingAsset.add(AssetEx);
                toUpdateExistingAssetMap.put(AssetEx.id, AssetEx);
            }
            
            for(Asset AssetDel : [SELECT Id, Part_Number__c, SerialNumber, Status FROM Asset WHERE Id =: toDeleteAssetIds]){
                
                //Add to List for Deletion
                //ToDeleteAssets.add(AssetDel);
                ToDeleteAssetsMap.put(AssetDel.id, AssetDel);
            }
            
            System.debug('ToUpdateOrderProductsMap List = ' + ToUpdateOrderProductsMap);
            System.debug('toUpdateExistingAssetMap List = ' + toUpdateExistingAssetMap);
            System.debug('ToDeleteAssetsMap List = ' + ToDeleteAssetsMap);
            
            /*
            if(!OrderProductItemstoUpdateSet.isEmpty()){
                update new List<Order_Product_Item__c>(OrderProductItemstoUpdateSet);
            }
            */
            
            if(!ToUpdateOrderProductsMap.isEmpty()){
                update ToUpdateOrderProductsMap.values();
            }
            
            if(!ToExistingUpdateOrderProductsMap.isEmpty()){
                update ToExistingUpdateOrderProductsMap.values();
            }
            
            /*
            if(!toUpdateExistingAsset.isEmpty()){
                update toUpdateExistingAsset;
            }
            
            if(!ToDeleteAssets.isEmpty()){
                delete ToDeleteAssets;
            }*/
            
            if(!toUpdateExistingAssetMap.isEmpty()){
                update toUpdateExistingAssetMap.values();
            }
            
            if(!ToDeleteAssetsMap.isEmpty()){
                //delete ToDeleteAssetsMap.values();
                Database.delete(ToDeleteAssetsMap.values(), false);
            }
            
            
        }
    }
    
    
    private static void updateShipmentDateOfAsset(List<Asset> incomingAsset){
        Map<Id, List<Asset>> quoteToAsset = new Map<Id, List<Asset>>();
        List<Asset> updateAsset = new List<Asset>();
        Set<Id> assetIds = new Set<Id>();
        
        for(Asset asset: incomingAsset){
           assetIds.add(asset.Id);
        }
        
        List<Asset> assetlst = [SELECT Id, SBQQ__QuoteLine__r.SBQQ__Quote__c FROM Asset WHERE Id IN: assetIds];
        System.debug('assetlst ----------------> ' + assetlst);
        System.debug('quoteToAsset -------------------> ' + quoteToAsset);
        for(Asset a: assetlst){
            if(quoteToAsset.containsKey(a.SBQQ__QuoteLine__r.SBQQ__Quote__c)){
                 List<Asset> assetToUpdateTheShipmentDate = quoteToAsset.get(a.SBQQ__QuoteLine__r.SBQQ__Quote__c);
                 assetToUpdateTheShipmentDate.add(a);
            }
     
            else{
                 quoteToAsset.put(a.SBQQ__QuoteLine__r.SBQQ__Quote__c, new List<Asset>{a});
            }
        }
        
        Set<Id> assetQuoteIds = quoteToAsset.keySet();
        System.debug('asset quote ids' + assetQuoteIds);
        
        Order orderlst = queryForOrder(assetQuoteIds);
        System.debug('order list ' + orderlst);
      
        if(orderlst != null && orderlst.ActivatedDate != null){
            for(Asset asset: assetlst){
                DateTime dt = orderlst.ActivatedDate;
                Date shipDate = dt.date();
                asset.Ship_Date__c = shipDate;
                updateAsset.add(asset);
            }
        }
        
        
        if(updateAsset.size()>0){
            update updateAsset;
        }
    }
    private static Order queryForOrder(Set<Id> assetQuoteIds){
        Order parentOrder = new Order();
        
        try{
            parentOrder = [SELECT Id, ActivatedDate, SBQQ__Contracted__c, SBQQ__Quote__c FROM Order WHERE SBQQ__Quote__c IN: assetQuoteIds AND SBQQ__Contracted__c =TRUE LIMIT 1];
        }
        catch(QueryException qe){
            System.debug(qe.getMessage());
        }
        
        System.debug('Assets related to Subscriptions: ' + parentOrder);
        
        return parentOrder;
    }
    
    /*private static void updateAssetStatus(List<Asset> assetStatusToUpdate){
        
        Set<Id> assetIds = new Set<Id>();
        List<Asset> updateAsset = new List<Asset>();
        Map<Id, List<Asset>> quoteToAsset = new Map<Id, List<Asset>>();
        
        
        for(Asset asset: assetStatusToUpdate){
           assetIds.add(asset.Id);
        }
        
        List<Asset> assetlst = [SELECT Id, Name, Product2.Name, SBQQ__QuoteLine__r.POC_ID__c, SBQQ__QuoteLine__r.SBQQ__Quote__c, SBQQ__OrderProduct__c FROM Asset WHERE Id IN: assetIds];
        System.debug('ORDER PRODUCT ON CREATE ------>>> ' + assetlst);
        for(Asset a: assetlst){
            
            if(a.SBQQ__QuoteLine__r.POC_ID__c != null && a.SBQQ__QuoteLine__r.POC_ID__c != 0){
                a.Status = 'Customer Evaluation';
            }
            if(a.Product2.Name.contains('Asset') && a.Product2.Name != null){
                a.Status = 'Customer Subscription';  
            }
            updateAsset.add(a);
            
        }
        if(updateAsset.size()>0){
           update updateAsset; 
        }
    }*/
    private static void updateAssetStatus(List<Asset> assetStatusToUpdate){
        System.debug('updateAssetStatus -----------> ' + assetStatusToUpdate);
        Set<Id> quoteLineId = new Set<Id>();
        Set<Id> productId = new Set<Id>();
        
        for(Asset asset: assetStatusToUpdate){
           quoteLineId.add(asset.SBQQ__QuoteLine__c);
           productId.add(asset.Product2Id);
        }
        
        Map<Id, SBQQ__QuoteLine__c> qline = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, POC_ID__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineId]);
        Map<Id, Product2> prodMap = new Map<Id, Product2>([SELECT Id, Name FROM Product2 WHERE Id IN :productId]);
        
        for(Asset a: assetStatusToUpdate){
            SBQQ__QuoteLine__c ql = qline.get(a.SBQQ__QuoteLine__c);
            Product2 p2 = prodMap.get(a.Product2Id);
            
            if(ql != null && ql.POC_ID__c != null && ql.POC_ID__c != 0){
                a.Status = 'Customer Evaluation';
            }
            if(p2 != null && p2.Name.contains('Asset') && p2.Name != null){
                a.Status = 'Customer Subscription';  
            }
            if(a.Product_Category__c == 'Appliance') {
                a.Status = 'Customer Owned'; 
            }
            if(a.Status == null) {
                a.Status = 'Customer Subscription'; 
            }
            //updateAsset.add(a);
        }
    }

    private static void retrieveAssetSerials(List<Asset> newAssets) {
        Set<Id> qLineCollect = new Set<Id>();
        for(Asset a : newAssets) {
            qLineCollect.add(a.SBQQ__QuoteLine__c);
        }
        qLineCollect.remove(null);

        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE Id IN :qLineCollect]);
        Set<Id> quoteIdCollect = new Set<Id>();
        for(SBQQ__QuoteLine__c ql : quoteLineMap.values()) {
            quoteIdCollect.add(ql.SBQQ__Quote__c);
        }

        Map<Id, Map<Id, Order_Product_Item__c>> opiToQuote = new Map<Id, Map<Id, Order_Product_Item__c>>();
        for(Order_Product_Item__c opi : [SELECT Id, Existing_Asset__c,Serial_Number__c,Part_Number__c, Order_Product__r.SBQQ__QuoteLine__r.SBQQ__Quote__c, Status__c FROM Order_Product_Item__c WHERE Order_Product__r.SBQQ__QuoteLine__r.SBQQ__Quote__c IN :quoteIdCollect]) {
            if(!opiToQuote.containsKey(opi.Order_Product__r.SBQQ__QuoteLine__r.SBQQ__Quote__c)) {
                opiToQuote.put(opi.Order_Product__r.SBQQ__QuoteLine__r.SBQQ__Quote__c, new Map<Id, Order_Product_Item__c>());
            }
            opiToQuote.get(opi.Order_Product__r.SBQQ__QuoteLine__r.SBQQ__Quote__c).put(opi.Id, opi);
        }
        List<Order_Product_Item__c> opiIdDone = new List<Order_Product_Item__c>();
        
        for(Asset a : newAssets) {
            Id quoteId = quoteLineMap.get(a.SBQQ__QuoteLine__c).SBQQ__Quote__c;
            Map<Id, Order_Product_Item__c> opitemMap = opiToQuote.get(quoteId);
            if(opitemMap.size() > 0) {
                a.Name = opitemMap.values()[0].Serial_Number__c;
                a.SerialNumber = opitemMap.values()[0].Serial_Number__c;
                a.Part_Number__c = opitemMap.values()[0].Part_Number__c;
                a.Status = 'Customer Owned';
                
                Order_Product_Item__c opiUp = opiToQuote.get(quoteId).get(opitemMap.values()[0].Id);
                opiUp.Asset__c = a.Id;
                opiIdDone.add(opiUp);
                opiToQuote.get(quoteId).remove(opitemMap.values()[0].Id);
            }
        }
        System.debug('opiIdDone -------------------------> ' + opiIdDone);
        update opiIdDone;
    }
    
    private static void generateVirtualSerialNumber(List<Asset> newAssets) {
        List<Asset_Mac__c> macList = new List<Asset_Mac__c>();
        
        for(Asset a : newAssets) {
            macList.add(new Asset_Mac__c(
                AssetId__c = a.Id,
                Used__c = true
            ));

        }
        Map<Id, Id> macToAsset = new Map<Id, Id>();
        if(!macList.isEmpty()) insert macList;

        for(Asset_Mac__c am : macList) {
            macToAsset.put(am.AssetId__c, am.Id);
        }
        
        List<Asset> assetReUpdate = [SELECT Id, SerialNumber FROM Asset WHERE Id IN :macToAsset.keySet()];
        Map<Id, Asset_Mac__c> macMap = new Map<Id, Asset_Mac__c>();
        for(Asset_Mac__c am : [SELECT Id, AssetId__c, Name FROM Asset_Mac__c WHERE Id IN :macToAsset.values()]) {
            macMap.put(am.AssetId__c, am);
        }
        
        for(Asset a : assetReUpdate) {
            if(macMap.containsKey(a.Id)) {
                a.SerialNumber = '001BBC' + VirtualAssetManager.toHex(Integer.valueOf(macMap.get(a.Id).Name));
            }
        }
        if(!assetReUpdate.isEmpty()) update assetReUpdate;
    }
    
}