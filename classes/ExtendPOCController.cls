public class ExtendPOCController {
    
    public SBQQ__Quote__c quote {get;set;}
    public List<SBQQ__Quote__c> quoteList {get;set;}
    
    
    public ExtendPOCController(ApexPages.StandardController stdController){
        
        if(!Test.isRunningTest()){
            stdController.addFields(getAllQuoteFieldsAPINames());
        }
        
        this.quote = (SBQQ__Quote__c)stdController.getRecord();
        
        quoteList = [SELECT Id, Name, Justification__c, Requested_Extension_Date__c, SBQQ__EndDate__c FROM SBQQ__Quote__c WHERE Id =: quote.Id LIMIT 1];
        
    }
    
    public PageReference saveQuote(){
        PageReference page = new PageReference('/' + this.quote.Id);
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