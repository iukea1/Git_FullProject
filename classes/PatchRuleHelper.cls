/*
* Includes helper methods for triggers and classes related to Patch Assignment and Patch Matching
*/
public class PatchRuleHelper
{
    public static List<Id> leadsNeedAssignment;
    public static Patch__c SPCatchAllPatch;
    public static Map<Id, List<Id>> overlayHolder; //this map temporarily holds the result after patch match. because assignPatch and assignTeamMember are in different method call. assignPatch puts result to the map so that assignTeamMember will read it
    public static String OverrideSegmentationType;

    static
    {
        leadsNeedAssignment = new List<Id>();
        overlayHolder = new Map<Id, List<Id>>();
        SPCatchAllPatch =new Patch__c();
        OverrideSegmentationType = null;
    }
    
    @future
    public static void willAssignPatch(List<Id> recordIds)
    {
        assignPatch(recordIds);
    }
    
    public static void assignPatch(List<Id> recordIds)
    {
        if(recordIds == null || recordIds.size() == 0)
        {
            return;
        }
        List<sObject> objs = getSObjects(recordIds);
        assignPatches(objs);
        if(objs.size() > 0)
        {
            Database.SaveResult[] saveResults = Database.update(objs, false);
            SilverPeakUtils.logDatabaseError(objs, saveResults);
        }
    }
    
    public static void assignPatches(List<sObject> objs)
    {
        Map<Id, Patch__c> patches = new Map<Id, Patch__c>();
        //Add patchIds To Match team members. Lei
        List<Id> patchIds = new List<Id>();
        for(Patch__c patch : [select Id, Name,Patch_Name__c, Catchall__c, Type__c, IsSalesTeam__c, Owner__c, Owner__r.GEO__c, RSM__c, RSS__c, CSM__c, SE__c, ISR__c, Overlay_1__c, Overlay_2__c, Active__c, Overlay__c, FCMM__c from Patch__c])
        {
            patchIds.add(Patch.Id);
            patches.put(patch.Id, patch);
            if(patch.Name=='P-603')
            {
                SPCatchAllPatch=patch;
                System.debug('SPCatchAllPatch'+SPCatchAllPatch);
            }
        }
        Map<Id, Map<String, List<SalesTeamMember__c>>> patchId2Type2Members = getSalesTeamMembers(patchIds);
        Map<Id, String> ownerGEO = new Map<Id, String>();

        for(sObject obj : objs)
        {
            Id patchId = null;
            Id geoPatchId = null;
            if(obj instanceOf Lead && (Boolean)obj.get('Patch_Locked__c'))
            {
                //if a lead is locked, we keep the patch member up to date, leave the patch unchanged
                patchId = (Id)obj.get('Patch__c');
            }
            else
            {
                PatchRuleEngineBase.Target target = getTarget(obj);
                PatchRuleEngine engine = new PatchRuleEngine();
                PatchRuleEngineBase.Match match = engine.match(target);
                if(match != null)
                {
                    patchId = match.PatchId;
                    geoPatchId = match.GeoPatchId == null ? match.PatchId : match.GeoPatchId;
                    overlayHolder.put(obj.Id, match.OverlayMatches);
                }
            }

            Patch__c patch = patches.get(patchId);
            if(patch == null || patch.IsSalesTeam__c == false)
            {
                assignPatch(obj, patch, geoPatchId);    
            }
            else
            {
                Map<String, List<SalesTeamMember__c>> type2Members = patchId2Type2Members.containsKey(patchId) ? patchId2Type2Members.get(patchId) : new Map<String, List<SalesTeamMember__c>>();
                assignPatchBySalesTeams(obj, patch, geoPatchId, type2Members);
            }
            ownerGEO.put((Id)obj.get('OwnerId'), null);
        }
        for(User usr : [select Id, GEO_Region__c from User where Id in :ownerGEO.keyset()])
        {
            ownerGEO.put(usr.Id, usr.GEO_Region__c);
        }
        for(sObject obj : objs)
        {
            if(obj instanceOf Lead)
            {
                Lead ld = (Lead)obj;
                if(ownerGEO.get(ld.OwnerId) != null)
                {
                    ld.GEO__c = ownerGEO.get(ld.OwnerId);
                }
            }
        }
    }
    
    public static void assignPatch(sObject obj, Patch__c patch)
    {
        assignPatch(obj, patch, null);
    }
    
