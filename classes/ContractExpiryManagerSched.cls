global class ContractExpiryManagerSched implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new ContractExpiryManager());
    }
}