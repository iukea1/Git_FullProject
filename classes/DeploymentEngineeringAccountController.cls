public class DeploymentEngineeringAccountController 
{
    public boolean IsDEAccount {get;set;}
    public DeploymentEngineeringAccountController(ApexPages.StandardController stdController)
    {
        Id accountId=stdController.getId();
        system.debug('accountId:'+ accountId);
        Account accountInfo=[Select Id, Deployment_Engineering__c from Account where Id=:accountId];
        if(accountInfo!=null)
        {
            IsDEAccount= accountInfo.Deployment_Engineering__c;
        }
    }
}