    public static void assignPatch(sObject obj, Patch__c patch, Id additionalPatch)
    {
        Boolean locked = (Boolean)obj.get('Patch_Locked__c');

        if(patch != null)
        {
            if(obj instanceOf Lead)
            {
                Lead ld = (Lead)obj;
                if(ld.ECSP__c)
                {
                    if(patch.Type__c!='Named Accounts')
                    {
                        patch=SPCatchAllPatch;
                    }
                }
                ld.Patch__c = patch.Id;
                ld.Geo_Patch__c = additionalPatch;
                ld.Patch_Owner__c = patch.Owner__c;
                ld.RSM__c = patch.RSM__c;
                ld.SE__c = patch.SE__c;
                ld.CSM__c = patch.CSM__c;
                ld.ISR__c = patch.ISR__c;
                ld.SalesTeamMatched__c = ld.ENT_CAM__c = ld.ENT_RSM__c = ld.ENT_ISR__c = ld.MAJ_CAM__c = ld.MAJ_RSM__c = ld.MAJ_ISR__c = ld.SP_CAM__c = ld.SP_RSM__c = ld.SP_ISR__c = null;
                
                if(patch.ISR__c != null)
                {
                    ld.OwnerId = patch.ISR__c;
                }
                if(ld.LeadSource == 'Deal Registration')
                {
                    Map<String, Schema.RecordTypeInfo> leadRecordTypes = Schema.SObjectType.Lead.getRecordTypeInfosByName();
                    if(leadRecordTypes.get('Deal Registration') != null && leadRecordTypes.get('Deal Registration').getRecordTypeId() == ld.RecordTypeId)
                    {
                        //for the deal registration process, NAM goes to CSM, non-NAM goes to RSM
                        if(patch.ISR__c != null && (patch.Owner__r.GEO__c == null || patch.Owner__r.GEO__c.contains('NAM') || patch.Owner__r.GEO__c.contains('GAM')))
                        {
                            ld.OwnerId = patch.ISR__c;
                        }
                        else if(patch.RSM__c != null)
                        {
                            ld.OwnerId = patch.RSM__c;
                        }
                    }
                }
                
            }
            else if(obj instanceOf Account)
            {
                if(locked == true)
                {
                    throw new SilverPeakException('Patch is locked, and cannot be reassigned.');
                }
                Account acc = (Account)obj;
                if(acc.ECSP__c)
                {
                    if(patch.Type__c!='Named Accounts')
                    {
                        patch=SPCatchAllPatch;
                    }
                }
                acc.Patch__c = patch.Id;
                acc.Geo_Patch__c = additionalPatch;
                acc.SalesTeamMatched__c = null;
            }
            else if(obj instanceOf Opportunity)
            {
                if(locked == true)
                {
                    throw new SilverPeakException('Patch is locked, and cannot be reassigned.');
                }
                Opportunity opportunity = (Opportunity)obj;
                if(opportunity.Account.ECSP__c && patch.Type__c!='Named Accounts')
                {
                    patch=SPCatchAllPatch;
                }
                opportunity.Patch__c = patch.Id;
                opportunity.Bypassing_Validation__c = true;
                opportunity.Patch_Locked__c = opportunity.Account.Patch_Locked__c;
                opportunity.SalesTeamMatched__c = null;
            }
        }
        else
        {
            if(obj instanceOf Lead)
            {
                Lead ld = (Lead)obj;
                ld.Patch__c = ld.CSM__c = ld.ISR__c = ld.Patch_Owner__c = ld.RSM__c = ld.SE__c = null;
                ld.SalesTeamMatched__c = ld.ENT_CAM__c = ld.ENT_RSM__c = ld.ENT_ISR__c = ld.MAJ_CAM__c = ld.MAJ_RSM__c = ld.MAJ_ISR__c = ld.SP_CAM__c = ld.SP_RSM__c = ld.SP_ISR__c = null;
            }
            else if(obj instanceOf Account || obj instanceOf Opportunity)
            {
                obj.put('Patch__c', null);
                obj.put('SalesTeamMatched__c', null);
            }
        }

        obj.put('Trigger_Assignment__c', false);
    }

