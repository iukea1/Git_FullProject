/*
 * Controller of page PatchUserReplace
 */
public class PatchUserReplaceController 
{
    public PatchUserReplaceController()
    {
        String patchId = ApexPages.currentPage().getParameters().get('pid');
        if(String.isNotBlank(patchId) && patchId instanceOf Id)
        {
            SelectedPatch = patchId;
        }
        Temp = new Patch__c();
        String userId = ApexPages.currentPage().getParameters().get('uid');
        if(String.isNotBlank(userId) && userId instanceOf Id)
        {
            Temp.RSM__c = userId;
        }
    }
    
    public Patch__c Temp { get; set; } //used for quick page bound. RSM for source user, ISR for dest user.
    public Id SelectedPatch { get; set; }
    public Boolean Realign { get; set; }
    
    public List<SelectOption> Patches
    {
        get
        {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('', '- All Patches -'));
            for(Patch__c patch : [select Id, Patch_Name__c from Patch__c order by ProcessingSequence__c])
            {
                result.add(new SelectOption(patch.Id, patch.Patch_Name__c));
            }
            return result;
        }
    }
    
    public PageReference save()
    {
        if(Temp.RSM__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must select a source user to be replaced.'));
            return null;
        }
        List<Patch__c> patches = new List<Patch__c>();
        List<SalesTeamMember__c> teamMembers = new List<SalesTeamMember__c>();
        if(String.isNotBlank(SelectedPatch))
        {
            patches.addAll([select Id, Owner__c, IsSalesTeam__c, RSM__c, ISR__c, CSM__c, SE__c from Patch__c where Id=:SelectedPatch limit 1]);
            teamMembers = [select Id, User__c, SalesTeam__r.Patch__c from SalesTeamMember__c where SalesTeam__r.Patch__c = :SelectedPatch and User__c = :Temp.RSM__c];
        }
        else
        {
            patches.addAll([select Id, Owner__c, IsSalesTeam__c, RSM__c, ISR__c, CSM__c, SE__c from Patch__c]);
            teamMembers = [select Id, User__c, SalesTeam__r.Patch__c from SalesTeamMember__c where User__c = :Temp.RSM__c];
        }
        
        Set<Id> updatedPatchIds = new Set<Id>();
        for(Patch__c patch : patches)
        {
            Boolean replaced = replaceUser(patch, Temp.RSM__c, Temp.ISR__c);
            if(replaced) updatedPatchIds.add(patch.Id);
        }

        teamMembers = replaceTeamMembers(teamMembers, Temp.ISR__c);
        for(SalesTeamMember__c member : teamMembers)
        {
            updatedPatchIds.add(member.SalesTeam__r.Patch__c);
        }

        try
        {
            update patches;
            update teamMembers;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'User has been replaced.'));
            if(Realign)
            {
                List<Id> patchIds = new List<Id>();
                for(Id patchId : updatedPatchIds)
                {
                    patchIds.add(patchId);
                }

                return new PageReference('/apex/PatchRealign?id=' + String.join(patchIds, ',') + '&start=1');
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    private Boolean replaceUser(Patch__c patch, Id fromUser, Id toUser)
    {
        Boolean replaced = false;
        if(patch.Owner__c == fromUser)
        {
            patch.Owner__c = toUser;
            replaced = true;
        }
        if(patch.RSM__c == fromUser)
        {
            patch.RSM__c = toUser;
            replaced = true;
        }
        if(patch.ISR__c == fromUser)
        {
            patch.ISR__c = toUser;
            replaced = true;
        }
        if(patch.CSM__c == fromUser)
        {
            patch.CSM__c = toUser;
            replaced = true;
        }
        if(patch.SE__c == fromUser)
        {
            patch.SE__c = toUser;
            replaced = true;
        }
        return replaced;
    }

    private List<SalesTeamMember__c> replaceTeamMembers(List<SalesTeamMember__c> members, Id toUser)
    {
        for(SalesTeamMember__c member : members)
        {
            member.User__c = toUser;
        }
        return members;
    }
}