public class AsyncOppSplitsJob implements Queueable 
{
    private List<OpportunitySplit> newSplits;
    
    public AsyncOppSplitsJob(List<OpportunitySplit> splits)
    {
        this.newSplits = splits;
    }
    
    public void execute(QueueableContext context) 
    {
        Database.insert(newSplits, false);
    }
}