    public static void assignPatchBySalesTeams(sObject obj, Patch__c patch, Id additionalPatch, Map<String, List<SalesTeamMember__c>> type2members)
    {
        Boolean locked = (Boolean)obj.get('Patch_Locked__c');

        if(patch != null)
        {
            String segmentType = (OverrideSegmentationType != null ? OverrideSegmentationType : (String)obj.get('SegmentationType__c'));
            Id matchedSalesTeamId = type2Members.containsKey(segmentType) ? type2Members.get(segmentType)[0].SalesTeam__c : null;

            if(obj instanceOf Lead) 
            {
                Lead ld = (Lead)obj;
                if(ld.ECSP__c)
                {
                    if(patch.Type__c!='Named Accounts')
                    {
                        patch = SPCatchAllPatch;
                    }
                }

                ld.Patch__c = patch.Id;
                ld.Patch_Owner__c = patch.Owner__c;
                ld.Geo_Patch__c = additionalPatch;
                ld.SalesTeamMatched__c = matchedSalesTeamId;
                ld.CSM__c = ld.ISR__c = ld.RSM__c = ld.SE__c = null;
                ld.ENT_CAM__c = ld.ENT_RSM__c = ld.ENT_ISR__c = ld.MAJ_CAM__c = ld.MAJ_RSM__c = ld.MAJ_ISR__c = ld.SP_CAM__c = ld.SP_RSM__c = ld.SP_ISR__c = null;

                Map<String, Map<String, Id>> type2Role2MemberId = new Map<String, Map<String, Id>>();
                for(String salesTeamType : type2members.keySet())
                {
                    type2Role2MemberId.put(salesTeamType, new Map<String, Id>());
                    for(SalesTeamMember__c member : type2Members.get(salesTeamType))
                    {
                        type2Role2MemberId.get(salesTeamType).put(member.Role__c, member.User__c);
                    }
                }

                if(segmentType == Label.SegmentationType_Enterprise || segmentType == null)
                {
                    Map<String, Id> role2MemberId = type2Role2MemberId.containsKey(Label.SegmentationType_Enterprise) ? type2Role2MemberId.get(Label.SegmentationType_Enterprise) : new Map<String, Id>();
                    ld.ENT_CAM__c = role2MemberId.get(Label.SalesTeamMemberRole_CAM);
                    ld.ENT_RSM__c = role2MemberId.get(Label.SalesTeamMemberRole_RSM);
                    ld.ENT_ISR__c = role2MemberId.get(Label.SalesTeamMemberRole_ISR);
                }
                if (segmentType == Label.SegmentationType_Majors || segmentType == null) 
                {
                    Map<String, Id> role2MemberId = type2Role2MemberId.containsKey(Label.SegmentationType_Majors) ? type2Role2MemberId.get(Label.SegmentationType_Majors) : new Map<String, Id>();
                    ld.MAJ_CAM__c = role2MemberId.get(Label.SalesTeamMemberRole_CAM);
                    ld.MAJ_RSM__c = role2MemberId.get(Label.SalesTeamMemberRole_RSM);
                    ld.MAJ_ISR__c = role2MemberId.get(Label.SalesTeamMemberRole_ISR);
                }
                if(segmentType == Label.SegmentationType_ServiceProvider || segmentType == null)
                {
                    Map<String, Id> role2MemberId = type2Role2MemberId.containsKey(Label.SegmentationType_ServiceProvider) ? type2Role2MemberId.get(Label.SegmentationType_ServiceProvider) : new Map<String, Id>();
                    ld.SP_CAM__c = role2MemberId.get(Label.SalesTeamMemberRole_CAM);
                    ld.SP_RSM__c = role2MemberId.get(Label.SalesTeamMemberRole_RSM);
                    ld.SP_ISR__c = role2MemberId.get(Label.SalesTeamMemberRole_ISR);
                }

                Map<String, Id> role2MemberId = type2Role2MemberId.containsKey(segmentType) ? type2Role2MemberId.get(segmentType) : new Map<String, Id>();
                if(role2MemberId.containsKey(Label.SalesTeamMemberRole_ISR))
                {
                    ld.OwnerId = role2MemberId.get(Label.SalesTeamMemberRole_ISR);    
                }

                if(ld.LeadSource == 'Deal Registration')
                {
                    Id dealRegRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();
                    if(dealRegRecordTypeId == ld.RecordTypeId)
                    {
                        //for the deal registration process, NAM goes to CSM, non-NAM goes to RSM
                        if(role2MemberId.containsKey(Label.SalesTeamMemberRole_ISR) && (patch.Owner__r.GEO__c == null || patch.Owner__r.GEO__c.contains('NAM') || patch.Owner__r.GEO__c.contains('GAM')))
                        {
                            ld.OwnerId = role2MemberId.get(Label.SalesTeamMemberRole_ISR);
                        }
                        else if(role2MemberId.containsKey(Label.SalesTeamMemberRole_RSM))
                        {
                            ld.OwnerId = role2MemberId.get(Label.SalesTeamMemberRole_RSM);
                        }
                    }
                }
            }
            else if(obj instanceOf Account)
            {
                if(locked == true)
                {
                    throw new SilverPeakException('Patch is locked, and cannot be reassigned.');
                }
                Account acc = (Account)obj;
                if(acc.ECSP__c)
                {
                    if(patch.Type__c!='Named Accounts')
                    {
                        patch=SPCatchAllPatch;
                    }
                }
                acc.Patch__c = patch.Id;
                acc.Geo_Patch__c = additionalPatch;
                acc.SalesTeamMatched__c = matchedSalesTeamId;
            }
            else if(obj instanceOf Opportunity)
            {
                if(locked == true)
                {
                    throw new SilverPeakException('Patch is locked, and cannot be reassigned.');
                }
                Opportunity opportunity = (Opportunity)obj;
                if(opportunity.Account.ECSP__c && patch.Type__c!='Named Accounts')
                {
                    patch=SPCatchAllPatch;
                }
                opportunity.Patch__c = patch.Id;
                opportunity.Bypassing_Validation__c = true;
                opportunity.Patch_Locked__c = opportunity.Account.Patch_Locked__c;
                opportunity.SalesTeamMatched__c = matchedSalesTeamId;
            }
        }
        else
        {
            if(obj instanceOf Lead)
            {
                Lead ld = (Lead)obj;
                ld.Patch__c = ld.Patch_Owner__c = null;
                ld.CSM__c = ld.ISR__c = ld.RSM__c = ld.SE__c = null;
                ld.SalesTeamMatched__c = ld.ENT_CAM__c = ld.ENT_RSM__c = ld.ENT_ISR__c = ld.MAJ_CAM__c = ld.MAJ_RSM__c = ld.MAJ_ISR__c = ld.SP_CAM__c = ld.SP_RSM__c = ld.SP_ISR__c = null;
            }
            else if(obj instanceOf Account || obj instanceOf Opportunity)
            {
                obj.put('Patch__c', null);
                obj.put('SalesTeamMatched__c', null);
            }
        }

        obj.put('Trigger_Assignment__c', false);
    }

