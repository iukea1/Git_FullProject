/*
 * Controlle of component NewCaseWithAsset
 */
public with sharing class NewCaseWithAssetController 
{
    public String   SerialNo        { get; set; }
    public Boolean  ShowAssets      { get; private set; }
    public Integer  AssetsPageNo    { get; private set; }
    public Integer  AssetsPageCount { get; private set; }
    public Integer  AssetsPageSize  { get; private set; }
    public String   AssetId         { get; private set; }
    public List<AssetWrapper> lstData {get; private set;}
    public List<Asset> MyAssets
    {
        get
        {
            return [select Id, Name, SerialNumber, Model__c from Asset where Status in('Customer Owned','Customer Subscription Active','Customer Subscription','Customer Evaluation') order by Model__c limit 1000];
        }
    }

    public NewCaseWithAssetController()
    {
        AssetsPageNo = 0;
        AssetsPageSize = 50;
        Integer rmaCount=0;
        LoadData();
        //Integer rmaCount = [select count() from Asset where Status in('Customer Owned','Customer Subscription Active','Customer Subscription','Customer Evaluation') limit 1000];
        if(lstData!=null && lstData.size()>0)
            rmaCount=lstData.size();
        
        AssetsPageCount = rmaCount / AssetsPageSize;
    }

    public PageReference searchAsset()
    {
        AssetWrapper asset = findValidAssetSub(SerialNo);
        if(asset != null)
        {
            AssetId = asset.RecordId;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No asset found'));
        }
        return null;
    }
    
    public PageReference showAssets()
    {
        ShowAssets = true;
        return null;
    }

    private Asset findAsset(String assetName)
    {
        assetName = trimName(assetName);
        List<Asset> assets = [select Id, Name from Asset where Name = :assetName];
        if(assets.size() > 0)
        {
            return assets[0];
        }
        else
        {
            return null;
        }
    }
    private AssetWrapper findValidAssetSub(String assetName)
    {
        AssetWrapper result= new AssetWrapper();
        assetName = trimName(assetName);
        List<Asset> assets = [select Id, Name,SerialNumber,Model__c from Asset where Name = :assetName and status in('Customer Owned','Customer Subscription Active','Customer Evaluation')];
        if(assets.size() > 0)
        {
            result.RecordId=assets[0].Id;
            result.SerialNumber=assets[0].SerialNumber;
            result.Model=assets[0].Model__c;
        }
        List<SBQQ__Subscription__c> subs = [select Id, SBQQ__Product__r.Model__c,SerialNumber__c from SBQQ__Subscription__c where SerialNumber__c = :assetName and SBCF_Subscription_Status__c in('Customer Owned','Customer Subscription Active','Customer Evaluation')];
        if(subs.size() > 0)
        {
            result.RecordId=subs[0].Id;
            result.SerialNumber=subs[0].SerialNumber__c;
            result.Model=subs[0].SBQQ__Product__r.Model__c;
        }
        
        
        return result;
    }
    private String trimName(String assetName)
    {
        return assetName.replaceAll('-', '');
    }
    
    public PageReference nextPage()
    {
        AssetsPageNo++;
        if(AssetsPageNo <=0)
        {
            AssetsPageNo = 0;
        }
        return null;
    }
    
    public PageReference previousPage()
    {
        AssetsPageNo--;
        if(AssetsPageNo >= AssetsPageCount)
        {
            AssetsPageNo = AssetsPageCount -1;
        }
        return null;
    }
    private void LoadData()
    {
        lstData= new List<AssetWrapper>();
        List<Asset> lstAsset=[select Id, Name, SerialNumber, Model__c from Asset where Status in('Customer Owned','Customer Subscription Active','Customer Subscription','Customer Evaluation') order by Model__c limit 1000];
        List<SBQQ__Subscription__c> lstSub=[Select Id,SerialNumber__c, SBQQ__Product__r.Model__c from SBQQ__Subscription__c where SBCF_Subscription_Status__c in('Customer Subscription Active','Customer Evaluation') order by SBQQ__Product__r.Model__c limit 1000];
        if(lstAsset!=null && lstAsset.size()>0)
        {
            for(Asset asset:lstAsset)
            {
                AssetWrapper data= new AssetWrapper();
                data.RecordId=asset.Id;
                data.SerialNumber=asset.SerialNumber;
                data.Model=asset.Model__c;
                lstData.add(data);
            }
				
        }
        
        if(lstSub!=null && lstSub.size()>0)
        {
            for(SBQQ__Subscription__c sub:lstSub)
            {
                AssetWrapper data= new AssetWrapper();
                data.RecordId=sub.Id;
                data.SerialNumber=sub.SerialNumber__c;
                data.Model=sub.SBQQ__Product__r.Model__c;
                lstData.add(data);
            }
				
        }
            
            
    }
    public class AssetWrapper{
        public Id RecordId{get;set;}
        public string SerialNumber{get;set;}
        public string Model{get;set;}
        public boolean IsAsset
        {
            get
            {
                Schema.DescribeSObjectResult r= this.RecordId.getsobjecttype().getDescribe();
                if(r.getName()=='Asset')
                    return true;
                
                return false;
            }
        }
        public AssetWrapper(){}
        public AssetWrapper(string sn, string model,Id recordId)
        {
            this.SerialNumber=sn;
            this.Model=model;
            this.RecordId=recordId;
            
        }
        
        
    }

    @isTest
    static void test()
    {
        NewCaseWithAssetController controller = new NewCaseWithAssetController();
        List<Asset> assets = controller.MyAssets;
        controller.SerialNo = 'acme';
        controller.searchAsset();
        controller.showAssets();
        controller.nextPage();
        controller.previousPage();
    }
}