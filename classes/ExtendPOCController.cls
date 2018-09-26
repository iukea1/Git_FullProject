public class ExtendPOCController {
    
    public SBQQ__Quote__c quote {get;set;}
    public SBQQ__Quote__c quoteList {get;set;}
    public SBQQ__Quote__c checkQuote {get;set;}
    public Boolean checkStatus {get;set;}
    
    
    public ExtendPOCController(ApexPages.StandardController stdController){
        
        if(!Test.isRunningTest()){
            stdController.addFields(getAllQuoteFieldsAPINames());
        }
        
        this.checkStatus = false;
        this.quote = (SBQQ__Quote__c)stdController.getRecord();
        
        quoteList = [SELECT Id, Name, Justification__c, Requested_Extension_Date__c, SBQQ__EndDate__c, SBQQ__StartDate__c, POC_Status__c FROM SBQQ__Quote__c WHERE Id =: quote.Id LIMIT 1];
        
        if(quoteList == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'There is no quote available.');
            ApexPages.addMessage(myMsg);
            return;
        }
        
        
            if(quoteList.POC_Status__c != 'Shipped' && quoteList.POC_Status__c != 'Shipped - Extended' && quoteList.POC_Status__c != 'Pending Return'){
                checkStatus = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Invalid Quote POC Status.');
                ApexPages.addMessage(myMsg);
                return;
        	}  
        
    }
    
    public PageReference saveQuote(){
        
        boolean isValid=true;
        // Validate the extension request 
        if(quoteList.Requested_Extension_Date__c <= quoteList.SBQQ__StartDate__c && quoteList.Requested_Extension_Date__c <= quoteList.SBQQ__EndDate__c){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Extension Date'));
            isValid=false;
        }
        if(quoteList.Requested_Extension_Date__c==null )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter Extend To Date.'));
            isValid=false;
        }
        if(String.isblank(quoteList.Justification__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the reason for POC Extension.'));
            isValid=false;
        }
        if(!isValid)
        {
            return null;
        }
        
        
        
        try{
            //quoteList.SBQQ__EndDate__c = quoteList.Requested_Extension_Date__c;
            update quoteList; 
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }
        
        PageReference page = new PageReference('/apex/QuoteSubmitApproval?id=' + this.quote.Id);
        page.setRedirect(true);
        return page;  
    }    
    
    
    public PageReference returnToQuote(){
        PageReference page = new PageReference('/' + this.quote.Id);
        page.setRedirect(true);
        return page;
    }
    
    public static List<String> getAllQuoteFieldsAPINames(){
        List<String> quoteFieldAPINames = new List<String>();

        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.SBQQ__Quote__c.fields.getMap();
        
        system.debug('Quote Fields: ' + schemaFieldMap.keySet());
        
        for(String fieldAPIName: schemaFieldMap.keySet()){
            quoteFieldAPINames.add(fieldAPIName);
        }

        return quoteFieldAPINames;
    }

    
}