    public static Map<Id, Map<String, List<SalesTeamMember__c>>> getSalesTeamMembers(List<Id> patchIds)
    {
        Map<Id, Map<String, List<SalesTeamMember__c>>> patchId2Type2Members = new Map<Id, Map<String, List<SalesTeamMember__c>>>();
        for(SalesTeamMember__c member : [select Id, User__c, Role__c, SalesTeam__r.Type__c, SalesTeam__r.Patch__c 
                                            from SalesTeamMember__c 
                                            where SalesTeam__r.Patch__r.IsSalesTeam__c = TRUE and SalesTeam__r.Patch__c in :patchIds])
        {
            Id patchId = member.SalesTeam__r.Patch__c;
            Map<String, List<SalesTeamMember__c>> type2Members = new Map<String, List<SalesTeamMember__c>>();
            if(patchId2Type2Members.containsKey(patchId))
            {
                type2Members = patchId2Type2Members.get(patchId);
            }
            
            if(type2Members.containsKey(member.SalesTeam__r.Type__c))
            {
                type2Members.get(member.SalesTeam__r.Type__c).add(member);
            }
            else
            {
                type2Members.put(member.SalesTeam__r.Type__c, new List<SalesTeamMember__c>{ member } );   
            }
            patchId2Type2Members.put(patchId, type2Members);
        }

        return patchId2Type2Members;
    }
    
    public static List<sObject> getPatchSharings(List<sObject> objs)
    {
        Set<Id> patchIds = new Set<Id>();
        for(sObject obj : objs)
        {
            patchIds.add((Id)obj.get('Patch__c'));
        }
        for(Id tempId : OverlayHolder.keyset())
        {
            List<Id> overlayPatches = OverlayHolder.get(tempId);
            patchIds.addAll(overlayPatches);
        }
        List<Id> patchIdList = new List<Id>(patchIds);
        Map<Id, Patch__c> patchMap = new Map<Id, Patch__c>([select Id, IsSalesTeam__c, CSM__c, SE__c, ISR__c, RSS__c,RSM__c, Overlay_1__c, Overlay_2__c, Owner__c, Overlay__c, FCMM__c from Patch__c where Id in :patchIds]);
        Map<Id, Map<String, List<SalesTeamMember__c>>> patchId2Type2Members = getSalesTeamMembers(patchIdList);
        
        List<sObject> result = new List<sObject>();
        for(sObject obj : objs)
        {
            Id patchId = (Id)obj.get('Patch__c');
            if(patchId != null && patchMap.containsKey(patchId))
            {
                Patch__c patch = patchMap.get(patchId);
                if(patch != null && patch.IsSalesTeam__c)
                {
                    String segmentType = OverrideSegmentationType;
                    if(segmentType == null)
                    {
                        segmentType = obj.get('SegmentationType__c') != null ? (String)obj.get('SegmentationType__c') : Label.SegmentationType_Default;
                    }
                    Map<String, List<SalesTeamMember__c>> type2Members = patchId2Type2Members.containsKey(patchId) ? patchId2Type2Members.get(patchId) : new Map<String, List<SalesTeamMember__c>>();
                    List<SalesTeamMember__c> salesTeamMembers = type2Members.containsKey(segmentType) ? type2Members.get(segmentType) : new List<SalesTeamMember__c>();
                    result.addAll(getPatchSharingBySalesTeams(obj, patch, salesTeamMembers));
                }
                else
                {
                    result.addAll(getPatchSharing(obj, patch));
                }
            }

            List<Id> overlayPatches = OverlayHolder.get(obj.Id);
            if(overlayPatches != null && overlayPatches.size() > 0)
            {
                for(Id overlayPatchId : overlayPatches)
                {
                    Patch__c patch = patchMap.get(overlayPatchId);
                    result.addAll(getPatchSharing(obj, patch));
                }
            }
        }
        return result;
    }
    
    /*@future
    public static void willAssignTeamMembers(List<Id> objIds)
    {
        assignTeamMembers(objIds);
    }*/
    
    public static void assignTeamMembers(List<Id> objIds)

