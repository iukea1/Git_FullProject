@isTest
public class PatchRuleHelperTest
{
    @isTest
    static void testLead()
    {
        Lead ld = new Lead(LastName='acme', Company='acme', LeadSource='Deal Registration');
        insert ld;
        Patch__c patch = new Patch__c(Type__c='Named Accounts', CSM__c=UserInfo.getUserId(), ISR__c=UserInfo.getUserId(), Owner__c=UserInfo.getUserId(), RSM__c=UserInfo.getUserId(), SE__c=UserInfo.getUserId());
        insert patch;
        Patch__c patch2 = new Patch__c(Type__c='GEO');
        insert patch2;
        
        PatchRuleHelper.assignPatch(new List<Id> {ld.Id});
        PatchRuleHelper.assignPatch(ld, null);
        PatchRuleHelper.assignPatch(ld, patch, patch2.Id);
        PatchRuleHelper.getPatchSharing(ld, patch);
    }
    @isTest
    static void testLeadIsSalesTeam()
    {
        Lead ld = new Lead(LastName='acme', Company='acme');
        insert ld;
        Patch__c patch = new Patch__c(Patch_Name__c='acme', IsSalesTeam__c=true, Active__c=true, RSM__c=UserInfo.getUserId(), ProcessingSequence__c=1);
        insert patch;
        SalesTeam__c salesTeam = new SalesTeam__c(Patch__c=patch.Id, type__c='Enterprise');
        insert salesTeam;
        SalesTeamMember__c member1 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='CSM', SalesTeam__c=salesTeam.Id);
        insert member1;
        SalesTeamMember__c member2 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='ISR', SalesTeam__c=salesTeam.Id);
        insert member2;
        SalesTeamMember__c member3 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='SE', SalesTeam__c=salesTeam.Id);
        insert member3;
        SalesTeamMember__c member4 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='RSS', SalesTeam__c=salesTeam.Id);
        insert member4;
        SalesTeamMember__c member5 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='FCMM', SalesTeam__c=salesTeam.Id);
        insert member5;
        SalesTeamMember__c member6 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='SEM', SalesTeam__c=salesTeam.Id);
        insert member6;
        SalesTeamMember__c member7 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='RSM', SalesTeam__c=salesTeam.Id);
        insert member7;
        Patch__c patch2 = new Patch__c(Type__c='GEO');
        insert patch2;

        List<SalesTeamMember__c> members = new List<SalesTeamMember__c>{member1,member2,member3,member4,member5,member6,member7};
        Map<String, List<SalesTeamMember__c>> type2members = new Map<String, List<SalesTeamMember__c>>();
        type2members.put('Enterprise', members);
        PatchRuleHelper.assignPatchBySalesTeams(ld, patch, patch2.Id, type2members);
        PatchRuleHelper.getPatchSharingbySalesTeams(ld, patch, members);
    }
    
    
    @isTest
    static void testAccount()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Patch__c patch = new Patch__c(Type__c='Named Accounts', CSM__c=UserInfo.getUserId(), ISR__c=UserInfo.getUserId(), Owner__c=UserInfo.getUserId(), RSM__c=UserInfo.getUserId(), SE__c=UserInfo.getUserId());
        insert patch;
        Patch__c patch2 = new Patch__c(Type__c='GEO');
        insert patch2;
        
        PatchRuleHelper.assignPatch(new List<Id> {acc.Id});
        PatchRuleHelper.assignPatch(acc, null);
        PatchRuleHelper.assignPatch(acc, patch, patch2.Id);
        PatchRuleHelper.assignTeamMembers(new List<Id> {acc.Id});
        PatchRuleHelper.getPatchSharing(acc, patch);
    }
    @isTest
    static void testAccountIsSalesTeam()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Patch__c patch = new Patch__c(Patch_Name__c='acme', IsSalesTeam__c=true, Active__c=true, RSM__c=UserInfo.getUserId(), ProcessingSequence__c=1);
        insert patch;
        SalesTeam__c salesTeam = new SalesTeam__c(Patch__c=patch.Id, type__c='Enterprise');
        insert salesTeam;
        SalesTeamMember__c member1 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='CSM', SalesTeam__c=salesTeam.Id);
        insert member1;
        SalesTeamMember__c member2 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='ISR', SalesTeam__c=salesTeam.Id);
        insert member2;
        SalesTeamMember__c member3 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='SE', SalesTeam__c=salesTeam.Id);
        insert member3;
        SalesTeamMember__c member4 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='RSS', SalesTeam__c=salesTeam.Id);
        insert member4;
        SalesTeamMember__c member5 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='FCMM', SalesTeam__c=salesTeam.Id);
        insert member5;
        SalesTeamMember__c member6 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='SEM', SalesTeam__c=salesTeam.Id);
        insert member6;
        SalesTeamMember__c member7 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='RSM', SalesTeam__c=salesTeam.Id);
        insert member7;
        Patch__c patch2 = new Patch__c(Type__c='GEO');
        insert patch2;
        
        List<SalesTeamMember__c> members = new List<SalesTeamMember__c>{member1,member2,member3,member4,member5,member6,member7};
        Map<String, List<SalesTeamMember__c>> type2members = new Map<String, List<SalesTeamMember__c>>();
        type2members.put('Enterprise', members);
        PatchRuleHelper.assignPatchBySalesTeams(acc, patch, patch2.Id, type2members);
        PatchRuleHelper.getPatchSharingbySalesTeams(acc, patch, members);
    }
    
    @isTest
    static void testOpportunityIsSalesTeam()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Opportunity opp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Discovery', AccountId=acc.Id);
        insert opp;
        Patch__c patch = new Patch__c(Patch_Name__c='acme', IsSalesTeam__c=true, Active__c=true, RSM__c=UserInfo.getUserId(), ProcessingSequence__c=1);
        insert patch;
        SalesTeam__c salesTeam = new SalesTeam__c(Patch__c=patch.Id, type__c='Enterprise');
        insert salesTeam;
        SalesTeamMember__c member1 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='CSM', SalesTeam__c=salesTeam.Id);
        insert member1;
        SalesTeamMember__c member2 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='ISR', SalesTeam__c=salesTeam.Id);
        insert member2;
        SalesTeamMember__c member3 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='SE', SalesTeam__c=salesTeam.Id);
        insert member3;
        SalesTeamMember__c member4 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='RSS', SalesTeam__c=salesTeam.Id);
        insert member4;
        SalesTeamMember__c member5 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='SEM', SalesTeam__c=salesTeam.Id);
        insert member5;
        SalesTeamMember__c member6 = new SalesTeamMember__c(User__c =UserInfo.getUserId(), Role__c='RSM', SalesTeam__c=salesTeam.Id);
        insert member6;
        Patch__c patch2 = new Patch__c(Type__c='GEO');
        insert patch2;
        
        List<SalesTeamMember__c> members = new List<SalesTeamMember__c>{member1,member2,member3,member4,member5,member6};
        Map<String, List<SalesTeamMember__c>> type2members = new Map<String, List<SalesTeamMember__c>>();
        type2members.put('Enterprise', members);
        PatchRuleHelper.assignPatchBySalesTeams(opp, patch, patch2.Id, type2members);
        PatchRuleHelper.getPatchSharingbySalesTeams(opp, patch, members);
    }
    
    @isTest
    static void testOpportunity()
    {
        Patch__c patch = new Patch__c(Type__c='Named Accounts', CSM__c=UserInfo.getUserId(), ISR__c=UserInfo.getUserId(), Owner__c=UserInfo.getUserId(), RSM__c=UserInfo.getUserId(), SE__c=UserInfo.getUserId());
        insert patch;
        Patch__c patch2 = new Patch__c(Type__c='GEO');
        insert patch2;
        Account acc = new Account(Name='acme');
        insert acc;
        Opportunity opp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Discovery', AccountId=acc.Id);
        insert opp;
        
        PatchRuleHelper.assignPatch(new List<Id> {opp.Id});
        PatchRuleHelper.assignPatch(opp, null);
        PatchRuleHelper.assignPatch(opp, patch, patch2.Id);
        PatchRuleHelper.assignTeamMembers(new List<Id> {opp.Id});
        PatchRuleHelper.getPatchSharing(opp, patch);
    }
    
    @isTest static void testSplitCsv()
    {
        String[] s1 = PatchRuleHelper.splitCsv('us, usa, america, united states of america');
        System.assertEquals(4, s1.size());
        System.assertEquals('us', s1[0]);
        System.assertEquals('usa', s1[1]);
        System.assertEquals('america', s1[2]);
        System.assertEquals('united states of america', s1[3]);
        
        String[] s2 = PatchRuleHelper.splitCsv('taiwan, tw, "taiwan, province of china,"');
        System.assertEquals(3, s2.size());
        System.assertEquals('taiwan', s2[0]);
        System.assertEquals('tw', s2[1]);
        System.assertEquals('taiwan, province of china,', s2[2]);
    }
    
    @isTest static void testRefreshPatchTimestamp()
    {
        Patch__c patch = new Patch__c(Type__c='Named Accounts');
        insert patch;
        
        PatchRuleHelper.refreshPatchTimestamp(new Set<Id> {patch.Id});
        Long timestamp = PatchRuleHelper.LastDeploymentDate;
    }
}