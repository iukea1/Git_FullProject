public class OrderItemTriggerHandler implements ITriggerHandler {
    
    public Boolean IsDisabled() {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) {
        setDates(newItems);
    }
    public void AfterInsert(Map<Id, SObject> newItems) {
       //updateStartDateForRenewals(newItems);
       //runRecalcs(newItems.values());
   }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        setDates(newItems.values());
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void BeforeDelete(Map<Id,SObject> oldItems) {}
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> newItems) {}
    
    private static void runRecalcs(List<OrderItem> newList) {
        Set<Id> orderIdUpdate = new Set<Id>();
        //get renewed contracts
        
        for(OrderItem oi : newList) {
            orderIdUpdate.add(oi.OrderId);
        }
        List<Order> oUpdate = new List<Order>();
        for(Id i : orderIdUpdate) {
            oUpdate.add(new Order(Id=i));
        }
        update oUpdate;
    }
    
    
    private static void setDates(List<OrderItem> newList) {
        Set<Id> orderIds = new Set<Id>();
        Set<Id> quoteLineIds = new Set<Id>();
        for(OrderItem oi : newList) {
            orderIds.add(oi.OrderId);
            quoteLineIds.add(oi.SBQQ__QuoteLine__c);
        }
        Map<Id, Order> parentOrders = new Map<Id, Order>([SELECT Id, TemporaryStartDateHolder__c, Ship_Date__c, EffectiveDate, EndDate, End_Date__c FROM Order WHERE Id IN :orderIds]);
        Map<Id, SBQQ__QuoteLine__c> parentQls = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c, End_Date__c, SBQQ__Quote__r.End_Date__c, SBQQ__Quote__r.SBQQ__StartDate__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds]);
        
        Map<Id, Order> parentOrderUpdate = new Map<Id, Order>();
        
        Set<Id> parentOrderIds = new Set<Id>();
        for(OrderItem oi : newList) {
            if(parentQls.containsKey(oi.SBQQ__QuoteLine__c)) {
                SBQQ__QuoteLine__c ql = parentQls.get(oi.SBQQ__QuoteLine__c);
                Order pOrder = parentOrders.get(oi.OrderId);
                if(ql.SBQQ__SubscriptionTerm__c != null && ql.SBQQ__SubscriptionTerm__c != 0) {
                    oi.CotermEndDate__c = oi.EndDate;
                    if(oi.ServiceDate != ql.SBQQ__StartDate__c && ql.End_Date__c != null && ql.SBQQ__StartDate__c != null) {
                        Integer daysBetween = ql.SBQQ__StartDate__c.daysBetween(ql.End_Date__c);
                        oi.EndDate = oi.ServiceDate.addDays(daysBetween);
                    } else if(oi.ServiceDate == ql.SBQQ__StartDate__c && ql.End_Date__c != null) {
                        oi.EndDate = ql.End_Date__c;
                    }
                }
            }
            
        }
        
    }
    
}