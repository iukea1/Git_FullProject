/*
 * Controller of page PatchOverride
 */
public with sharing class PatchOverrideController 
{
    private sObject obj;

    public PatchOverrideController()
    {
        Id objId = ApexPages.currentPage().getParameters().get('id');
        IsAllowed = true;
        obj = PatchRuleHelper.getSObject(objId);
        ObjectName = (String)obj.get('Name');
        SegmentationTypeAccount = new Account();
        if(obj != null)
        {
            if((Boolean)obj.get('Patch_Locked__c'))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Record is locked, you can\'t override the patch'));
                IsAllowed = false;
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Object is not found'));
        }
    }

    public Boolean IsAllowed { get; set; }
    public String CompanyName { get; set; }
    public String EmailDomain { get; set; }
    public String Country { get; set; }
    public String State { get; set; }
    public String ZipCode { get; set; }
    public String Industry { get; set; }
    public Account SegmentationTypeAccount { get; set; }
    public String ObjectName { get; set; }

    public PageReference reassign()
    {
        PatchRuleEngineBase.Target target = getPatchTarget();
        try
        {
            PatchRuleEngine engine = new PatchRuleEngine();
            PatchRuleEngineBase.Match match = engine.match(target);
            Id patchId = match.PatchId;
            PatchRuleHelper.OverlayHolder.put(obj.Id, match.OverlayMatches);
            PatchRuleHelper.OverrideSegmentationType = SegmentationTypeAccount.SegmentationType__c;
            if(patchId == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No match found. Please try with another values.'));
                return null;
            }
            List<Patch__c> patchs = [select Id, IsSalesTeam__c, Patch_Name__c, Catchall__c, Type__c, Owner__c, Owner__r.GEO__c, RSM__c, CSM__c, 
                                            SE__c, ISR__c, Active__c, Overlay_1__c, Overlay_2__c 
                                        from Patch__c where Id=:patchId limit 1];
            if(patchs.size() == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error occured. Patch Rules need re-deployment'));
                return null;
            }

            if(patchs[0].IsSalesTeam__c)
            {
                Map<String, List<SalesTeamMember__c>> type2membersMap = new Map<String, List<SalesTeamMember__c>>();
                for(SalesTeamMember__c member : [select Id, User__c, Role__c, SalesTeam__r.Type__c, SalesTeam__r.Patch__c 
                                                   from SalesTeamMember__c where SalesTeam__r.Patch__c = :patchId])
                {
                    if(type2membersMap.containsKey(member.SalesTeam__r.Type__c))
                    {
                        type2membersMap.get(member.SalesTeam__r.Type__c).add(member);
                    }
                    else
                    {
                        type2membersMap.put(member.SalesTeam__r.Type__c, new List<SalesTeamMember__c>{ member });
                    }
                }
                PatchRuleHelper.assignPatchBySalesTeams(obj, patchs[0], null, type2membersMap);
            }
            else
            {
                PatchRuleHelper.assignPatch(obj, patchs[0]);
            }
            obj.put('Patch_Locked__c', true);
            update obj;

            PatchRuleHelper.AssignTeamMembers(new List<Id> { obj.Id });
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Patch reassigned.<script>opener.location=\'/'+obj.Id+'\';setTimeout("window.close()", 3000);</script>'));
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to reassign, the error message is: ' + ex.getMessage()));
        }
        return null;
    }

    private PatchRuleEngineBase.Target getPatchTarget()
    {
        PatchRuleEngineBase.Target target = new PatchRuleEngineBase.Target();
        target.Company = CompanyName;
        target.EmailDomain = PatchRuleHelper.getEmailDomain(EmailDomain);
        target.Country = Country;
        target.ZipCode = ZipCode;
        target.State = State;
        target.Industry = Industry;
        return target;
    }
}