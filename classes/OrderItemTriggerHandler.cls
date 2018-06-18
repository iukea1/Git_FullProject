public class OrderItemTriggerHandler implements ITriggerHandler {
    
    public Boolean IsDisabled() {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) {
        updateStartDateForRenewals(newItems);
    }
    public void AfterInsert(Map<Id, SObject> newItems) {}
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void BeforeDelete(Map<Id,SObject> oldItems) {}
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> newItems) {}
    
    private static Boolean isOnInsertState = false;
    private static void updateStartDateForRenewals(List<OrderItem> newList) {
        Map<Id, Date> orderOnRenewal = OrderTriggerHandler.orderOnRenewal;
        Map<Id, Date> orderEndOnRenewal = OrderTriggerHandler.orderEndOnRenewal;
        Map<Id, Date> newEndDates = OrderTriggerHandler.orderEndOnRenewal;
        Set<Id> orderIdUpdate = new Set<Id>();
        //get renewed contracts
        
        if(!orderOnRenewal.isEmpty()) {
            for(OrderItem oi : newList) {
                if(orderOnRenewal.containsKey(oi.OrderId)) {
                    isOnInsertState = true;
                    Integer daysBtwn = oi.ServiceDate.daysBetween(oi.EndDate);
                    oi.ServiceDate = orderOnRenewal.get(oi.OrderId);
                    oi.EndDate = oi.ServiceDate.addDays(daysBtwn);
                    
                    /*if(newEndDates.get(oi.OrderId) == null || newEndDates.get(oi.OrderId) < oi.EndDate) {
                        newEndDates.put(oi.OrderId, oi.EndDate);
                        if(oi.EndDate > orderEndOnRenewal.get(oi.OrderId)) orderIdUpdate.add(oi.OrderId);
                    }*/
                }
            }
        }
    }
   
}