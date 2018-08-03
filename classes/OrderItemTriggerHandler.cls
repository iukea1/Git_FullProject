public class OrderItemTriggerHandler implements ITriggerHandler {
    
    public Boolean IsDisabled() {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) {
        //setDates(newItems);
    }
    public void AfterInsert(Map<Id, SObject> newItems) {
       // updateStartDateForRenewals(newItems);
       runRecalcs(newItems.values());
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
        Map<Id, SBQQ__QuoteLine__c> parentQls = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, End_Date__c, SBQQ__Quote__r.End_Date__c, SBQQ__Quote__r.SBQQ__StartDate__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds]);
        
        Map<Id, Order> parentOrderUpdate = new Map<Id, Order>();
        
        Set<Id> parentOrderIds = new Set<Id>();
        for(OrderItem oi : newList) {
            if(oi.End_Date__c == null && parentQls.containsKey(oi.SBQQ__QuoteLine__c)) {
                oi.End_Date__c = oi.EndDate; //parentQls.get(oi.SBQQ__QuoteLine__c).End_Date__c;
                oi.EndDate = parentQls.get(oi.SBQQ__QuoteLine__c).End_Date__c;
            }
        
            if(parentOrders.containsKey(oi.OrderId) && /*oi.ServiceDate < parentOrders.get(oi.OrderId).TemporaryStartDateHolder__c &&*/ parentOrders.get(oi.OrderId).TemporaryStartDateHolder__c != null) {
                if(oi.EndDate != null) {
                    Integer daysBetween = oi.ServiceDate.daysBetween(oi.EndDate);
                    oi.ServiceDate = parentOrders.get(oi.OrderId).TemporaryStartDateHolder__c;
                    oi.EndDate = oi.ServiceDate.addDays(daysBetween);
                    oi.End_Date__c = oi.ServiceDate.addDays(daysBetween);
                    parentOrderIds.add(oi.OrderId);
                }
                
            } else if(parentOrders.containsKey(oi.OrderId) && (parentOrders.get(oi.OrderId).End_Date__c == null || parentOrders.get(oi.OrderId).EndDate == null) && !parentOrderUpdate.containsKey(oi.OrderId) &&  parentOrders.get(oi.OrderId).TemporaryStartDateHolder__c != null) {
                parentOrderUpdate.put(oi.OrderId, 
                    new Order(
                        Id=oi.OrderId, 
                        End_Date__c=parentQls.get(oi.SBQQ__QuoteLine__c).SBQQ__Quote__r.End_Date__c,
                        EndDate=parentQls.get(oi.SBQQ__QuoteLine__c).SBQQ__Quote__r.End_Date__c
                    )
                );
            }
        }
        
        if(!parentOrderUpdate.isEmpty()) update parentOrderUpdate.values();
        if(!parentOrderIds.isEmpty()) setParentDate(parentOrderIds);
    }
    
    @future
    private static void setParentDate(Set<Id> parentOrderId) {
        List<Order> parentOrders = [SELECT Id, TemporaryStartDateHolder__c, Ship_Date__c, EffectiveDate, SBQQ__Quote__c, SBQQ__Quote__r.End_Date__c FROM Order WHERE Id IN :parentOrderId AND TemporaryStartDateHolder__c != null];
        for(Order o : parentOrders) {
            o.EffectiveDate = o.TemporaryStartDateHolder__c;
            o.End_Date__c = o.SBQQ__Quote__r.End_Date__c;
            o.EndDate = o.SBQQ__Quote__r.End_Date__c;
            o.TemporaryStartDateHolder__c = null;
        }
        update parentOrders;
    }
}