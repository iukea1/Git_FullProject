public class RMAItemTriggerHandler implements ITriggerHandler {
    Id silverpeakSystemsId='00130000007mEjX';// production Id
    public RMAItemTriggerHandler()
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
    }
    
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        
        if(newItems!=null && newItems.size()>0)
        {
            
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        
        if(newItems!=null && newItems.size()>0)
        {
            
            for (Id rmaItemId : newItems.keyset())
            {
                RMA_Item__c  newRMAItem=(RMA_Item__c )newItems.get(rmaItemId);
                RMA_Item__c  oldRMAItem=(RMA_Item__c )oldItems.get(rmaItemId);
                
                
                
            }
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        
        if(newItems!=null && newItems.size()>0)
        {
            for(Id rmaItemId: newItems.keyset())
            {
            }
            
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {     
        
        List<RMA_Item__c> lstRMAItem = new List<RMA_Item__c>();
        if(newItems!=null && newItems.size()>0)
        {
            for(Id rmaItemId: newItems.keyset())
            {
                RMA_Item__c newRMAItem= (RMA_Item__c)newItems.get(rmaItemId);
                RMA_Item__c oldRMAItem= (RMA_Item__c)oldItems.get(rmaItemId);
                System.debug(newRMAItem.Status__c);
                System.debug(oldRMAItem.Status__c);
                if(newRMAItem.Asset__c!=null && newRMAItem.Status__c!=oldRMAItem.Status__c && newRMAItem.Status__c=='Received' && newRMAItem.Asset__c!=null)
                {
                    lstRMAItem.add(newRMAItem);
                    
                }
            }
            UpdateRecordsForRecievedRMA(lstRMAItem);
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
    }
    
    private void UpdateRecordsForRecievedRMA(List<RMA_Item__c> lstRMAItem)
    {
        if(lstRMAItem!=null && lstRMAItem.size()>0)
        {
            List<Asset> lstAsset= new List<Asset>();
            Set<Id> setAssetId= new Set<Id>();
            for(RMA_Item__c newRMAItem: lstRMAItem)
            {
                System.debug('newRmaItem.Product_Category__c'+newRmaItem.Product_Category__c);
                if(newRMAItem.Product_Category__c!=null && (newRMAItem.Product_Category__c =='Appliance' || newRMAItem.Product_Category__c =='GMS'))
                {
                    System.debug('test');
                    Asset asset= new Asset(Id=newRMAItem.Asset__c);
                    setAssetId.add(newRMAItem.Asset__c);
                    asset.ContactId = null;
                    asset.Status = 'Silver Peak Inventory';
                    asset.Description = null;
                    asset.Ship_To_Location__c = null;
                    asset.Installed_At_Location__c = null;
                    asset.Ship_Date__c = null;
                    asset.Warranty_Start_Date__c = null;
                    asset.Warranty_End_Date__c = null;
                    asset.Evaluation_Start_Date__c = null;
                    asset.Evaluation_End_Date__c = null;
                    asset.End_of_Software_Support__c = null;
                    asset.GMS_Nodes__c = null;
                    asset.POCRequest__c = null;
                    asset.Quote__c=null;
                    asset.Customer_Notes__c= null;
                    asset.AccountId = silverpeakSystemsId;
                    lstAsset.add(asset);
                }                
            }
            List<SBQQ__Subscription__c> subDeletion = new List<SBQQ__Subscription__c>();
            List<SBQQ__SubscribedAsset__c> lstSubscribed=[Select Id,SBQQ__Subscription__c, SBQQ__Active__c from SBQQ__SubscribedAsset__c where SBQQ__Asset__c in: setAssetId and SBQQ__Active__c=true];
            if(lstSubscribed!=null && lstSubscribed.size()>0)
            {
                for(SBQQ__SubscribedAsset__c item:lstSubscribed)
                {
                    item.SBQQ__Active__c=false;
                    subDeletion.add(new SBQQ__Subscription__c(Id=item.SBQQ__Subscription__c));
                }
            }
            if(lstAsset!=null && lstAsset.size()>0)
                update lstAsset;
            if(lstSubscribed!=null && lstSubscribed.size()>0)
            {
                update lstSubscribed;
            }
            if(!subDeletion.isEmpty()) {
                delete subDeletion;
            }
            
        }
        
    }

}