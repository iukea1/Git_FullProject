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
    
    
    private static void updateStartDateForRenewals(List<OrderItem> newList) {
        Map<Id, Date> orderOnRenewal = OrderTriggerHandler.orderOnRenewal;
        if(!orderOnRenewal.isEmpty()) {
            for(OrderItem oi : newList) {
                if(orderOnRenewal.containsKey(oi.OrderId)) {
                    if(oi.ServiceDate < orderOnRenewal.get(oi.OrderId)) {
                        Integer daysBtwn = oi.ServiceDate.daysBetween(oi.EndDate);
                        oi.ServiceDate = orderOnRenewal.get(oi.OrderId);
                        oi.EndDate = oi.EndDate.addDays(daysBtwn);
                    }
                }
            }
        }
    }
   
}