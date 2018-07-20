public class LicenseGenerationJob implements  Database.Batchable<sObject>
{
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([Select Id, SerialNumber,Model__c,Product_Quote_Type__c,Product_Category__c, GMS_Nodes__c,Status,Ship_Date__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__r.EndDate  from Asset where Create_License__c=true]);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        
        List<Asset> lstAssets=(List<Asset>)scope;
        List<Asset> lstAssetsToUpdate= new List<Asset>();
        List<License__c> licenses= new  List<License__c>();
        Set<Id> setAssetIds= new Set<Id>();
        Set<Id> setLicIds= new Set<Id>();
        System.debug('lstAssets.size'+ lstAssets.size());
        if(lstAssets!=null && lstAssets.size()>0)
        {
            for(Asset asset: lstAssets)
            {
                integer quantity=1;
                License__c lic =new License__c(AssetId__c=asset.Id,Start_Date__c=asset.Ship_Date__c,Model__c=asset.Model__c,SerialNumber__c=asset.SerialNumber);
                if(asset.Model__c=='GX-V' || asset.Product_Category__c=='GMS')
                    quantity=Integer.valueOf(asset.GMS_Nodes__c);
                lic.Quantity__c=quantity;
                if(asset.status=='Customer Owned')
                {
                    lic.License_Expiration__c=null;
                }
                if(asset.status=='Customer Subscription Active' || asset.status=='Customer Subscription' || asset.Status=='Customer Evaluation')
                {
                    lic.License_Expiration__c=asset.SBQQ__CurrentSubscription__r.SBQQ__Contract__r.EndDate;
                }
                licenses.add(lic);  
                if(asset.Product_Quote_Type__c=='NX/VX' && !asset.Model__c.startsWith('UNITY CLOUD') ) 
                    setAssetIds.add(asset.Id);
            }
            System.debug('before insert licenses'+licenses.size());
            System.debug('before insert licenses'+licenses);
        }
        
        if(licenses!=null && licenses.size()>0)
        {
            System.Savepoint sp= Database.setSavepoint();
            try
            {
                if(licenses.size()>0)
                {
                    insert licenses; 
                }
                for(License__c lic : [select Id,AssetId__c from License__c where Id in :licenses])
                {
                    if(setAssetIds.size()>0 && setAssetIds.contains(lic.AssetId__c))
                        setLicIds.add(lic.Id);
                }
                System.debug('after insert licenses'+setLicIds.size());
                System.debug('after insert licenses'+setLicIds);
                if(setLicIds.size()>0)
                {
                    LicenseEncryptionJob job = new LicenseEncryptionJob();
                    job.LicenseIds = new List<Id>(setLicIds);
                    System.enqueueJob(job);
                }
                // update CreateAsset flag= false;
                for(Asset asset: lstAssets)
                {
                    lstAssetsToUpdate.add(new Asset(Id=asset.Id,Create_License__c=false));
                }
                System.debug('lstAssetsToUpdate '+ lstAssetsToUpdate);
                update lstAssetsToUpdate;
                
            }
            
            catch(Exception ex)
            {
                Database.rollback(sp);
                System.debug(ex);
                SilverPeakUtils.logException('License Generation Job Failure',ex.getMessage());
            }
            
        }
        
    }  
    public void finish(Database.BatchableContext BC)
    {
       if(!Test.isRunningTest())
        {
            LicenseGenerationJob obj= new LicenseGenerationJob();
            System.scheduleBatch(obj, 'LicenseGeneration', 5);        
        }
    }
}