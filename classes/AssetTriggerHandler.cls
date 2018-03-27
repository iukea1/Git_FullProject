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
           // populateStatusPartAndSerialNumberToAsset(newItems);
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
        System.debug('After Insert');
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
            //populateRelatedAssetSubscriptionLookups(newItems.values());
        }
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
    
        
    // Main Method
    public static void populateRelatedAssetSubscriptionLookups(List<Asset> incomingAssets){
        // Used in action method
        
        Map<Id, List<Asset>> quoteLineIdsToAssets = buildQuoteLineIdsToAssets(incomingAssets);
        System.debug('@@---------quoteLineIdsToAssets'+ quoteLineIdsToAssets);
        
        if(quoteLineIdsToAssets.keySet() == null){
            System.debug('There are no quote lines related to incoming subscriptions. ');
            return;
        }
        
        Set<Id> assetQuoteLineIds = quoteLineIdsToAssets.keySet();
        System.debug('@@---------assetQuoteLineIds'+ assetQuoteLineIds);
        // Map quote line Id to Quote Line
        Map<Id, SBQQ__QuoteLine__c> assetQuoteLineMap = queryForAssetQuoteLines(assetQuoteLineIds);
        System.debug('@@---------queryForAssetQuoteLines'+ assetQuoteLineMap);
        if(assetQuoteLineMap.size() == 0){
            System.debug('No quote lines were returned related to subscription quote lines.');
            return;
        }
        
        Set<Id> requiredByQuoteLineIds = getRequiredByQuoteLineIds(assetQuoteLineMap.values());
        System.debug('@@---------assetQuoteLineMap.values() : '+ assetQuoteLineMap.values());
        System.debug('@@---------assetQuoteLineMap.keySet() : '+ assetQuoteLineMap.keySet());
        System.debug('@@---------requiredByQuoteLineIds'+ requiredByQuoteLineIds);
        List<SBQQ__Subscription__c> subscriptionRelatedToAssets = queryForSubscriptionRelatedToAssetsRequiredByIds(requiredByQuoteLineIds);
        System.debug('@@---------subscriptionRelatedToAssets'+ subscriptionRelatedToAssets);
        // PROBLEM 
        if(subscriptionRelatedToAssets.size() == 0){
            System.debug('No assets were found relating to the subscription quote lines required by quote line.');
            return;
        }
        
        Map<Id, Set<Id>> assetRequiredByIdToAssetQuoteLineIds = buildAssetRequiredByIdToAssetQuoteLineIds(assetQuoteLineMap.values());
        System.debug('@@---------assetRequiredByIdToAssetQuoteLineIds'+ assetRequiredByIdToAssetQuoteLineIds);
        List<SBQQ__Subscription__c> subscriptionsToUpdate = updateSubscriptionsWithAssetLookups(subscriptionRelatedToAssets, assetRequiredByIdToAssetQuoteLineIds, quoteLineIdsToAssets);
        
        System.debug('Assets to update: ' + subscriptionsToUpdate);
        
        if(subscriptionsToUpdate.size() > 0){
            update subscriptionsToUpdate;
            
        }
        // end of the asset 

        
    }
    //Helper Method
     private static Map<Id, List<Asset>> buildQuoteLineIdsToAssets(List<Asset> incomingAssets){
         Map<Id, List<Asset>> quoteLineIdsToAssets = new Map<Id, List<Asset>>();
         
         for(Asset asset: incomingAssets){
             if(asset.SBQQ__QuoteLine__c == null){
                 continue;
             }
             
             List<Asset> assetsRelatedToQuoteLine = quoteLineIdsToAssets.get(asset.SBQQ__QuoteLine__c);
             
             if(assetsRelatedToQuoteLine == null){
                 assetsRelatedToQuoteLine = new List<Asset>();
                 quoteLineIdsToAssets.put(asset.SBQQ__QuoteLine__c, assetsRelatedToQuoteLine);
             }
             
             assetsRelatedToQuoteLine.add(asset);
         }
         
         System.debug('Quote Line Id To Asset Id: ' + quoteLineIdsToAssets);
         return quoteLineIdsToAssets;
     }

    
    private static Map<Id, SBQQ__QuoteLine__c> queryForAssetQuoteLines(Set<Id> assetQuoteLineIds){
        Map<Id, SBQQ__QuoteLine__c> assetQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> queryForAssetQuoteLine = new List<SBQQ__QuoteLine__c>();
        
        try{
            queryForAssetQuoteLine = [SELECT Id, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c IN :assetQuoteLineIds];
            
            for(SBQQ__QuoteLine__c quoteLineMap: queryForAssetQuoteLine){
                assetQuoteLineMap.put(quoteLineMap.SBQQ__RequiredBy__c, quoteLineMap);
            }
        }
        catch(QueryException qe){
            system.debug(qe.getMessage());
        }
        
        System.debug('Asset Quote Line Map: ' + assetQuoteLineMap);
        return assetQuoteLineMap;
    }
    
    private static Set<Id> getRequiredByQuoteLineIds(List<SBQQ__QuoteLine__c> assetQuoteLines){
        Set<Id> requiredByQuoteLineIds = new Set<Id>();
        
        for(SBQQ__QuoteLine__c quoteLine: assetQuoteLines){
            if(quoteLine.Id == null){
                continue;
            } 
            
            requiredByQuoteLineIds.add(quoteLine.Id);
        }
        
        return requiredByQuoteLineIds;
    }
    
    private static Map<Id, SBQQ__Subscription__c> assetRequiredByIdToSubscriptionQuoteline(Set<Id> assetRequiredByIds){
        Map<Id, SBQQ__Subscription__c> requiredByToSubscriptionQuoteLineMap = new Map<Id, SBQQ__Subscription__c>();
        
        
        return requiredByToSubscriptionQuoteLineMap;
    }
    
    private static List<SBQQ__Subscription__c> queryForSubscriptionRelatedToAssetsRequiredByIds(Set<Id> requiredByAssetQuoteLineIds){
        List<SBQQ__Subscription__c> subscriptionRelatedToAssets = new List<SBQQ__Subscription__c>();
        
        try{
            subscriptionRelatedToAssets = [SELECT Id, SBQQ__QuoteLine__c, SBCF_Asset__c FROM SBQQ__Subscription__c WHERE SBQQ__QuoteLine__c IN :requiredByAssetQuoteLineIds];
        }
        catch(QueryException qe){
            System.debug(qe.getMessage());
        }
            
            System.debug('Subscription realted to Asset : ' + subscriptionRelatedToAssets);
        
        return subscriptionRelatedToAssets;
    }
    
    private static Map<Id, Set<Id>> buildAssetRequiredByIdToAssetQuoteLineIds(List<SBQQ__QuoteLine__c> assetQuoteLines){
        Map<Id, Set<Id>> assetRequiredByIdToSubscriptionQuoteLineIds = new Map<Id, Set<Id>>();
        
        System.debug('asset Quote Lines in buildAssetRequiredByIdToAssetQuoteLineIds: ' + assetQuoteLines);
        
        for(SBQQ__QuoteLine__c subscriptionQuoteLine: assetQuoteLines){
            if(subscriptionQuoteLine.SBQQ__RequiredBy__c == null){
                continue;
            }
            
            Set<Id> subscriptionQuoteLineIds = assetRequiredByIdToSubscriptionQuoteLineIds.get(subscriptionQuoteLine.SBQQ__RequiredBy__c);
            
            if(subscriptionQuoteLineIds == null){
                subscriptionQuoteLineIds = new Set<Id>();
                assetRequiredByIdToSubscriptionQuoteLineIds.put(subscriptionQuoteLine.SBQQ__RequiredBy__c, subscriptionQuoteLineIds);
            }
            
            subscriptionQuoteLineIds.add(subscriptionQuoteLine.Id);
        }
        
        System.debug('Asset Required By Id To Asset Quote Line Ids: ' + assetRequiredByIdToSubscriptionQuoteLineIds);
        
        return assetRequiredByIdToSubscriptionQuoteLineIds;
    }
    
    private static List<SBQQ__Subscription__c> updateSubscriptionsWithAssetLookups(List<SBQQ__Subscription__c> subscriptionRelatedToAssets, Map<Id, Set<Id>> assetRequiredByIdToAssetQuoteLineIds,
                                                                   Map<Id, List<Asset>> quoteLineIdsToAssets){
                                                                       
                                                                       System.debug('Update Subscription With Asset Lookups Method.');
                                                                       List<SBQQ__Subscription__c> subscriptionsToUpdate = new List<SBQQ__Subscription__c>();
                                                                       
                                                                       for(SBQQ__Subscription__c subscription: subscriptionRelatedToAssets){
                                                                           Set<Id> assetQuoteLineIds = assetRequiredByIdToAssetQuoteLineIds.keySet();
                                                                           
                                                                           if(assetQuoteLineIds == null){
                                                                               System.debug('No asset quote line Ids related to Subscription for subscription: ' + subscription);
                                                                               continue;
                                                                           }
                                                                           
                                                                           List<Asset> assetsRelatedToSubscription = new List<Asset>();
                                                                           for(Id assetQuoteLineId: assetQuoteLineIds){
                                                                               List<Asset> assets = quoteLineIdsToAssets.get(assetQuoteLineId);
                                                                               if(assets == null){
                                                                                   System.debug('No asset in = map with id: ' + assetQuoteLineId);
                                                                                   continue;
                                                                               }
                                                                               assetsRelatedToSubscription.addAll(assets);
                                                                           }
                                                                           
                                                                           if(assetsRelatedToSubscription.size() == 0){
                                                                               System.debug('There were no subscriptions related to asset with Id: ' + subscription.Id);
                                                                           }
                                                                           else{
                                                                               System.debug('assets found related to subscription.');
                                                                               System.debug('Updating subscription with Id: ' + subscription.Id + ' with asset lookups with the following assets: ' + assetsRelatedToSubscription);
                                                                               
                                                                               Asset asset;
                                                                               //SBQQ__Subscription__c smartHandsSubscription;
                                                                               
                                                                               for(Asset relatedAsset: assetsRelatedToSubscription){
                                                                                   asset = relatedAsset;
                                                                               }
                                                                               
                                                                               // Should not be the case since the trigger is on subscription
                                                                               if(asset == null){
                                                                                   System.debug('No Asset Found for Subscription with Id: ' + subscription.Id);
                                                                                   continue;
                                                                               }
                                                                               else{
                                                                                   if(asset != null){
                                                                                       subscription.SBCF_Asset__c = asset.Id;
                                                                                   }
                                                                                   
                                                                                   subscriptionsToUpdate.add(subscription);
                                                                                   
                                                                               }
                                                                               
                                                                           }
                                                                           
                                                                       }
                                                                        System.debug('subscription to Update : ' + subscriptionsToUpdate);
                                                                       return subscriptionsToUpdate;
                                                                   }
 // end of the helper method 
 
    
 // Author : Ronald Pascual
 // Date: March 26, 2018
 // Description : To Pull the Status, Part Number, and Serial Number from the Order Product Items to Asset. 
 // -------------------------------------------------------------------------------------------------------
 
 // START of Activation Order task -------@@@ 

    private static void populateAssetFields(List<Asset> incomingAssets){
        List<Asset> updateOrderProductItem = populateStatusPartAndSerialNumberToAsset(incomingAssets);
        
        if(updateOrderProductItem == null){
            System.debug('There are no incoming asset that was related to order product item. ');
        }
        
        if(updateOrderProductItem.size()>0){
            update updateOrderProductItem;
        }
    }
    
    private static List<Asset> populateStatusPartAndSerialNumberToAsset(List<Asset> asset){
    
        List<Asset> assetProductEqualToPhysical = assetsWithForecastCategoryEqualToPhysical(asset);
    
        if(assetProductEqualToPhysical == null){
            System.debug('There are no incoming asset that has a product forecast category of PHYSICAL. ');
        }
    
        Map<Id, List<Asset>> orderProductToAssets = groupAssetsByOrderProduct(assetProductEqualToPhysical);
    
        if(orderProductToAssets.keySet() == null){
            System.debug('There are no order product related to incoming assets. ');
        }
    
        Set<Id> orderProductFromAsset =  orderProductToAssets.keySet();
    
        List<Order_Product_Item__c> orderProductItemRelatedToAsset = getAllOrderProductItemsRelatedToOrderProduct(orderProductFromAsset);
    
        if(orderProductToAssets.keySet() == null){
            System.debug('There are no ORDER PRODUCT ITEM related to incoming assets. ');
        }
    
        List<Asset> updateAssets = updateAssetRelatedToOrderProduct(orderProductItemRelatedToAsset, orderProductToAssets);
    
        System.debug('Asset to update :  ' + updateAssets);
    
        if(updateAssets.size()>0){
            update updateAssets;
        }
        
        //List<Order_Product_Item__c> updateOrderProductItem = updateOrderProductRelatedToAsset(orderProductItemRelatedToAsset, updateAssets);
    	
        return updateAssets;

    }
    
    //List<Asset> assetProductEqualToPhysical = assetsWithForecastCategoryEqualToPhysical(List<Asset> incomingAsset);
    
    private static List<Asset> assetsWithForecastCategoryEqualToPhysical(List<Asset> incomingAsset){
        List<Asset> assetProductEqualToPhysical = new List<Asset>();
    
        for(Asset asset: incomingAsset){
            if(asset.Product2.Forecast_Category__c == 'Physical'){
                assetProductEqualToPhysical.add(asset);
            }	
        }
    
        return assetProductEqualToPhysical;	
    }
    
    //Map<Id, List<Asset>> orderProductToAssets = groupAssetsByOrderProduct(assetProductEqualToPhysical);
    
    private static Map<Id, List<Asset>> groupAssetsByOrderProduct(List<Asset> assetProductEqualToPhysical){
         Map<Id, List<Asset>> orderProductToAssets = new Map<Id, List<Asset>>();
    
         for(Asset asset: assetProductEqualToPhysical){
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
    // --- requires @future method 
    
    private static Set<Id> generatedAssetIds(List<Asset> incomingAssets){
        Set<Id> generatedAssetSetOfIds = new Set<Id>();
        List<Asset> updatedAssetsRelatedToOrderProdItems = populateStatusPartAndSerialNumberToAsset(incomingAssets);
        
        if(updatedAssetsRelatedToOrderProdItems == null){
            System.debug('There are no incoming asset that was related to order product item. ');
        }
        
        for(Asset updatedAssets: updatedAssetsRelatedToOrderProdItems){
            generatedAssetSetOfIds.add(updatedAssets.Id);
        }
        
        return generatedAssetSetOfIds;
    }
    
    private static void overrideAsset(Set<Id> orderProductAsset){
        
    	List<Order_Product_Item__c> orderProductItemsWithExistingAsset = [SELECT Id, Name, Existing_Asset__c, Asset__c FROM Order_Product_Item__c WHERE Asset__c IN: orderProductAsset];
        System.debug('@@-------- orderProductItemsWithExistingAsset : ' + orderProductItemsWithExistingAsset);
        for(Order_Product_Item__c orderProdItem: orderProductItemsWithExistingAsset){
            //existsingAssetToAsset.put(orderProdItem.Existing_Asset__c, Asset__c);
        }
        
    }
        
}