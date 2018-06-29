/*
 * Controlle of component NewCaseWithAsset
 */
public with sharing class NewCaseWithAssetController 
{
    public String   SerialNo        { get; set; }
    public Boolean  ShowAssets      { get; private set; }
    public Id  AccountId      { get; private set; }
    public Integer  AssetsPageNo    { get; private set; }
    public Integer  AssetsPageCount { get; private set; }
    public Integer  AssetsPageSize  { get; private set; }
    public String   AssetId         { get; private set; }
    public string  AssetType         { get; private set; }
    public List<AssetWrapper> lstData 
    {
        get
        {
           return LoadData();
        }
    }
   /* public List<Asset> MyAssets
    {
        get
        {
            return [select Id, Name, SerialNumber, Model__c from Asset where Status in('Customer Owned','Customer Subscription Active','Customer Subscription','Customer Evaluation') order by Model__c limit 1000];
        }
    }*/

    public NewCaseWithAssetController()
    {
        AssetsPageNo = 0;
        AssetsPageSize = 50;
        Integer rmaCount=0;
        User loggedInUser=[Select Id,Contact.AccountId from User where Id=:UserInfo.getUserId()];
        if(loggedInUser!=null && loggedInUser.Contact.AccountId!=null)
        {
            AccountId = loggedInUser.Contact.AccountId;
        }
        
        List<AssetWrapper> lstAW= LoadData();
        //Integer rmaCount = [select count() from Asset where Status in('Customer Owned','Customer Subscription Active','Customer Subscription','Customer Evaluation') limit 1000];
        if(lstAW!=null && lstAW.size()>0)
            rmaCount=lstAW.size();
        
        System.debug('rmaCount' + rmaCount);
        
        AssetsPageCount = rmaCount / AssetsPageSize;
        System.debug('AssetsPageCount'+ AssetsPageCount);
    }

    public PageReference searchAsset()
    {
        AssetWrapper asset = findValidAssetSub(SerialNo);
        if(asset != null && asset.RecordId!=null)
        {
            AssetId=asset.RecordId;
            Schema.DescribeSObjectResult r= asset.RecordId.getsobjecttype().getDescribe();
            if(r.getName()=='Asset')
                AssetType = 'Asset';
            else
                AssetType= 'Subscription';
         
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

   /* private Asset findAsset(String assetName)
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
    }*/
    private AssetWrapper findValidAssetSub(String assetName)
    {
        AssetWrapper result= new AssetWrapper();
        assetName = trimName(assetName);
        List<Asset> assets = [select Id, Name,SerialNumber,Model__c from Asset where Name = :assetName and status in('Customer Owned','Customer Subscription Active','Customer Evaluation')];
        if(assets!=null && assets.size() > 0)
        {
            result.RecordId=assets[0].Id;
            result.SerialNumber=assets[0].SerialNumber;
            result.Model=assets[0].Model__c;
            result.AssetType= 'Asset';
        }
        List<SBQQ__Subscription__c> subs = [select Id, SBQQ__Product__r.Model__c,SerialNumber__c from SBQQ__Subscription__c where SerialNumber__c = :assetName and SBCF_Subscription_Status__c in('Customer Owned','Customer Subscription Active','Customer Evaluation')];
        if(subs!=null && subs.size() > 0)
        {
            result.RecordId=subs[0].Id;
            result.SerialNumber=subs[0].SerialNumber__c;
            result.Model=subs[0].SBQQ__Product__r.Model__c;
            result.AssetType= 'Subscription';
        }
        
        
        return result;
    }
    private String trimName(String assetName)
    {
        string assetData= !assetName.startsWith('SUB')?assetName.replaceAll('-', ''):assetName;
        return assetData;
    }
    
    public PageReference nextPage()
    {
        System.debug('nextPage AssetsPageNo'+ AssetsPageNo);
        AssetsPageNo++;
        if(AssetsPageNo <=0)
        {
            AssetsPageNo = 0;
        }
        System.debug('Now AssetsPageNo'+ AssetsPageNo);
        return null;
    }
    
    public PageReference previousPage()
    {
        System.debug('previousPage AssetsPageNo'+ AssetsPageNo);
        AssetsPageNo--;
        if(AssetsPageNo >= AssetsPageCount)
        {
            AssetsPageNo = AssetsPageCount -1;
        }
        System.debug('Prev AssetsPageNo'+ AssetsPageNo);
        return null;
    }
    private List<AssetWrapper> LoadData()
    {
        List<AssetWrapper> lstAssetWrapper= new List<AssetWrapper>();
        List<Asset> lstAsset=[select Id, Name, SerialNumber, Model__c from Asset where Status in('Customer Owned','Customer Subscription Active','Customer Subscription','Customer Evaluation')  order by Model__c limit 1000];
        List<SBQQ__Subscription__c> lstSub=[Select Id,SerialNumber__c, SBQQ__Product__r.Model__c from SBQQ__Subscription__c where SBCF_Subscription_Status__c in('Customer Subscription Active','Customer Evaluation') and SBQQ__Account__c=:AccountId and SBQQ__Contract__r.Product_Type__c!='NX/VX' order by SBQQ__Product__r.Model__c limit 1000];
        if(lstAsset!=null && lstAsset.size()>0)
        {
            for(Asset asset:lstAsset)
            {
                AssetWrapper data= new AssetWrapper();
                data.RecordId=asset.Id;
                data.SerialNumber=asset.SerialNumber;
                data.Model=asset.Model__c;
                data.AssetType= 'Asset';
                lstAssetWrapper.add(data);
            }
			  System.debug('lstAssetWrapper' +lstAsset);	
        }
        
        if(lstSub!=null && lstSub.size()>0)
        {
            for(SBQQ__Subscription__c sub:lstSub)
            {
                AssetWrapper data= new AssetWrapper();
                data.RecordId=sub.Id;
                data.SerialNumber=sub.SerialNumber__c;
                data.Model=sub.SBQQ__Product__r.Model__c;
                data.AssetType='Subscription';
                lstAssetWrapper.add(data);
            }
			  System.debug('lstSubWrapper' +lstSub);	
        }
      	System.debug('lstAssetWrapper count' +lstAssetWrapper.size());	
		return lstAssetWrapper;            
    }
    public class AssetWrapper{
        public Id RecordId{get;set;}
        public string SerialNumber{get;set;}
        public string Model{get;set;}
        public string AssetType {get;set;}
        public AssetWrapper(){}
        
        
    }

    @isTest
    static void test()
    {
        
        NewCaseWithAssetController controller = new NewCaseWithAssetController();
        List<AssetWrapper> assets = controller.lstData;
        controller.SerialNo = '001BBC231231';
        controller.searchAsset();
        controller.showAssets();
        controller.nextPage();
        controller.previousPage();
    }
   	@IsTest
    static void testNXVX()
    {
         Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 vxSub= new Product2(Name='VX-1000 Sub ',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxSub;
        Product2 vxProd= new Product2(Name='VX-1000 Sub(Asset)',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxProd;
        Asset asset1= new Asset(Status='Customer Owned',Name='001BBC231231',SerialNumber='001BBC231231',AccountId=acc.Id,Product2Id=vxProd.Id);
        insert asset1;
        Contract con= new Contract(AccountId=acc.Id);
        insert con;
        
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=vxSub.Id);
        insert sub;
        
        asset1.SBQQ__CurrentSubscription__c=sub.Id;
        update asset1;
        NewCaseWithAssetController controller = new NewCaseWithAssetController();
        List<AssetWrapper> assets = controller.lstData;
        controller.SerialNo = '001BBC231231';
        controller.searchAsset();
        System.assert(assets.size()>0);
        controller.showAssets();
        controller.nextPage();
        controller.previousPage();
        
    }
     @IsTest
    public  static void TestEC_SubAssset()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 ecBase= new Product2(Name='EC-BASE-1Y ',Model__c='EC-BASE-1Y',Family='Virtual Image', PRoduct_Type__c='EDGECONNECT');
        insert ecBase;
        Product2 ecHW= new Product2(Name='EC-XS-1Y',Model__c='EC-XS-1Y',Family='Product', PRoduct_Type__c='EDGECONNECT');
        insert ecHW;
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=ecHW.Id);
        insert asset1;
        SBQQ__Quote__c objQuote= new SBQQ__Quote__c(Product_Type__c='EDGECONNECT',SBQQ__StartDate__c=Date.today());
        insert objQuote;
        Contract con= new Contract(AccountId=acc.Id,SBQQ__Quote__c=objQuote.Id);
        insert con;
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=ecBase.Id);
        insert sub;
        SBQQ__Subscription__c sub1=[Select Id,Name from SBQQ__Subscription__c where Id=:sub.Id];
     
       	NewCaseWithAssetController controller = new NewCaseWithAssetController();
        List<AssetWrapper> assets = controller.lstData;
        controller.SerialNo = sub1.Name;
        controller.searchAsset();
        System.debug(assets);
        System.assert(assets.size()>0);
        controller.showAssets();
        controller.nextPage();
        controller.previousPage();
        
    }
}