public class CloudPortalPostAssetsJobScheduler implements Schedulable{
    
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new CloudPortalPostAssetsJob(), 1);
    }

}