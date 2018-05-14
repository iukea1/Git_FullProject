/*
 * Controller of the component ExpiringContractList
 */
public class ExpiringContractListController 
{
    public ExpiringContractListController()
    {
    }
    
    public Id AccountId { get; set; }
    
    public List<Contract> Contracts
    {
        get
        {
            if(AccountId != null)
            {
                return [select Id, ContractNumber, Account.Name, CustomerSigned.Name, CustomerSigned.Email, Status, EndDate, (select Name, Model__c from Assets1__r) from Contract where (Status in ('Activated', 'Expired') or Trigger_Notice__c!=null) and AccountId=:AccountId and Include_For_Notice__c=1 order by EndDate];
            }
            else
            {
                return new List<Contract>();
            }
        }
    }
    
    
     public List<ContractWrapper> SubscribedContracts
    {
        get
        {
            List<ContractWrapper> lstContractData= new List<ContractWrapper>();
            if(AccountId != null)
            {
                
                List<Contract> lstContracts= [select Id, ContractNumber, Account.Name, CustomerSigned.Name, CustomerSigned.Email, Status, EndDate, (select Name, Model__c from Assets1__r) from Contract where (Status in ('Activated', 'Expired') or Trigger_Notice__c!=null) and AccountId=:AccountId and Perpetual_Product_Count__c >0 order by EndDate];
                List<SBQQ__Subscription__c> lstSub=[Select Id,SBQQ__Contract__c,(Select Id,SBQQ__Asset__r.Name,SBQQ__Asset__r.Model__c from SBQQ__SubscribedAssets__r where SBQQ__Active__c=true) from SBQQ__Subscription__c where SBQQ__Product__r.Product_Type__c='NX/VX' and SBQQ__Product__r.Product_Category__c like 'Maintenance%'  and (SBQQ__Contract__r.Status in ('Activated', 'Expired') or SBQQ__Contract__r.Trigger_Notice__c!=null)and SBQQ__Contract__r.AccountId=:AccountId and SBQQ__Contract__r.Perpetual_Product_Count__c>0];
                if(lstContracts!=null && lstContracts.size()>0)
                {
                    for(Contract con:lstContracts)
                    {
                        ContractWrapper conWrapper= new ContractWrapper(); 
                        conWrapper.ContractId=con.Id;
                        conWrapper.ContractNumber=con.ContractNumber;
                        conWrapper.AccountName=con.Account.Name;
                        conWrapper.CustomerSignedName=con.CustomerSigned.Name;
                        conWrapper.CustomerSignedEmail=con.CustomerSigned.Email;
                        conWrapper.Status=con.Status;
                        conWrapper.EndDate=con.EndDate;
                        if(lstSub!=null && lstSub.size()>0)
                        {
                           string assetList='';
                            for(SBQQ__Subscription__c sub:lstSub)
                            {
                                if(sub.SBQQ__Contract__c==con.Id)
                                {
                                    if(sub.SBQQ__SubscribedAssets__r!=null && sub.SBQQ__SubscribedAssets__r.size()>0)
                                    {
                                        for(SBQQ__SubscribedAsset__c subAsset:sub.SBQQ__SubscribedAssets__r)
                                        {
                                            assetList+= subAsset.SBQQ__Asset__r.Name +'('+subAsset.SBQQ__Asset__r.Model__c +'),';
                                        }
                                    }
                                    
                                }
                            }
                           assetList= assetList.removeEnd(',');
                           conWrapper.AssetList=assetList;
                        }
                        lstContractData.add(conWrapper);
                    }
                }
                
            }
            return lstContractData;
        }
    }
    
    
    public class ContractWrapper
    {
        public Id ContractId{get;set;}
        public string ContractNumber{get;set;}
        public string AccountName{get;set;}
        public string CustomerSignedName{get;set;}
        public string CustomerSignedEmail{get;set;}
        public string Status{get;set;}
        public Date EndDate{get;set;}
        public string AssetList{get;set;}
        public ContractWrapper()
        {
            
        }
    }
    @isTest
    static void testExpiringContractListController()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        ExpiringContractListController controller = new ExpiringContractListController();
        controller.AccountId=acc.Id;
        List<Contract> contracts = controller.Contracts;
    }
     @isTest
    static void testExpiringContractListController1()
    {
        Account acc= new Account(Name='Test');
        insert acc;
        Account spacc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 vxSub= new Product2(Name='VX-1000 Maint Contract ',Model__c='VX-1000',Product_Category__c='Maintenance-1 Year',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxSub;
        Product2 vxProd= new Product2(Name='VX-1000',Model__c='VX-1000',Family='Virtual Image', PRoduct_Type__c='NX/VX');
        insert vxProd;
        Asset asset1= new Asset(Name='Test',SerialNumber='Test',AccountId=acc.Id,Product2Id=vxProd.Id);
        insert asset1;
        Contract con= new Contract(AccountId=acc.Id,Contract_Type__c='Platinum');
        insert con;
        
        con.status='Activated';
        update con;
        SBQQ__Subscription__c sub= new SBQQ__Subscription__c(SBQQ__Account__c=acc.Id,SBQQ__Contract__c=con.Id,SBQQ__Quantity__c=1,SBQQ__Product__c=vxSub.Id);
        insert sub;
        
        asset1.SBQQ__CurrentSubscription__c=sub.Id;
        update asset1;
        SBQQ__SubscribedAsset__c sub11= new SBQQ__SubscribedAsset__c(SBQQ__Asset__c=asset1.Id,SBQQ__Subscription__c=sub.Id,SBQQ__Active__c=true);
           insert sub11;
        ExpiringContractListController controller = new ExpiringContractListController();
        controller.AccountId=acc.Id;
        List<ContractWrapper> contracts = controller.SubscribedContracts;
    }
}