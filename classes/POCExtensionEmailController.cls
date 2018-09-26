public class POCExtensionEmailController {
    public Id quoteId { get; set; }  
    public String display {get;set;}
    public List<RMA__c> RMAs {
        get {
            if(quoteId != null) {
                return [select Id,Name from RMA__c where POC_Quote__c=:quoteId and Status__c!='Closed'];
            } else {
                return new List<RMA__c>();
            }
        }
    }
    public List<Asset> Assets {
        get {
            if(quoteId != null) {
                return [select Id, Model__c, SerialNumber from Asset where Id IN (SELECT SBQQ__Asset__c FROM SBQQ__SubscribedAsset__c WHERE SBQQ__Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c = :quoteId)];
            } else {
                return new List<Asset>();
            }
        }
    }
}