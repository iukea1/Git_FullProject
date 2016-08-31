trigger AddActiveECBaseLicenseToECHardware on Asset (after insert, after update) {
    Set<Id> assetIds= new Set<Id>();
    for(Asset asset: Trigger.New)
    {
        if(Trigger.IsInsert)
        {
            assetIds.add(asset.Id);
        }
        if(Trigger.IsUpdate)
        {
            Asset oldAsset= Trigger.OldMap.get(asset.Id);
            if(oldAsset.AccountId!=asset.AccountId)
            {
                assetIds.add(asset.Id);
            }
        }
    }
    
    
    Map<Id,Id> hardwareECAssetIds= new  Map<Id,Id>();
    Map<Id,Id> softwareECBaseAssetIds= new  Map<Id,Id>();
    if(assetIds.size()>0)
    {
        for(Asset toUpdateAsset:[Select Id,Product2Id,Product2.Product_Category__c,Product2.Name,Product2.Family,AccountId,Active_EC_Base_License__c from Asset where Id in: assetIds and Product2.Name like 'EC%'])
        {
            if(toUpdateAsset.Product2.Product_Category__c=='Appliance' && toUpdateAsset.Product2.Family=='Product')
            {
                
                hardwareECAssetIds.put(toUpdateAsset.Id, toUpdateAsset.AccountId);
            }
            
            if(toUpdateAsset.Product2.Product_Category__c=='Subscription' && toUpdateAsset.Product2.Family=='Virtual Image' && toUpdateAsset.Product2.Name.startsWith('EC-BASE' ))
            {
                softwareECBaseAssetIds.put(toUpdateAsset.AccountId, toUpdateAsset.Id);
            }
            
        }
        List<Asset> lstHardwareAssetToUpdate=null;
        // Assign Base Software Base License to the Hardware asset
        if(hardwareECAssetIds.size()>0)
        {
            List<Asset> baseLicenses = [Select Id, AccountId from Asset where AccountId in :hardwareECAssetIds.values() and Product2.Family='Virtual Image' and Status in('Customer subscription Active','Customer Evaluation') and Product2.Name like 'EC-BASE-%' order by CreatedDate asc];
            Map<Id, Id> accId2BaseLicenseId = new Map<Id, Id>();
            for(Asset baseLicense : baseLicenses)
            {
                accId2BaseLicenseId.put(baseLicense.AccountId, baseLicense.Id);
            }
            Asset hardwareAssetToUpdate = null;
            lstHardwareAssetToUpdate= new List<Asset>();
            for(Id assetId : hardwareECAssetIds.keySet())
            {
                Id acctId= hardwareECAssetIds.get(assetId);
                Id baseLicenseId = accId2BaseLicenseId.get(acctId);
                if(baseLicenseId != null)
                {
                    hardwareAssetToUpdate = new Asset(Id=assetId, Active_EC_Base_License__c=baseLicenseId);
                    lstHardwareAssetToUpdate.add(hardwareAssetToUpdate);
                }
            }
            if(lstHardwareAssetToUpdate.size()>0)
            {
                update lstHardwareAssetToUpdate;
            }
        }
        // If the EC BASE license is created, then assign this ID to all hardware asset
        if(softwareECBaseAssetIds.size()>0)
        {
            lstHardwareAssetToUpdate = new List<Asset>();
            List<Asset> hardwareAssets = [Select Id, AccountId from Asset where AccountId in :softwareECBaseAssetIds.keyset() and Product2.Family='Product' and Product2.Name like 'EC-%' order by CreatedDate desc];
            for(Asset hardwareAsset : hardwareAssets)
            {
                Id acctId = hardwareAsset.AccountId;
                Id baseLicenseid = softwareECBaseAssetIds.get(acctId);
                lstHardwareAssetToUpdate.add(new Asset(Id=hardwareAsset.Id, Active_EC_Base_License__c=baseLicenseid));
            }
            if(lstHardwareAssetToUpdate.size()>0)
            {
                update lstHardwareAssetToUpdate;
            }
        }
    }
}