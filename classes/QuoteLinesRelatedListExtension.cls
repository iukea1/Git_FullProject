public with sharing class QuoteLinesRelatedListExtension
{
    private Id quoteId;
    
    public QuoteLinesRelatedListExtension(ApexPages.standardController controller)
    {
        quoteId = controller.getId();
    }
    
    public List<SBQQ__QuoteLine__c> QuoteLines
    {
        get
        {
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : this.getFields()) {
                query += f.getFieldPath() + ', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteId ORDER BY CreatedDate DESC';
            return Database.query(query);
        }
    }
    
    private List<Schema.FieldSetMember> getFields() 
    {
        return SObjectType.SBQQ__QuoteLine__c.FieldSets.RelatedListFields.getFields();
    }
}