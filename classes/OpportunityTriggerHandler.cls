public class OpportunityTriggerHandler implements ITriggerHandler {
    Id MasterRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('All_Master').getRecordTypeId();
    List<Opportunity> listOpps = new List<Opportunity>();
    List<OpportunityRecordTypeTransition__c> listCSDataset = OpportunityRecordTypeTransition__c.getall().values(); 
    String productValue; 
    Map<Id,Id> mapOppTR = null;
    public OpportunityTriggerHandler()
    {
        
    }
    
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for(Opportunity newOpp:(List<Opportunity>)newItems)
            {
                if(!SilverPeakUtils.BypassingTriggers)
                {
                    if(newOpp.LeadSource==null)
                    {
                        newOpp.LeadSource=newOpp.Opportunity_Source__c;
                    }
                }
                System.debug('newOpp.CloseDate'+newOpp.CloseDate);
                newOpp.Fiscal_Quarter_Name__c=RetrieveQuarterName(newOpp.CloseDate);
                listOpps.add(newOpp);
            }
            populateOpportunityRecordTypes(listOpps);
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        Set<Id> notAllowClosedStageOpps= new Set<Id>();
        Schema.Describefieldresult F = Opportunity.LeadSource.getDescribe();
        List<Schema.Picklistentry> P = F.getPicklistValues();
        Set<String> options = new Set<String>();
        for(Schema.Picklistentry ple : P)
        {
            options.add(ple.getValue());
        }
        if(newItems!=null && newItems.size()>0)
        {
            List<Asset> lstAssets=[Select Id,POCRequest__r.Opportunity__c from Asset where Product2.Family='Product' and POCRequest__c  in (Select Id from Request__c where Opportunity__c in :newItems.keyset())];
            notAllowClosedStageOpps=CheckIfAssetsCreatedForClosedOpp(lstAssets);
            for (Id oppId : newItems.keyset())
            {
                Opportunity newOpp=(Opportunity)newItems.get(oppId);
                Opportunity oldOpp=(Opportunity)oldItems.get(oppId);
                
                if(newOpp.CloseDate!=oldOpp.CloseDate)
                {
                    newOpp.Fiscal_Quarter_Name__c= RetrieveQuarterName(newOpp.CloseDate);
                }
                
                if(!SilverPeakUtils.BypassingTriggers)
                {
                    if(newOpp.Opportunity_Source__c!=oldOpp.Opportunity_Source__c)
                    {
                        if(!options.contains(newOpp.LeadSource))
                        {
                            newOpp.LeadSource=newOpp.Opportunity_Source__c;
                        }
                    }
                }
                
                if(!newOpp.IsClosed)
                {
                    if(oldOpp.Has_Active_POCs__c != newOpp.Has_Active_POCs__c)
                    {
                        if(newOpp.Has_Active_POCs__c)
                        {
                            newOpp.POC_Start_Date__c = Date.today();
                            newOpp.POC_End_Date__c   = Date.today();
                            newOpp.POC_Duration__c   = oldOpp.POC_Age__c;
                        }
                        else
                        {
                            newOpp.POC_End_Date__c   = Date.today();
                        }
                    }
                }
                else if(newOpp.IsClosed && !oldOpp.IsClosed)
                {
                    if(newOpp.StageName=='Closed Dead'|| newOpp.StageName=='Closed Lost' || newOpp.StageName=='Closed Deleted') 
                    {
                        if(notAllowClosedStageOpps!=null && notAllowClosedStageOpps.size()>0 && notAllowClosedStageOpps.contains(newOpp.Id))
                        {
                            newOpp.addError('This selected stage cannot be updated as it has active physical assets.');
                        }
                    }
                    if(newOpp.Has_Active_POCs__c)
                    {
                        newOpp.POC_End_Date__c = Date.today();
                    } 
                }
                if(oldOpp.Deal_Type__c != newOpp.Deal_Type__c || oldOpp.Type != newOpp.Type || oldOpp.StageName != newOpp.StageName || oldOpp.Product_Type__c != newOpp.Product_Type__c)
                {
                    listOpps.add(newOpp);
                } 
            }
            populateOpportunityRecordTypes(listOpps);
            
            sendEmailAlertForSplitUpdate(newItems, oldItems);

            deleteOppSplits(newItems, oldItems);

        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        if(oldItems.size()>0)
        {
            User currentUser = [select Id, Profile.PermissionsModifyAllData, Profile.PermissionsCustomizeApplication from User where Id=:UserInfo.getUserId() limit 1];
            Boolean isAdmin = currentUser.Profile.PermissionsModifyAllData && currentUser.Profile.PermissionsCustomizeApplication;
            for(Id oppId:oldItems.keySet())
            {
                Opportunity opp=(Opportunity)oldItems.get(oppId);
                if(!isAdmin)
                {
                    opp.addError('You are not allowed to delete opportunities.');
                }
            }
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        List<Id> lstOpps= new List<Id>();
        List<OpportunityContactRole>lstContactRole= new List<OpportunityContactRole>();
        Set<Id> oppNeedsPatchAssign = new Set<Id>();
        Set<Id> oppNeedsTeamAssign = new Set<Id>();
        List<Opportunity> oppsNeedSharing = new List<Opportunity>();
        List<Id> oppIdsNeedSharing = new List<Id>();
        mapOppTR= new Map<Id,Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id oppId : newItems.keyset())
            {
                Opportunity newOpp=(Opportunity)newItems.get(oppId);
                if(newOpp.CampaignId == SalesDevelopmentHelper.getSDcampaign())
                {
                    lstOpps.add(oppId);
                }
                if(newOpp.Type != 'Marketplace')
                {
                    if(newOpp.Patch__c == null)
                    {
                        oppNeedsPatchAssign.add(newOpp.Id);
                    }
                    else
                    {
                        oppNeedsTeamAssign.add(newOpp.Id);
                    }
                }
                if(newOpp.Registered_Distributor_Contact__c!=null || newOpp.Registering_Partner_Sales_Rep__c!=null || newOpp.Registered_Distributor__c!=null || newOpp.Registering_Partner__c!=null)
                {
                    oppsNeedSharing.add(newOpp);
                    oppIdsNeedSharing.add(newOpp.Id);
                }
                if(newOpp.Technical_Responsible__c !=null)
                {
                    mapOppTR.put(newOpp.Id,newOpp.Technical_Responsible__c);
                }
            }
            ShareOppToRegisteredPartner(oppsNeedSharing,oppIdsNeedSharing);
            LinkOpportunityToPatch(oppNeedsPatchAssign, oppNeedsTeamAssign);
            ResetPrimaryCampaignSource(lstOpps);
            AddTRToOpportunityTeam(mapOppTR);
            //SetContactRole(newItems.keyset());
            
            createOppSplits(newItems, null);
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {     
        Set<Id> wanStartOpps= new Set<Id>();
        Set<Id> setAccIds= new Set<Id>();
        Set<Id> oppNeedsPatchAssign = new Set<Id>();
        Set<Id> oppNeedsTeamAssign = new Set<Id>();
        List<Opportunity> oppsNeedSharing = new List<Opportunity>();
        List<Id> oppIdsNeedSharing = new List<Id>();
        mapOppTR= new Map<Id,Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id oppId : newItems.keyset())
            {
                Opportunity newOpp=(Opportunity)newItems.get(oppId);
                Opportunity oldOpp=(Opportunity)oldItems.get(oppId);
                if(!SilverPeakUtils.BypassingTriggers)
                {  
                    if(newOpp.WANstartCaseCreated__c==null)
                    {
                        newOpp.WANstartCaseCreated__c=false;
                    }
                    if (newOpp.IsWon && newOpp.WANstart_count__c > 0 && newOpp.WANstartCaseCreated__c == false)
                    {
                        if(newOpp.IsWon != oldOpp.IsWon || newOpp.WANstart_count__c != oldOpp.WANstart_count__c || newOpp.WANstartCaseCreated__c != oldOpp.WANstartCaseCreated__c)
                            wanStartOpps.add(newOpp.Id);
                    }
                    
                }
                if(newOpp.Type != 'Marketplace' && newOpp.IsClosed == false)
                {
                    Boolean isSegmentChanged = oldOpp.SegmentationType__c != newOpp.SegmentationType__c && newOpp.IsSalesTeamPatch__c;
                    if(newOpp.Patch_Locked__c == false)
                    {
                        if(newOpp.Trigger_Assignment__c || newOpp.AccountId != oldOpp.AccountId || isSegmentChanged)
                        {
                            oppNeedsPatchAssign.add(newOpp.Id);
                            oppNeedsTeamAssign.add(newOpp.Id);
                            continue;
                        }
                    }
                    if(newOpp.Patch__c != oldOpp.Patch__c || newOpp.Trigger_Assignment__c || newOpp.OwnerId != oldOpp.OwnerId)
                    {
                        oppNeedsTeamAssign.add(newOpp.Id);
                    }
                }
                if(newOpp.StageName!=oldOpp.StageName)
                {
                    if(newOpp.AccountId!=null)
                    {
                        setAccIds.add(newOpp.AccountId);
                    }
                }
               // if(newOpp.LeadSource=='Deal Registration')
               // {
                    if(isChanged(oldOpp, newOpp, new String[] { 'LeadSource', 'OwnerId', 'Registered_Distributor_Contact__c', 'Registering_Partner_Sales_Rep__c', 'Registered_Distributor__c', 'Registering_Partner__c'}))
                    {
                        oppsNeedSharing.add(newOpp);
                        oppIdsNeedSharing.add(newOpp.Id);
                    }
               // }
                if(newOpp.Technical_Responsible__c !=null && newOpp.Technical_Responsible__c != oldOpp.Technical_Responsible__c)
                {
                    mapOppTR.put(newOpp.Id,newOpp.Technical_Responsible__c);
                }
            }
            ShareOppToRegisteredPartner(oppsNeedSharing,oppIdsNeedSharing);
            LinkOpportunityToPatch(oppNeedsPatchAssign, oppNeedsTeamAssign);
            CalculateFirstCustomerDate(setAccIds);
            //SetContactRole(newItems.keyset());
            CreateWANStartCase(wanStartOpps);
            //SycnOpportunityToQuoteHandler.sycnOpportunityDateToQuoteDateOnUpdate((Map<Id,Opportunity>)oldItems,(Map<Id,Opportunity>)newItems);
            UpdateFirstOpportunityWinCheckBox(setAccIds);
            AddTRToOpportunityTeam(mapOppTR);
            
            createOppSplits(newItems, oldItems);
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        if(oldItems!=null && oldItems.size()>0)
        {
            for (Id oppId : oldItems.keyset())
            {
                Opportunity oldOpp=(Opportunity)oldItems.get(oppId);
            }
            if(!SilverPeakUtils.BypassingTriggers)
            {
                OpportunityMergeController.removeOrphanedPOC();
            }  
            
        }
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id oppId : newItems.keyset())
            {
                Opportunity newOpp=(Opportunity)newItems.get(oppId);
            }
        }
    }
    //checks if the fields are changed in the sObjects
    private Boolean isChanged(sObject oldObj, sObject newObj, String[] fields)
    {
        for(String field : fields)
        {
            Object oldValue = oldObj.get(field);
            Object newValue = newObj.get(field);
            if(oldValue != newValue)
            {
                return true;
            }
        }
        return false;
    }
    private void ShareOppToRegisteredPartner(List<Opportunity> opps, List<Id> oppIds)
    {
        if(opps.size() > 0)
        {
            
            ShareLeadAndOpportunityToPartnerHelper.willShareOpportunities(oppIds);
            
        }
    }
    
    
    private void CalculateFirstCustomerDate(Set<Id> acctIds)
    {
        List<Account> lstAccToUpdate= new List<Account>();  
        if(acctIds!=null && acctIds.size()>0)
        {
            List<Account> lstAccounts =[Select Id,First_Asset_Quarter__c,Is_Partner_Initiated_Account__c ,(Select Id, CloseDate,Deal_Reg__c,First_Win_Opportunity__c from Opportunities where StageName='Closed Won' order by CloseDate asc) from Account where Id in:acctIds ];
            
            for(Account item: lstAccounts)
            {
                System.debug('AcctIds');
                Date minDate=null;
                boolean partnerInitated;
                List<Opportunity> lstCurrOpp=item.Opportunities;
                if(lstCurrOpp!=null && lstCurrOpp.size()>0)
                {
                    minDate= lstCurrOpp[0].CloseDate;
                    partnerInitated=lstCurrOpp[0].Deal_Reg__c;
                    string currentFiscalQuarter =RetrieveQuarterName(minDate);
                    if(item.First_Asset_Quarter__c!=currentFiscalQuarter || item.Is_Partner_Initiated_Account__c!=partnerInitated)
                    {
                        lstAccToUpdate.add(new Account(Id=item.Id,First_Asset_Quarter__c=currentFiscalQuarter,Is_Partner_Initiated_Account__c=partnerInitated));
                    }
                    
                }
                else
                {
                    lstAccToUpdate.add(new Account(Id=item.Id,First_Asset_Quarter__c='',Is_Partner_Initiated_Account__c=false));
                }
            }
            
            if(lstAccToUpdate.size()>0)
            {
                update lstAccToUpdate;
            }
            
        }
    }
    
    private void UpdateFirstOpportunityWinCheckBox(Set<Id> acctIds)
    {
        List<Opportunity> lstOppToUpdate= new List<Opportunity>();
        if(acctIds!=null && acctIds.size()>0)
        {
            
            List<Account> lstAccounts =[Select Id,(Select Id,Name, StageName,CloseDate,Deal_Reg__c,First_Win_Opportunity__c from Opportunities  order by CloseDate asc, LastModifiedDate asc) from Account where Id in:acctIds ];
            for(Account item: lstAccounts)
            {
                System.debug(item.Id);
                boolean firstOpp=false;
                List<Opportunity> lstCurrOpps=item.Opportunities;
                System.debug('lstCurrOpps '+ lstCurrOpps.size());
                if(lstCurrOpps!=null && lstCurrOpps.size()>0)
                {
                    for(integer counter=0; counter<lstCurrOpps.size(); counter++)
                    {
                        Opportunity currOpp=lstCurrOpps[counter];
                        if(currOpp.StageName=='Closed Won' && !firstOpp)
                        {
                            firstOpp=true;
                            if(!currOpp.First_Win_Opportunity__c)
                            {
                                currOpp.First_Win_Opportunity__c=true;
                                lstOppToUpdate.add(currOpp);
                            }
                            
                        }
                        else
                        {
                            if(currOpp.First_Win_Opportunity__c)
                            {
                                currOpp.First_Win_Opportunity__c=false;
                                lstOppToUpdate.add(currOpp);
                            }
                            
                        }
                        
                    }
                }
                
            }
            if(lstOppToUpdate.size()>0)
            {
                update lstOppToUpdate;
            }
            
            
        }
        
    }
    
    private  string RetrieveQuarterName(Date closeDate)
    {
        List<Period> lstPeriod =[Select Type, StartDate, EndDate, QuarterLabel, PeriodLabel, Number, FiscalYearSettings.Name From Period  where Type ='Quarter' order by StartDate];
        if(lstPeriod!=null && lstPeriod.size()>0)
        {
            for(Period item: lstPeriod)
            {
                if(item.StartDate<=closeDate && closeDate<=item.EndDate)
                {
                    return item.FiscalYearSettings.Name + 'Q' + item.Number;
                }
            }
        }
        return null;
    }
    
    private void LinkOpportunityToPatch(Set<Id> setPatchAssign, Set<Id> setTeamAssign)
    {
        if(setPatchAssign.size() > 0)
        {
            if(System.isFuture() || System.isBatch())
            {
                PatchRuleHelper.assignPatch(new List<Id>(setPatchAssign));
            }
            else
            {
                PatchRuleHelper.willAssignPatch(new List<Id>(setPatchAssign));
                List<Opportunity> opps = new List<Opportunity>();
                for(Id oppId : setPatchAssign)
                {
                    opps.add(new Opportunity(Id=oppId, Trigger_Assignment__c=false, Bypassing_Validation__c=true));
                }
                update opps;
            }
        }
        if(setTeamAssign.size() > 0)
        {
            PatchRuleHelper.assignTeamMembers(new List<Id>(setTeamAssign));
        }
    }
    /* private void SetContactRole(Set<Id> oppIds)
{
List<OpportunityContactRole>lstContactRole= new List<OpportunityContactRole>();
List<OpportunityContactRole> oppCR = [select id, role from OpportunityContactRole where 
opportunityid in :oppIds AND role= null];

if(oppCR.size() > 0)
{
for(OpportunityContactRole item: oppCR)
{
item.Role = 'Contact';
lstContactRole.add(item);
}

}
if(lstContactRole.size()>0)
{
update lstContactRole;
}
}*/
    private Set<Id> CheckIfAssetsCreatedForClosedOpp(List<Asset> lstAssets)
    {
        Set<Id> setOppIds= new Set<Id>();
        if(lstAssets!=null && lstAssets.size()>0)
        {
            for(Asset asset: lstAssets)
            {
                setOppIds.add(asset.POCRequest__r.Opportunity__c);
            }
        }
        return setOppIds;
    }
    private void ResetPrimaryCampaignSource(List<Id> setOpps)
    {
        if(setOpps.size() > 0)
        {
            if(System.isFuture())
            {
                SalesDevelopmentHelper.ResetPrimaryCampaignSource(setOpps);
            }
            else
            {
                SalesDevelopmentHelper.willResetPrimaryCampaignSource(setOpps);
            }
        }
    }
    private void CreateWANStartCase(Set<Id> oppIds)
    {
        List<Case> cases = new List<Case>();
        Id TechSupportQueue = '00G30000000mEL4';
        if(oppIds!=null && oppIds.size()>0)
        {
            List<Opportunity> opps = new List<Opportunity>();
            for(Opportunity opp : [select Id, AccountId, Account.Name, Technical_Responsible__c, (select Id from OpportunityLineItems where PricebookEntry.ProductCode in('300019-002','300148-001')) from Opportunity where Id in :oppIds])
            {
                if (opp.AccountId != null)
                {
                    Case newCase = new Case(Subject='New WANstart for ' + opp.Account.Name, AccountId=opp.AccountId);
                    if(opp.Technical_Responsible__c != null)
                    {
                        newCase.OwnerId = opp.Technical_Responsible__c;
                    }
                    else
                    {
                        newCase.OwnerId = TechSupportQueue;
                    }
                    if(opp.OpportunityLineItems.size() > 0)
                    {
                        newCase.Type = 'WANstart Services';
                        newCase.Status = 'Staged';
                    }
                    else
                    {
                        newCase.Type = 'WANstart Bundled';
                        newCase.Status = 'Staged';
                    }
                    cases.add(newCase);
                    opps.add(new Opportunity(Id=opp.Id, WANstartCaseCreated__c=true));
                }
            }
            if(cases.size() > 0)
            {
                try
                {
                    insert cases;
                    update opps;
                }
                catch(Exception ex)
                {
                    Trigger.new[0].addError(ex.getMessage());
                }
            }
        }
    }
    
    private void populateOpportunityRecordTypes(List<Opportunity> listOppsRT)
    {
        for(Opportunity o: listOppsRT){
            if(o.Product_Type__c == null){
                productValue = o.Deal_Type__c;
            }
            else if(o.Product_Type__c != null){
                productValue = o.Product_Type__c;
            }
            if(productValue == null || o.Type == null || o.StageName == null)
            {
                o.RecordTypeId = MasterRT;
            }
            else
            {
                for(OpportunityRecordTypeTransition__c ort: listCSDataset){
                    o.RecordTypeId = MasterRT;
                    if(ort.Initial_Solution_Interest__c == productValue && ort.Type__c == o.Type && ort.Stage__c == o.StageName)
                    {
                        o.RecordTypeId = ort.Record_Type_Id__c;
                        break;
                    }
                }
            }
        }
    }
    
    private void AddTRToOpportunityTeam(Map<Id,Id> mapOppsTRValue)
    {
        if(mapOppsTRValue.size()>0){
            List<OpportunityTeamMember> listNewMembers = new List<OpportunityTeamMember>();
            Set<Id> setNewMembersIds = new Set<Id>();    
            List<Opportunity> listOppswithTeamMembers = [Select Id,Technical_Responsible__c, (Select Id,OpportunityId,OpportunityAccessLevel,TeamMemberRole,UserId from OpportunityTeamMembers where UserId IN:mapOppsTRValue.values() and TeamMemberRole='Systems Engineer')
                                                         from Opportunity where Id IN :mapOppsTRValue.keySet()];
            
            if(listOppswithTeamMembers != null && listOppswithTeamMembers.size()>0){
                for(Opportunity opp: listOppswithTeamMembers)
                {
                    if(opp.OpportunityTeamMembers != null && opp.OpportunityTeamMembers.size()==0)
                    {
                        OpportunityTeamMember newOTM = new OpportunityTeamMember();
                        newOTM.OpportunityId = opp.Id;
                        newOTM.UserId = opp.Technical_Responsible__c;
                        newOTM.TeamMemberRole = 'Systems Engineer';
                        listNewMembers.add(newOTM);
                        setNewMembersIds.add(opp.Technical_Responsible__c);
                    }
                    else
                    {
                        Boolean isMatchFound;
                        for(OpportunityTeamMember otm: opp.OpportunityTeamMembers)
                        {
                            if(opp.Technical_Responsible__c == otm.UserId)
                            {
                                isMatchFound = True;
                            }
                        }
                        if(!isMatchFound){
                            OpportunityTeamMember newOTM = new OpportunityTeamMember();
                            newOTM.OpportunityId = opp.Id;
                            newOTM.UserId = opp.Technical_Responsible__c;
                            newOTM.TeamMemberRole = 'Systems Engineer';
                            listNewMembers.add(newOTM);
                            setNewMembersIds.add(opp.Technical_Responsible__c);
                            
                        }
                    }
                }
                
                if(listNewMembers != null && listNewMembers.size()>0)
                {
                    insert listNewMembers; 
                }
                
                List<OpportunityShare> listShares = [Select Id,OpportunityAccessLevel,Rowcause from OpportunityShare where UserOrGroupId IN :setNewMembersIds and OpportunityId IN :mapOppsTRValue.keySet() and RowCause = 'Team'];
                if(listShares!= null && listShares.size()>0){
                    for (OpportunityShare share : listShares)  {
                        share.OpportunityAccessLevel = 'Edit';
                    }
                    update listShares;      
                }
            }
        }
    }
    
    private void sendEmailAlertForSplitUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {
        Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>();
        Opportunity newOpp, oldOpp;
        for(Id oppId : newItems.keyset())
        {
            newOpp = (Opportunity)newItems.get(oppId);
            oldOpp = (Opportunity)oldItems.get(oppId);

            // only when the Opportunity Owner is changed, and use the static variable to avoid recurring trigger
            if(isFieldValueChanged(newOpp.OwnerId, oldOpp.OwnerId, OpportunityTriggerController.oppOwnerInAfterUpdate))
            {
                oldOppMap.put(oppId, oldOpp);
            }
        }

        if(!oldOppMap.isEmpty())
        {
            Set<Id> oppIds = new Set<Id>();
            for(OpportunitySplit split : [select Id, OpportunityId, SplitOwnerId from OpportunitySplit 
                                          where OpportunityId in :oldOppMap.keySet() and SplitType.IsActive = true
                                          order by OpportunityId, SplitOwnerId])
            {
                oldOpp = oldOppMap.get(split.OpportunityId);                
                if(split.SplitOwnerId != oldOpp.OwnerId && split.SplitOwnerId != oldOpp.Technical_Responsible__c)
                {
                    oppIds.add(split.OpportunityId);
                }
            }

            if(!oppIds.isEmpty())
            {
                sendEmailMessage(oppIds);
            }
        }
    }

    private void sendEmailMessage(Set<Id> oppIds)
    {
        Id templateId = [select Id from EmailTemplate where DeveloperName = 'Opportunity_Split_Update_Notification'].Id;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Id oppId : oppIds)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setTemplateId(templateId);
            mail.setWhatId(oppId);
            mail.setToAddresses(new String[] {'rmarqueling@silver-peak.com'});
            mail.setTreatTargetObjectAsRecipient(false);
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }

    // Add by SNAP
    private  void createOppSplits(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {
        List<OpportunitySplitType> splitTypes = [select Id from OpportunitySplitType where IsActive = true and DeveloperName != 'Revenue'];
        if(!splitTypes.isEmpty())
        {
            List<OpportunitySplit> newSplits = new List<OpportunitySplit>();
            Opportunity newOpp, oldOpp;
            for(Id oppId : newItems.keySet())
            {
                newOpp = (Opportunity)newItems.get(oppId);
                if(oldItems == null)
                {
                    // add Opportunity owner to the split
                    newSplits.addAll(getNewSplits(newOpp, newOpp.OwnerId, splitTypes));
                    // add Technical_Responsible__c to the split
                    if(newOpp.Technical_Responsible__c != null)
                    {
                        newSplits.addAll(getNewSplits(newOpp, newOpp.Technical_Responsible__c, splitTypes));
                    }
                }
                else
                {
                    oldOpp = (Opportunity)oldItems.get(newOpp.Id);
                    // add new Opportunity owner to the split                    
                    if(isFieldValueChanged(newOpp.OwnerId, oldOpp.OwnerId, OpportunityTriggerController.oppOwnerInAfterUpdate))
                    {                        
                        newSplits.addAll(getNewSplits(newOpp, newOpp.OwnerId, splitTypes));
                        // add the TR user back to the Opportunity Splits after the Opportunity ower changes, because all
                        // Opportunity Splits will be auto-removed after the owner is changed. 
                        if(newOpp.Technical_Responsible__c != null)
                        {
                            newSplits.addAll(getNewSplits(newOpp, newOpp.Technical_Responsible__c, splitTypes));
                        }
                        OpportunityTriggerController.oppOwnerInAfterUpdate = newOpp.OwnerId;
                    }

                    // add new Technical_Responsible__c to the split
                    if(isFieldValueChanged(newOpp.Technical_Responsible__c, oldOpp.Technical_Responsible__c, OpportunityTriggerController.oppTRInAfterUpdate))
                    {
                        OpportunityTriggerController.oppTRInAfterUpdate = newOpp.Technical_Responsible__c;
                        if(newOpp.Technical_Responsible__c != null)
                        {
                            newSplits.addAll(getNewSplits(newOpp, newOpp.Technical_Responsible__c, splitTypes));
                        }
                    }
                }
            }   
            if(!newSplits.isEmpty())
            {
                System.debug('$$' + newSplits);
                // Somehow, we get insufficient privileges issue, so we move the DML operations to a Queuable job.
                if(!Test.isRunningTest())
                {
                    System.enqueueJob(new AsyncOppSplitsJob(newSplits));
                }                
            }
        }
    }

    
    // Add by SNAP
    private List<OpportunitySplit> getNewSplits(Opportunity opp, Id ownerId, List<OpportunitySplitType> splitTypes)
    {
        List<OpportunitySplit> splits = new List<OpportunitySplit>();
        for(OpportunitySplitType sType : splitTypes)
        {
            splits.add(new OpportunitySplit(SplitOwnerId = ownerId, OpportunityId = opp.Id, SplitTypeId = sType.Id, SplitPercentage = 100));
        }
        return splits;
    }
    
    // Add by SNAP
    private void deleteOppSplits(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {
        Opportunity newOpp, oldOpp;
        Map<String, Set<Id>> oppIdMap = new Map<String, Set<Id>>{
            'RSM' => new Set<Id>(), 
            'SE' => new Set<Id>()
        };
            
        for(Id oppId : newItems.keyset())
        {
            newOpp = (Opportunity)newItems.get(oppId);
            oldOpp = (Opportunity)oldItems.get(oppId);

            // delete all old RSM splits when the Opportunity owner is changed.
            if(isFieldValueChanged(newOpp.OwnerId, oldOpp.OwnerId, OpportunityTriggerController.oppOwnerInBeforeUpdate))
            {
                oppIdMap.get('RSM').add(newOpp.Id);
                OpportunityTriggerController.oppOwnerInBeforeUpdate = newOpp.OwnerId;
            }            

            // delete all old SE splits when the Technical_Responsible__c is changed.
            if(isFieldValueChanged(newOpp.Technical_Responsible__c, oldOpp.Technical_Responsible__c, OpportunityTriggerController.oppTRInBeforeUpdate))
            {
                oppIdMap.get('SE').add(newOpp.Id);
                OpportunityTriggerController.oppTRInBeforeUpdate = newOpp.Technical_Responsible__c;
            }
        }
        for(String roleType : oppIdMap.keySet())
        {
            Set<Id> oppIds = oppIdMap.get(roleType);
            if(!oppIds.isEmpty())
            {
                delete [select Id from OpportunitySplit where SplitType.IsActive = true and SplitType.DeveloperName != 'Revenue' and OpportunityId in :oppIds and Role_Type2__c = :roleType];
            }
        }
    }

    //Add by SNAP
    private Boolean isFieldValueChanged(String newFieldValue, String oldFieldValue, String auditFieldValue)
    {
        if(auditFieldValue == '')
        {
            return newFieldValue != oldFieldValue;
        }
        else
        {
            return newFieldValue != auditFieldValue;
        }
    }
}