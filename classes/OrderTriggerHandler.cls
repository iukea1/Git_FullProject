public class OrderTriggerHandler implements ITriggerHandler {
    
    public Boolean IsDisabled() {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) {}
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        setRenewalDefaultDates((List<Order>)newItems.values(), (Map<Id, Order>) oldItems);
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) {}
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> newItems) {}
    
    
    //methods
    public static Map<Id, Date> orderOnRenewal = new Map<Id, Date>();
    private static void setRenewalDefaultDates(List<Order> newItems, Map<Id, Order> oldItems) {
        Boolean hasProcess = false;
        Set<Id> oppId = new Set<Id>();
        for(Order o : newItems) {
            if(o.Type == 'Renewal' && oldItems.get(o.Id).Type != 'Renewal') {
                oppId.add(o.OpportunityId);
                hasProcess = true;
            }
        }
        
        if(hasProcess) {
            Map<Id, Opportunity> oppCollect = new Map<Id, Opportunity>([SELECT Id, SBQQ__RenewedContract__c, SBQQ__RenewedContract__r.EndDate FROM Opportunity WHERE SBQQ__Renewal__c = true AND Id IN :oppId]);
            for(Order o : newItems) {
                if(o.Type == 'Renewal' && oldItems.get(o.Id).Type != 'Renewal' && oppCollect.containsKey(o.OpportunityId)) {
                    o.EffectiveDate = oppCollect.get(o.OpportunityId).SBQQ__RenewedContract__r.EndDate.addDays(1);
                    orderOnRenewal.put(o.Id, o.EffectiveDate);
                }
            }
        }
    }
}