public class PORenewalAssetsController {
    public Purchase_Order__c PORequest{get;set;}
    public Purchase_Order__c CustomerContact{get;set;}
    public List<Asset> AssetList{get;set;}
    public License__c License { get; set; }
    public boolean IsFromApex {get;set;}
    public String AssetTypeSelection{get; set;}
    public PORenewalAssetsController(ApexPages.StandardController controller)
    {
        
        if(AssetList==null)
        { AssetList= new List<Asset>();}
        License= new License__c();
        CustomerContact = new Purchase_Order__c();
        List<Purchase_Order__c> requests = [select Id, Opportunity__c, Opportunity__r.AccountId,Email_Contact__c from Purchase_Order__c where Id = :controller.getId()];        
        if(!requests.isEmpty())
        {
            PORequest = requests[0];
            AssetList= RetreiveAssets(false);
            
        }
        IsFromApex=false;
        
    }
    public PageReference ResetFilter()
    {
        if(AssetTypeSelection=='1')
        {
            AssetList= RetreiveAssets(false);
        }
        else
        {
            AssetList= RetreiveAssets(true);
        }
        return null;
        
    }
    public List<Asset> RetreiveAssets(boolean isEdgeConnect)
    {
        List<Asset> lstAssets=null;
        
        if(isEdgeConnect)
        {
            lstAssets =[Select Id, Name,License_End_Date__c,Product2.Name,Status,Ship_Date__c, Product2.Product_Category__c,Product2.NumberOfLicenses__c,Hosted_GMS__c,GMS_Nodes__c,Product2.Model__c,Is_Selected_For_Renewal__c,Renewal_Date__c,License_Expiration__c from Asset where AccountId =:PORequest.Opportunity__r.AccountId and  Status in('Customer Subscription Active', 'Customer Subscription Expired','Customer Subscription') and Product2.Family='Virtual Image' and Product2.Name like'EC%' and (NOT Product2.Name='EC-ORCH')];
        }
        else
        {
            lstAssets =[Select Id, Name,License_End_Date__c,Product2.Name,Status,Ship_Date__c, Product2.Product_Category__c,Product2.NumberOfLicenses__c,Hosted_GMS__c,GMS_Nodes__c,Product2.Model__c,Is_Selected_For_Renewal__c,Renewal_Date__c,License_Expiration__c from Asset where AccountId =:PORequest.Opportunity__r.AccountId and  Status in('Customer Subscription Active', 'Customer Subscription Expired','Customer Subscription') and Product2.Family='Virtual Image'  and  (NOT Product2.Name like'EC%')];
        }
        
        
        return lstAssets;
    }
    
    
    public PageReference SaveAssets()
    {
        boolean isSuccessful=false;
        SavePoint sp= Database.setSavepoint();
        List<Asset> assets= new List<Asset>();
        List<Asset> ecOrchAsset= new List<Asset>();
        try
        {
            
            if(AssetTypeSelection=='2')
            {
                for(Asset item: AssetList)
                {
                    if(item.Is_Selected_For_Renewal__c)
                    {
                        if( item.Product2.Name=='EC-ORCH')
                        { ecOrchAsset.add(item);}
                        else
                        {assets.add(item);}
                    }
                }
                if(assets.size()==0 && ecorchAsset.size()==0)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please select records.'));
                }
                if(assets.size()>0 || ecOrchAsset.size()>0)
                {
                    
                    if(assets.size()>0)
                    {
                        
                        RenewalAssetsHelper.CheckUnCheckAssets(assets, true);
                        RenewalAssetsHelper.RenewEdgeConnectLicense(assets); 
                        RenewalAssetsHelper.UpdateAssetStatus(assets, AssetTypeSelection);
                        isSuccessful=true;
                       
                    }
                    if(ecOrchAsset.size()>0)
                    {
                        
                        RenewalAssetsHelper.CheckUnCheckAssets(ecOrchAsset, true);
                        RenewalAssetsHelper.CreateNewLicenses(ecOrchAsset);
                        isSuccessful=true;
                    }
                    if(isSuccessful=true)
                    {
                        RenewalAssetsHelper.SendEmailsForPurchaseOrder(true, PORequest,CustomerContact.Email_Contact__c);
                        isSuccessful=true;
                    }
                }
                else
                {
                    
                }
            }
            if(AssetTypeSelection=='1')
            {
               
                for(Asset item: AssetList)
                {
                    if( item.Is_Selected_For_Renewal__c)
                    {assets.add(item);}
                }
                if(assets.size()>0)
                {
                    RenewalAssetsHelper.CheckUnCheckAssets(assets, true);
                    if( RenewalAssetsHelper.CreateNewLicenses(assets))
                    {
                        RenewalAssetsHelper.UpdateAssetStatus(assets, AssetTypeSelection);
                        RenewalAssetsHelper.SendEmailsForPurchaseOrder(false, PORequest,CustomerContact.Email_Contact__c);
                        isSuccessful=true;
                    }
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please select records.'));
                }
            }
            
            if(ApexPages.currentPage() != null && isSuccessful)
            {
                if(!isFromApex)
                {
                    ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Succeeded. <script type="text/javascript">top.opener.location="/' + PORequest.Id + '";window.setTimeout("top.close();", 2000);</script>');
                    ApexPages.addMessage(pageMsg);
                }
                
            }
        }
        catch(Exception ex)
        {
            Database.Rollback(sp);
            ApexPages.addMessages(ex);
            SilverPEakUtils.logException(ex);
        }
        finally
        {
            if(assets.size()>0)
            {
                RenewalAssetsHelper.CheckUnCheckAssets(assets, false);
                RenewalAssetsHelper.ClearRenewalDate(assets);
            }
            if(ecOrchAsset.size()>0)
            {
                RenewalAssetsHelper.CheckUnCheckAssets(ecOrchAsset, false);
                RenewalAssetsHelper.ClearRenewalDate(ecOrchAsset);
            }
        }
        return null;
        
    }
    
    
}