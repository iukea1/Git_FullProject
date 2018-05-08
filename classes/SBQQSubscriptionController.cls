public class SBQQSubscriptionController {
   public ID ContractId{get;set;}
    public List<Asset> lstVXSubAssets{
        get
        {
            List<Asset> lstData=new List<Asset>();
            if(ContractId!=null)
            {
               lstData=[Select Id, Product2.Name,SerialNumber from Asset where Product2.Product_Type__c='NX/VX' and Product2.Family='Virtual Image' and SBQQ__CurrentSubscription__c in (Select Id from SBQQ__Subscription__c where SBQQ__Contract__c=:ContractId)];
            }
            
            return lstData ;
        }
    }
    
    public SBQQSubscriptionController()
    {
       
    }
}