    {
        if(objIds == null || objIds.size() == 0)
        {
            return;
        }
        SavePoint sp = Database.setSavePoint();
        try
        {
            List<sObject> objs = getSObjects(objIds);
            if(objs.size() > 0)
            {
                if(objs[0] instanceOf Lead)
                {
                    List<Lead> effectiveObjs = new List<Lead>();
                    List<Id> leadIds = new List<Id>();
                    for(sObject obj : objs)
                    {
                        Lead ld = (Lead)obj;
                        if(!ld.IsConverted)
                        {
                            effectiveObjs.add(ld);
                            leadIds.add(ld.Id);
                        }
                    }
                    if(effectiveObjs.size() > 0)
                    {
                        Database.delete([select Id from LeadShare where LeadId in :effectiveObjs], false);
                        Database.insert(getPatchSharings(effectiveObjs), false);
                        //ShareLeadAndOpportunityToPartnerHelper.willShareLeads(leadIds);
                    }
                }
                else if(objs[0] instanceOf Opportunity)
                {
                    List<Opportunity> effectiveOpps = new List<Opportunity>();
                    List<Id> oppIds = new List<Id>();
                    Set<Id> oppIdsForOpportunityShare = new Set<Id>();
                    Set<Id> oppUserIdsForOpportunityShare = new Set<Id>();
                    for(sObject obj : objs)
                    {
                        Opportunity opp = (Opportunity)obj;
                        if(!opp.IsClosed)
                        {
                            effectiveOpps.add(opp);
                            oppIds.add(opp.Id);
                        }
                    }
                    if(effectiveOpps.size() > 0)
                    {
                        List<OpportunityTeamMember> oldOppMembers = [select Id from OpportunityTeamMember where OpportunityId in :effectiveOpps and IsAddedByPatch__c = True];
                        if(oldOppMembers.size() > 0)
                        {
                            Database.DeleteResult[] result = Database.delete(oldOppMembers, false);
                            //SilverPeakUtils.logDatabaseError(oldOppMembers, result);
                        }

                        List<sObject> teamMembers = getPatchSharings(effectiveOpps);
                        System.debug('Opportunity Team: '  + teamMembers);
                        Database.SaveResult[] result = Database.insert(teamMembers, false);
                        System.debug('result: '  + result);
                        //SilverPeakUtils.logDatabaseError(teamMembers, result);
                        //ShareLeadAndOpportunityToPartnerHelper.willShareOpportunities(oppIds);
                        
                        for(sObject obj: teamMembers)
                        {
                            String oppTeamMemberRole = (String)obj.get('TeamMemberRole');
                            Id oppUserIdForShare = (Id)obj.get('UserId');
                            Id oppIdForShare = (Id)obj.get('OpportunityId');
                            if(oppTeamMemberRole != null && oppTeamMemberRole != 'Field and Channel Marketing Manager')
                            {    
                                oppIdsForOpportunityShare.add(oppIdForShare);
                                oppUserIdsForOpportunityShare.add(oppUserIdForShare);
                            }
                        }  
                        System.debug('before');
                        EditAccessToOppTeam(oppIdsForOpportunityShare, OppUserIdsForOpportunityShare);
                        System.debug('after');
                    }
                }
                else if(objs[0] instanceOf Account)
                {
                    //Remove old account team members
                    List<String> oldMemberIdsFromPatch = new List<String>();
                    for(sObject sObj : objs)
                    {
                        Account acct = (Account)sObj;
                        if(String.isNotEmpty(acct.TeamMemberIdFromPatch__c))
                        {
                            oldMemberIdsFromPatch.addAll(acct.TeamMemberIdFromPatch__c.split(','));
                        }
                    }
                    List<AccountTeamMember> oldAccMembers = [select Id from AccountTeamMember where AccountId in: objs and Id in :oldMemberIdsFromPatch];
                    if(oldAccMembers.size() > 0)
                    {
                        Database.DeleteResult[] deletionResults = Database.delete(oldAccMembers, false);
                        SilverPeakUtils.logDatabaseError(oldAccMembers, deletionResults);
                    }

                    //Add new account team members
                    List<AccountTeamMember> teamMembers = (List<AccountTeamMember>)getPatchSharings(objs);
                    Database.SaveResult[] insertResults = Database.insert(teamMembers, false);
                    SilverPeakUtils.logDatabaseError(teamMembers, insertResults);

                    //Update new account team member Id on account
                    Map<Id, Account> id2Account = new Map<Id, Account>();
                    for(AccountTeamMember teamMember : teamMembers)
                    {
                        if(teamMember.Id != null)
                        {
                            Account acct = id2Account.containsKey(teamMember.AccountId) ? id2Account.get(teamMember.AccountId) : new Account(Id=teamMember.AccountId, TeamMemberIdFromPatch__c='');
                            acct.TeamMemberIdFromPatch__c += teamMember.Id + ',';
                            id2Account.put(acct.Id, acct);
                        }
                    }
                    if(id2Account.size() > 0) update id2Account.values();
                }
            }
        }
        catch(Exception ex)
        {
            throw ex;
            Database.rollback(sp);
            SilverPeakUtils.logException('Failed to assign team members, record id: ' + objIds);
            SilverPeakUtils.logException(ex);
        }
    }
    
    @future
    public static void refreshPatchTimestamp(Set<Id> patchIds)
    {
        List<Patch__c> patches = [select Id, Timestamp__c from Patch__c where Id in :patchIds];
        for(Patch__c patch : patches)
        {
            patch.Timestamp__c = System.now();
        }
        try
        {
            update patches;
        }
        catch(Exception ex)
        {
            SilverPeakUtils.logException(ex);
        }
    }
    
    public static Long LastDeploymentDate
    {
        get
        {
            List<ApexClass> engineClass = [select LastModifiedDate from ApexClass where Name='PatchRuleEngine' limit 1];
            if(engineClass.size() > 0)
            {
                return engineClass[0].LastModifiedDate.getTime();
            }
            return 0;
        }
    }
    
    //supports acc/opp/lead Id
    public static sObject getSObject(Id recordId)
    {
        List<sObject> result = getSObjects(new List<Id> { recordId });
        if(result.size() > 0)
        {
            return result[0];
        }
        return null;
    }
    
