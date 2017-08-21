trigger ResubmitPR on Purchasing_Request__c (before update) {
    //The trigger fires only when size = 1
    if(trigger.new.Size() == 1)
    {
        Purchasing_Request__c pr = trigger.new[0];
        if(pr.Recall_process__c == true)
        {
            List<ProcessInstance> pi = new List<ProcessInstance>([Select Id from ProcessInstance where Status = 'Pending' and TargetObjectId = : pr.Id]);
            if(!pi.isEmpty())
            {
                List<ProcessInstanceWorkitem> workitems = new List<ProcessInstanceWorkitem>([select Id from ProcessInstanceWorkitem where ProcessInstanceId = :pi[0].id]);
                if(!workitems.isEmpty())
                {
                    Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
                    pwr.setComments('The Estimated Silver Peak Amount of related funding request has been increased');
                    pwr.setWorkItemId(workitems[0].Id);
                    pwr.setAction('Removed');
                    Approval.processResult prt = Approval.Process(pwr);
                    if(prt.getInstanceStatus() == 'Removed')
                    {
                        system.debug('success');
                    }
                    else
                    {
                        SilverPeakUtils.logException('Failed to recall Purchase Request. [Id=' + pr.Id + ']');
                    }
                }
                pr.Recall_process__c = false;
            }
        }
    }
}