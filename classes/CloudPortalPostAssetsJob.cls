public class CloudPortalPostAssetsJob implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts 
{
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id,Name,Cloud_Portal_Account_Id__c from Account where Sync_Virtual_Assets_with_CP__c=true]);
    }
    public void execute(Database.BatchableContext context, List<sObject> scope)
    { 
        List<Asset> lstAsset= null;
        boolean isSuccessCallout=false;
        
        List<Account> lstAccountToUpdate= new List<Account>();
        List<Asset> lstFinalAssets= new List<Asset>();
        List<Account> lstFinalSyncAccountUpdate= new List<Account>();
        List<Account> lstAccounts =(List<Account>)scope;
        if(lstAccounts!=null && lstAccounts.size()>0)
        {
            for(Account accId:lstAccounts)
            {
                try
                {
                    string cloudPortalId='';
                    Account accUpdated= new Account();
                    lstAsset=new List<Asset>();
                    lstAsset=[Select Id,Sync_With_Cloud_Portal__c,Cloud_Portal_Sync_Status__c from Asset where AccountId=:accId.Id and Sync_With_Cloud_Portal__c=true and Cloud_Portal_Sync_Status__c='Pending' and Product2.Family='Virtual Image'];
                    
                    if(accId.Cloud_Portal_Account_Id__c!=null)
                    {
                        cloudPortalId=accId.Cloud_Portal_Account_Id__c;
                    }
                    else
                    {
                        accUpdated=CloudPortalAccountHelper.GetOrCreateAccountFromCloudPortal(accId.Id,accId.Name);
                        cloudPortalId= accUpdated.Cloud_Portal_Account_Id__c;
                        
                    }
                    if(String.isBlank(cloudPortalId))
                    {
                        continue;
                    }
                    List<Asset> lstAssetsToUpdate=[Select Id,SerialNumber,Product2.Name,Product2.Model__c,Product2.Product_Type__c,Licenses_Nodes__c,Bandwidth_Nodes__c,License_End_Date__c,Contract_Number__r.StartDate,Contract_Number__r.EndDate,Contract_Number__r.Status,Quantity,Account.Unity_Orch_Admin_User__c,Account.Unity_Orch_Domain__c,Account.Unity_Orch_Location__c,Account.Unity_Orch_Version__c ,Product2.Bandwidth__c from Asset where AccountId=:accId.Id and (Product2.Name like 'EC%' or Product2.Name like'UNITY CLOUD%') and Product2.Family='Virtual Image' and (NOT Product2.Name='EC-ORCH') and Status in ('Customer Subscription Active','Customer Subscription','Customer Evaluation','Loan','Conditional PO','Customer Owned') ];
                    List<SBQQ__Subscription__c> lstSubToUpdate=[Select Id,SerialNumber__c,Boost_Bandwidth_Qty__c,SBQQ__Product__r.Name,SBQQ__Product__r.Model__c,SBQQ__Product__r.Product_Type__c,SBQQ__Quantity__c,SBQQ__Contract__r.StartDate,SBQQ__Contract__r.EndDate,SBQQ__Contract__r.Status,SBQQ__Account__r.Unity_Orch_Admin_User__c,SBQQ__Account__r.Unity_Orch_Domain__c,SBQQ__Account__r.Unity_Orch_Location__c,SBQQ__Account__r.Unity_Orch_Version__c ,SBQQ__Product__r.Bandwidth__c from SBQQ__Subscription__c where SBQQ__Account__r.Id=:accId.Id  and SBQQ__Contract__r.Status='Activated'and SBQQ__Product__r.SBQQ__Component__c=false and SBQQ__SubscriptionStartDate__c<=:Date.today() and (SBQQ__Product__r.Name like 'EC%' or SBQQ__Product__r.Name like'UNITY CLOUD%') and SBQQ__Product__r.Family='Virtual Image' and SBQQ__Contract__r.Product_Type__c in('EDGECONNECT','EC-SP-Term','EC-SP-Metered','EC-SP-Perpetual','Service Provider') ];                   
                    List<CPAsset> lstECAssets,lstECEvalAssets,lstSaasAssets,lstECSaasSub,lstCPXAssets,lstSPAssets,lstECSPSub,lstCloudOrchAssets= new List<CPAsset>() ;
                    // Call the account helper to create assets in cloudportal format.
                    lstECAssets=CloudPortalAccountHelper.ConvertSubscriptionsToCpSub(lstSubToUpdate, 'EC');
                    //lstECEvalAssets=CloudPortalAccountHelper.ConvertAssetToCpAsset(lstAssetsToUpdate, 'Evaluation');
                    lstSaasAssets=CloudPortalAccountHelper.ConvertAssetToCpAsset(lstAssetsToUpdate, 'SAAS'); // UNITY CLOUD Intelligence
                    lstECSaasSub=CloudPortalAccountHelper.ConvertSubscriptionsToCpSub(lstSubToUpdate, 'SAAS'); // EC-SAAS
                    //lstCPXAssets=CloudPortalAccountHelper.ConvertAssetToCpAsset(lstAssetsToUpdate, 'CPX');
                    lstSPAssets=CloudPortalAccountHelper.ConvertAssetToCpAsset(lstAssetsToUpdate, 'SP'); // Perpetual
                    lstECSPSub=CloudPortalAccountHelper.ConvertSubscriptionsToCpSub(lstSubToUpdate, 'SP'); // Term
                    lstCloudOrchAssets=CloudPortalAccountHelper.ConvertSubscriptionsToCpSub(lstSubToUpdate, 'UNITYORCH');
                    
                    //Combine assets and subscriptions in one list
                     //if(lstECEvalAssets!=null && lstECEvalAssets.size()>0)
                       // lstECAssets.addAll(lstECEvalAssets);
                    if(lstECSaasSub!=null && lstECSaasSub.size()>0)
                        lstSaasAssets.addAll(lstECSaasSub);
                    System.debug('lstSaasAssets' + lstSaasAssets);
                     if(lstECSPSub!=null && lstECSPSub.size()>0)
                        lstSPAssets.addAll(lstECSPSub);
                    
                    string currToken= CloudPortalAccountHelper.GetTokenFromPortal();
                    CloudPortalPostAssetsApi obj= new CloudPortalPostAssetsApi(cloudPortalId);
                    obj.token=currToken;
                    obj.cpxAssets=lstCPXAssets;
                    obj.ecAssets=lstECAssets;
                    obj.saasAssets=lstSaasAssets;
                    obj.spAssets=lstSPAssets;
                    obj.orchAssets=lstCloudOrchAssets;
                    obj.execute();
                    if(obj.isSucceed)
                    {
                        if(lstAsset!=null && lstAsset.size()>0)
                        {
                            for(Asset item: lstAsset)
                            {
                                item.Sync_With_Cloud_Portal__c=false;
                                item.Cloud_Portal_Sync_Status__c='Complete';
                                lstFinalAssets.add(item);
                            }
                        }
                        System.debug('accUpdated '+ accUpdated);
                        if(accUpdated!=null && accUpdated.Id!=null)
                        { 
                            lstAccountToUpdate.add(accUpdated);
                        }
                        
                        lstFinalSyncAccountUpdate.add(new Account(Id=accId.Id,Sync_Virtual_Assets_with_CP__c=false));
                    } 
                }
                catch(Exception ex)
                {
                    SilverPeakUtils.logException(ex);
                    continue;
                }
            }
            
            try
            {
                if(lstAccountToUpdate.size()>0)
                {
                    update lstAccountToUpdate;
                }
                if(lstFinalAssets.size()>0)
                {
                    update lstFinalAssets;
                }     
                 if(lstFinalSyncAccountUpdate.size()>0)
                {
                    update lstFinalSyncAccountUpdate;
                }    
                 
            }
            catch(Exception ex)
            {
                
                SilverPeakUtils.logException(ex);
            }
        }
        
    }  
    
    public void finish(Database.BatchableContext context)
    {
      if(!Test.isRunningTest())
        {
            CloudPortalPostAssetsJob obj= new CloudPortalPostAssetsJob();
            System.scheduleBatch(obj, 'CPPostAssets', 30, 1);
        }
        
    }
    
}