    //supports acc/opp/lead Id
    public static List<sObject> getSObjects(List<Id> recordIds)
    {
        List<sObject> result = new List<sObject>();
        Set<Id> accIds = new Set<Id>(), oppIds = new Set<Id>(), leadIds = new Set<Id>();
        for(Id recordId : recordIds)
        {
            String recordIdStr = recordId + '';
            if(recordIdStr.startsWith('001'))
            {
                accIds.add(recordId);
            }
            else if(recordIdStr.startsWith('00Q'))
            {
                leadIds.add(recordId);
            }
            else if(recordIdStr.startsWith('006'))
            {
                oppIds.add(recordId);
            }
        }
        if(accIds.size() > 0)
        {
            result.addAll((List<sObject>)[select Id, Name, OwnerId, Patch__c, SegmentationType__c, TeamMemberIdFromPatch__c, BillingCountry, BillingPostalCode, BillingState, Industry, Type, Patch_Locked__c, GEO_Supported__c,ECSP__c from Account where Id in :accIds]);
        }
        if(leadIds.size() > 0)
        {
            result.addAll((List<sObject>)[select Id, Name, OwnerId, Patch__c, SegmentationType__c, IsConverted, Company, Email, Country, State, PostalCode, Industry, Ownership_Routing__c, Patch_Locked__c, Trial_Request_from_Marketplace__c, LeadSource, RecordTypeId, GEO__c,ECSP__c from Lead where Id in :leadIds]);
        }
        if(oppIds.size() > 0)
        {
            result.addAll((List<sObject>)[select Id, Name, OwnerId, Patch__c, SegmentationType__c, Type, IsClosed, IsWon, StageName, Transactional_Opportunity__c, Technical_Responsible__c, AccountId, Account.Name, Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.Industry, Account.Patch__c, Account.Patch__r.Id, Account.Patch__r.RSM__c, Account.Patch_Locked__c, Patch_Locked__c,Account.ECSP__c from Opportunity where Id in :oppIds]);
        }
        return result;
    }
    
    //supports acc/opp/lead object
    public static PatchRuleEngineBase.Target getTarget(sObject obj)
    {
        PatchRuleEngineBase.Target target = new PatchRuleEngineBase.Target();
        if(obj instanceOf Account)
        {
            Account acc = (Account)obj;
            target.Company = acc.Name;
            //target.EmailDomain = acc.Email;
            target.Country = acc.BillingCountry;
            target.ZipCode = acc.BillingPostalCode;
            target.State = acc.BillingState;
            target.Industry = acc.Industry;
            target.Locked = acc.Patch_Locked__c;
        }
        else if(obj instanceOf Lead)
        {
            Lead ld = (Lead)obj;
            target.Company = ld.Company;
            target.EmailDomain = getEmailDomain(ld.Email);
            target.Country = ld.Country;
            target.ZipCode = ld.PostalCode;
            target.State = ld.State;
            target.Industry = ld.Industry;
            target.Locked = ld.Patch_Locked__c;
        }
        else if(obj instanceOf Opportunity)
        {
            Opportunity opp = (Opportunity)obj;
            target.Company = opp.Account.Name;
            //target.EmailDomain = opp.Email;
            target.Country = opp.Account.BillingCountry;
            target.ZipCode = opp.Account.BillingPostalCode;
            target.State = opp.Account.BillingState;
            target.Industry = opp.Account.Industry;
            target.Locked = opp.Patch_Locked__c;
        }
        return target;
    }
    
    public static Boolean isSameTarget(PatchRuleEngineBase.Target a, PatchRuleEngineBase.Target b)
    {
        return a.Company == b.Company && a.EmailDomain == b.EmailDomain && a.Country == b.Country && a.ZipCode == b.ZipCode && a.State == b.State && a.Industry == b.Industry;
    }
    
    public static String getEmailDomain(String email)
    {
        email = (email == null) ? '' : email;
        return (email.indexOf('@') >= 0) ? email.substring(email.indexOf('@') + 1) : email;
    }
    
    public static List<String> splitCsv(String line)
    {
        List<String> result = new List<String>();
        Boolean itemStarted = true;
        Boolean isQuoteItem = false;
        String tempValue = '';
        for(Integer i = 0 ; i < line.length(); i++)
        {
            String c = line.mid(i, 1);
            if(c == ',')
            {
                if(itemStarted && !isQuoteItem)
                {
                    itemStarted = false;
                    result.add(tempValue.trim());
                    tempValue = '';
                }
                else if(itemStarted && isQuoteItem)
                {
                    tempValue += c;
                }
            }
            else if(c == ' ')
            {
                if(itemStarted)
                {
                    tempValue += c;
                }
            }
            else if(c == '"')
            {
                if(!itemStarted)
                {
                    itemStarted = true;
                    isQuoteItem = true;
                }
                else if(itemStarted && isQuoteItem)
                {
                    isQuoteItem = false;
                }
                else if(itemStarted && !isQuoteItem)
                {
                    tempValue += c;
                }
            }
            else
            {
                itemStarted = true;
                tempValue += c;
            }
        }
        result.add(tempValue.trim());
        return result;
    }
    
