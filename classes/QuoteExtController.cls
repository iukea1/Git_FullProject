public with sharing class QuoteExtController{
    private Id quoteId;
    public SBAA__Approval__c[] approvals {get; set;}
    public List<string> lstErrorMessages{get;set;}
    public QuoteExtController(ApexPages.StandardController stdController){
        quoteId = stdController.getId();
    }
    
    public PageReference onSubmit(){
        if (quoteId != null){
            lstErrorMessages= new List<string>();
            if(ValidateBeforeApproval()){
                SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
                return new PageReference('/' + quoteId);
            }
            else{
                lstErrorMessages.add(0, 'There are following errors on the quote. Click on the quote <a href="https://' + URL.getSalesforceBaseUrl().getHost() + '/' + quoteId + '">' +'Back to the Quote'+ '</a>');
                lstErrorMessages.add(1, '\n');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,string.join(lstErrorMessages,'<br/>'),'Quote Error'));
            }      
        }
        return null;
    }
    
    public PageReference onRecall(){
        if (quoteId != null){
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
            return new PageReference('/' + quoteId);
        }
        return null;
    }
    
    public PageReference onPreview(){
        if (quoteId != null){
            approvals = SBAA.ApprovalAPI.preview(quoteId, SBAA__Approval__c.Quote__c);
        }
        return null;    
	}
    
    private boolean CheckHardwareAddressAssociation(Id quoteId){
        SBQQ__Quote__c quoteInfo=[Select Id,SBCF_Evaluation_Quote__c,Hw_Count_Qty_QL__c,Hw_Count_Qty_QLA__c,Hw_Sum_Qty_QLA__c,Hw_Sum_Qty_QL__c from SBQQ__Quote__c where Id=:quoteId];
        if(quoteInfo.SBCF_Evaluation_Quote__c && quoteInfo.Hw_Count_Qty_QL__c>0 ){
            //if(quoteInfo.Hw_Count_Qty_QL__c>0 && quoteInfo.Hw_Count_Qty_QL__c!=quoteInfo.Hw_Count_Qty_QLA__c)
            // return true;
            if(quoteInfo.Hw_Sum_Qty_QL__c>0 && quoteInfo.Hw_Sum_Qty_QL__c!=quoteInfo.Hw_Sum_Qty_QLA__c)
                return true;
            
        }
        return false;
    }
    private boolean CheckUnityCloudOrchInformation(Id quoteId){
        SBQQ__Quote__c quoteInfo=[Select Id,SBCF_Evaluation_Quote__c,SBQQ__Account__r.Unity_Orch_Admin_User__c,SBQQ__Account__r.Unity_Orch_Domain__c,SBQQ__Account__r.Unity_Orch_Location__c,(Select Id from SBQQ__LineItems__r where SBQQ__Product__r.Name like 'EC-ORCH-AAS%') from SBQQ__Quote__c where Id=:quoteId];
        if(quoteInfo.SBCF_Evaluation_Quote__c){
            List<SBQQ__QuoteLine__c> lstQL= quoteInfo.SBQQ__LineItems__r;
            if(lstQL!=null && lstQL.size()>0 &&(quoteInfo.SBQQ__Account__r.Unity_Orch_Admin_User__c==null || quoteInfo.SBQQ__Account__r.Unity_Orch_Domain__c==null || quoteInfo.SBQQ__Account__r.Unity_Orch_Location__c==null))
                return true;
            
        }
        return false;
    }
	private boolean CheckDiscountJustification(Id quoteId){
        SBQQ__Quote__c quoteInfo=[Select Id,Approval_Level_Triggered__c,Discount_Justification__c from SBQQ__Quote__c where Id=:quoteId];
		if(String.isBlank(quoteInfo.Discount_Justification__c) && quoteInfo.Approval_Level_Triggered__c > 0)
			return true;
		
        return false;
    }
   
    private boolean ValidateBeforeApproval(){
        boolean isValid=true;
		if(CheckHardwareAddressAssociation(quoteId)){
			lstErrorMessages.add('The address has not been associated with the hardware products in the quote. Please go to the Quote Address section and add shipping quantities.');
			isValid=false;
		}
		if(CheckUnityCloudOrchInformation(quoteId)){
			lstErrorMessages.add('You can only request unity cloud orchestrator provided all the fields(unity orchestrator domain, unity orchestrator admin user and unity orchestrator location ) are populated in the account. Please contact operations for any assistance.');
			isValid=false;
		}
		if(CheckDiscountJustification(quoteId)){
			lstErrorMessages.add('Additional discounts above approved thresholds requires a discount justification. Please fill out the Discount Justification.');
			isValid=false;
		}
        
        return isValid;
    }
}