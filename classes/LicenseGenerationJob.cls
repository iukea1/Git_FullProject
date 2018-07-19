public class LicenseGenerationJob implements  Database.Batchable<sObject>, Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([Select Id, Model__c,Product_Quote_Type__c,Product_Category__c, GMS_Nodes__c,Status,Ship_Date__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__r.EndDate  from Asset where Create_License__c=true]);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        
        List<Asset> lstAssets=(List<Asset>)scope;
        List<Asset> lstAssetsToUpdate= new List<Asset>();
        List<License__c> licenses= new  List<License__c>();
        Set<Id> setAssetIds= new Set<Id>();
        Set<Id> setLicIds= new Set<Id>();
        if(lstAssets!=null && lstAssets.size()>0)
        {
            for(Asset asset: lstAssets)
            {
                integer quantity=1;
                License__c lic =new License__c(AssetId__c=asset.Id,Start_Date__c=asset.Ship_Date__c,Model__c=asset.Model__c);
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
                // added the not equal to null condition @Ronald
                if(asset.Model__c != null){
                    if(asset.Product_Quote_Type__c=='NX/VX' && !asset.Model__c.startsWith('UNITY CLOUD') ) 
                        setAssetIds.add(asset.Id);
                    licenses.add(lic);  
                }
                
            }
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
                for(License__c lic:licenses)
                {
                    if(setAssetIds.size()>0 && setAssetIds.contains(lic.AssetId__c))
                        setLicIds.add(lic.Id);
                }
                if(setLicIds.size()>0)
                {
                    Set<Id> gmsLicenseIds = new Set<Id>();
                    for(License__c gmsLicense : [select Id from License__c where Id in :setLicIds and (AssetId__r.Product2.Model__c='GX-V' OR AssetId__r.Product2.Product_Category__c = 'GMS')])
                    {
                        gmsLicenseIds.add(gmsLicense.Id);
                    }
                    if(gmsLicenseIds.size() > 0)
                    {
                        LicenseEncryptionJob job = new LicenseEncryptionJob();
                        job.LicenseIds = new List<Id>(gmsLicenseIds);
                        System.enqueueJob(job);
                    }
                    
                    Set<Id> virtualLicenseIds = new Set<Id>();
                    for(License__c virtualLicense : [select Id from License__c where Id in :setLicIds and AssetId__r.Product2.Model__c!='GX-V' And AssetId__r.Product2.Product_Category__c !='GMS'])
                    {
                        virtualLicenseIds.add(virtualLicense.Id);
                    }
                    if(virtualLicenseIds.size() > 0)
                    {
                        LicenseEncryptionJob job = new LicenseEncryptionJob();
                        job.LicenseIds = new List<Id>(virtualLicenseIds);
                        System.enqueueJob(job);
                    }
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
            System.scheduleBatch(obj, 'LicenseGeneration', 5, 1);
        }
    }
}