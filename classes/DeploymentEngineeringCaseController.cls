public class DeploymentEngineeringCaseController {
    public boolean IsDEAccount {get;set;}
    
    public DeploymentEngineeringCaseController(ApexPages.StandardController stdController)
    {
        Id caseId=stdController.getId();
        system.debug('caseId:'+ caseId);
        Case caseInfo=[Select Id,AccountId, Account.Name,Account.Deployment_Engineering__c,IsClosed from Case where Id=:caseId];
        if(caseInfo!=null)
        {
            IsDEAccount= caseInfo.Account.Deployment_Engineering__c && !caseInfo.IsClosed;
        }
        
    }
}