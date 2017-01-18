public class Throwaway implements Database.Batchable<SObject>, Database.Stateful
{
    public Integer batches;
    public List<Account> lstAccount;
    public Throwaway() { batches = 0;lstAccount= new List<Account>(); }
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT Id FROM Account where Id='0014B00000BuVK5']);
    }
    public void execute(Database.BatchableContext bc, List<SObject> scope)
    {
        lstAccount = [Select Id from Account where Sync_Virtual_Assets_with_CP__c=true];
        System.debug('lstAccount vcount'+ lstAccount.size());
    }
    public void finish(Database.BatchableContext bc)
    {
        System.debug('lstAccount'+ lstAccount.size());
    }
}