    @testvisible
    private static List<sObject> getPatchSharing(sObject obj, Patch__c patch)
    {
        List<sObject> result = new List<sObject>();
        if(patch != null)
        {
            if(obj instanceOf Lead)
            {
                Lead ld = (Lead)obj;
                if(patch.CSM__c != null && patch.CSM__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.CSM__c, LeadAccessLevel='Edit'));
                }
                if(patch.ISR__c != null && patch.ISR__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.ISR__c, LeadAccessLevel='Edit'));
                }
                if(patch.Owner__c != null && patch.Owner__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.Owner__c, LeadAccessLevel='Edit'));
                }
                if(patch.RSM__c != null && patch.RSM__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.RSM__c, LeadAccessLevel='Edit'));
                }
                if(patch.SE__c != null && patch.SE__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.SE__c, LeadAccessLevel='Edit'));
                }
                if(patch.FCMM__c != null && patch.FCMM__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.FCMM__c, LeadAccessLevel='Edit'));
                }
                if(patch.Overlay_1__c != null && patch.Overlay_1__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.Overlay_1__c, LeadAccessLevel='Edit'));
                }
                if(patch.Overlay_2__c != null && patch.Overlay_2__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.Overlay_2__c, LeadAccessLevel='Edit'));
                }
            }
            else if(obj instanceOf Account)
            {
                Account acc = (Account)obj;
                if(patch.CSM__c != null)
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.CSM__c, TeamMemberRole='Channel Manager'));
                }
                if(patch.ISR__c != null)
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.ISR__c, TeamMemberRole='Inside Sale Representative'));
                }
                if(patch.RSM__c != null)
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.RSM__c, TeamMemberRole='Account Manager'));
                }
                if(patch.SE__c != null)
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.SE__c, TeamMemberRole='Systems Engineer'));
                }
                if(patch.Owner__c != null && !IsPartOfCoreTeam(patch,patch.Owner__c))
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.Owner__c, TeamMemberRole='Team Owner'));
                }
                if(patch.Overlay_1__c != null && patch.Overlay__c == true && !IsPartOfCoreTeam(patch,patch.Overlay_1__c))
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.Overlay_1__c, TeamMemberRole='Team Member'));
                }
                if(patch.Overlay_2__c != null && patch.Overlay__c == true && !IsPartOfCoreTeam(patch,patch.Overlay_2__c))
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.Overlay_2__c, TeamMemberRole='Team Member'));
                }
                if(patch.FCMM__c != null)
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.FCMM__c, TeamMemberRole='Field and Channel Marketing Manager'));
                }
                if(patch.RSS__c != null)
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.RSS__c, TeamMemberRole='Renewal Specialist'));
                }
            }
            else if(obj instanceOf Opportunity)
            {
                Opportunity opp = (Opportunity)obj;
                if(patch.CSM__c != null)
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.CSM__c, IsAddedByPatch__c=True, TeamMemberRole='Channel Manager'));
                }
                if(patch.ISR__c != null)
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.ISR__c, IsAddedByPatch__c=True, TeamMemberRole='Inside Sale Representative'));
                }
                if(patch.RSM__c != null)
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.RSM__c, IsAddedByPatch__c=True, TeamMemberRole='Account Manager'));
                }
                if(patch.SE__c != null)
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.SE__c, IsAddedByPatch__c=True, TeamMemberRole='Systems Engineer'));
                }
                if(patch.FCMM__c != null && !IsPartOfCoreTeam(patch,patch.FCMM__c))
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.FCMM__c, IsAddedByPatch__c=True, TeamMemberRole='Field and Channel Marketing Manager'));
                }
                if(patch.Owner__c != null && !IsPartOfCoreTeam(patch,patch.Owner__c))
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.Owner__c, IsAddedByPatch__c=True, TeamMemberRole='Team Owner'));
                }
                if(patch.Overlay_1__c != null && !IsPartOfCoreTeam(patch,patch.Overlay_1__c))
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.Overlay_1__c, IsAddedByPatch__c=True, TeamMemberRole='Team Member'));
                }
                if(patch.Overlay_2__c != null && !IsPartOfCoreTeam(patch,patch.Overlay_2__c))
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.Overlay_2__c, IsAddedByPatch__c=True, TeamMemberRole='Team Member'));
                }
                if(patch.SE__c != null && opp.Technical_Responsible__c!= null && patch.SE__c != opp.Technical_Responsible__c)
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=opp.Technical_Responsible__c, IsAddedByPatch__c=True, TeamMemberRole='Systems Engineer'));
                }
                if(patch.RSS__c != null)
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.RSS__c, IsAddedByPatch__c=True, TeamMemberRole='Renewal Specialist'));
                }
            }
        }
        return result;
    }

    @testvisible
    private static List<sObject> getPatchSharingBySalesTeams(sObject obj, Patch__c patch, List<SalesTeamMember__c> members)
    {
        List<sObject> result = new List<sObject>();
        if(patch != null)
        {
            if(obj instanceOf Lead)
            {
                Lead ld = (Lead)obj;
                for(SalesTeamMember__c member : members)
                {
                    if(member.User__c != ld.OwnerId)
                    {
                        result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=member.User__c, LeadAccessLevel='Edit'));
                    }
                }

                if(patch.Overlay_1__c != null && patch.Overlay_1__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.Overlay_1__c, LeadAccessLevel='Edit'));
                }
                if(patch.Overlay_2__c != null && patch.Overlay_2__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.Overlay_2__c, LeadAccessLevel='Edit'));
                }
            }
            else if(obj instanceOf Account)
            {
                Account acc = (Account)obj;
                for(SalesTeamMember__c member : members)
                {
                    if(member.Role__c == Label.SalesTeamMemberRole_CAM)
                    {
                        result.add(new AccountTeamMember(AccountId=acc.Id, UserId=member.User__c, TeamMemberRole='Channel Manager'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_ISR)
                    {
                        result.add(new AccountTeamMember(AccountId=acc.Id, UserId=member.User__c, TeamMemberRole='Inside Sale Representative'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_RSM)
                    {
                        result.add(new AccountTeamMember(AccountId=acc.Id, UserId=member.User__c, TeamMemberRole='Account Manager'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_SE)
                    {
                        result.add(new AccountTeamMember(AccountId=acc.Id, UserId=member.User__c, TeamMemberRole='Systems Engineer'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_FCMM)
                    {
                        result.add(new AccountTeamMember(AccountId=acc.Id, UserId=member.User__c, TeamMemberRole='Field and Channel Marketing Manager'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_RSS)
                    {
                        result.add(new AccountTeamMember(AccountId=acc.Id, UserId=member.User__c, TeamMemberRole='Renewal Specialist'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_SEM)
                    {
                        result.add(new AccountTeamMember(AccountId=acc.Id, UserId=member.User__c, TeamMemberRole='SEM'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_TeamOwner && !IsPartOfCoreSalesTeam(member.User__c, members))
                    {
                        result.add(new AccountTeamMember(AccountId=acc.Id, UserId=member.User__c, TeamMemberRole='Team Owner'));
                    }
                }

                if(patch.Overlay_1__c != null && patch.Overlay__c == true && !IsPartOfCoreSalesTeam(patch.Overlay_1__c, members))
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.Overlay_1__c, TeamMemberRole='Team Member'));
                }
                if(patch.Overlay_2__c != null && patch.Overlay__c == true && !IsPartOfCoreSalesTeam(patch.Overlay_2__c, members))
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.Overlay_2__c, TeamMemberRole='Team Member'));
                }
            }
            else if(obj instanceOf Opportunity)
            {
                Opportunity opp = (Opportunity)obj;
                for(SalesTeamMember__c member : members)
                {
                    if(member.Role__c == Label.SalesTeamMemberRole_CAM)
                    {
                        result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=member.User__c, TeamMemberRole='Channel Manager'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_ISR)
                    {
                        result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=member.User__c, TeamMemberRole='Inside Sale Representative'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_RSM)
                    {
                        result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=member.User__c, TeamMemberRole='Account Manager'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_SE)
                    {
                        result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=member.User__c, TeamMemberRole='Systems Engineer'));
                        if(opp.Technical_Responsible__c!= null && member.User__c != opp.Technical_Responsible__c)
                        {
                           result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=opp.Technical_Responsible__c, TeamMemberRole='Systems Engineer')); 
                        }
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_RSS)
                    {
                        result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=member.User__c, TeamMemberRole='Renewal Specialist'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_SEM)
                    {
                        result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=member.User__c, TeamMemberRole='SEM'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_FCMM && !IsPartOfCoreSalesTeam(member.User__c, members))
                    {
                        result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=member.User__c, TeamMemberRole='Field and Channel Marketing Manager'));
                    }
                    else if(member.Role__c == Label.SalesTeamMemberRole_TeamOwner && !IsPartOfCoreSalesTeam(member.User__c, members))
                    {
                        result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=member.User__c, TeamMemberRole='Team Owner'));
                    }
                }

                if(patch.Overlay_1__c != null && !IsPartOfCoreSalesTeam(patch.Overlay_1__c, members))
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.Overlay_1__c, TeamMemberRole='Team Member'));
                }
                if(patch.Overlay_2__c != null && !IsPartOfCoreSalesTeam(patch.Overlay_2__c, members))
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.Overlay_2__c, TeamMemberRole='Team Member'));
                }
            }
        }
        return result;
    }
    
    private static void EditAccessToOppTeam(Set<Id> setOppIds, Set<Id> setUserIds)
    { 
        List<OpportunityShare> listShares = [Select Id,OpportunityAccessLevel,Rowcause from OpportunityShare where OpportunityId  IN :setOppIds and UserOrGroupId IN : setUserIds and rowcause ='Team'];
        
        if(listShares != null && listShares.size()>0 ){
            for (OpportunityShare share : listShares)  {
                share.OpportunityAccessLevel = 'Edit';
            }
            update listShares;
        }
    }
    
    private static boolean IsPartOfCoreTeam(Patch__c patch,Id userId)
    {
        if(userId== patch.RSM__c)
        {return true;}
        if(userId== patch.CSM__c)
        {return true;}
        if(userId== patch.ISR__c)
        {return true;}
        if(userId== patch.SE__c)
        {return true;}
        return false;
    }
    private static boolean IsPartOfCoreSalesTeam(Id userId, List<SalesTeamMember__c> members)
    {
        for(SalesTeamMember__c member : members)
        {
            if(member.Role__c == Label.SalesTeamMemberRole_RSM && member.User__c == UserId)
            {
                return true;
            }
            if(member.Role__c == Label.SalesTeamMemberRole_CAM && member.User__c == UserId)
            {
                return true;
            }
            if(member.Role__c == Label.SalesTeamMemberRole_ISR && member.User__c == UserId)
            {
                return true;
            }
            if(member.Role__c == Label.SalesTeamMemberRole_SE && member.User__c == UserId)
            {
                return true;
            }
        }
        return false;
    }
}