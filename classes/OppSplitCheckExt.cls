/**
 * Used by OppSplitCheck VF to validate Opportunity Split and dispaly warning message or error message
 * at the top of Opportunity detail when the total split is over or below allocated. 
 *
 * @author: SnapBI
 *
 * @changelog
 * 08/09/2018 Eric He - Created.
 */
public class OppSplitCheckExt 
{
    public String WarningMsg { get; private set; }
    public String ErrorMsg { get; private set; }
    public OppSplitCheckExt(ApexPages.StandardController stdController) 
    {
        Id oppId = stdController.getId();
        WarningMsg = ErrorMsg = '';
        checkOppSplits(oppId);
    }

    private void checkOppSplits(Id oppId)
    {
        Map<String, Map<String, Decimal>> splitPercentageMap = new Map<String, Map<String, Decimal>>();
        Decimal totalPercentage;
        for(OpportunitySplit split : [select SplitPercentage, Role_Type2__c, SplitType.MasterLabel 
                                      from OpportunitySplit 
                                      where OpportunityId = :oppId and SplitType.IsActive = true and SplitType.DeveloperName != 'Revenue'
                                      order by SplitType.MasterLabel, Role_Type2__c])
        {
            if(!splitPercentageMap.containsKey(split.SplitType.MasterLabel))
            {
                splitPercentageMap.put(split.SplitType.MasterLabel, new Map<String, Decimal>());
            }
            if(!splitPercentageMap.get(split.SplitType.MasterLabel).containsKey(split.Role_Type2__c))
            {
                splitPercentageMap.get(split.SplitType.MasterLabel).put(split.Role_Type2__c, split.SplitPercentage);
            }
            else
            {
                totalPercentage = splitPercentageMap.get(split.SplitType.MasterLabel).get(split.Role_Type2__c);
                totalPercentage += split.SplitPercentage;
                splitPercentageMap.get(split.SplitType.MasterLabel).put(split.Role_Type2__c, totalPercentage);
            }
        }

        for(string splitType : splitPercentageMap.keySet())
        {
            for(String roleType : splitPercentageMap.get(splitType).keySet())
            {
                totalPercentage = splitPercentageMap.get(splitType).get(roleType);
                // splits are not fully allocated.
                if(totalPercentage < 100)
                {
                    ErrorMsg += 'DEAL NOT FULLY ALLOCATED TO ' + roleType + ' at ' + splitType + ': ' + totalPercentage + '%<br />';
                }
                // splits are over-allocated.
                else if(totalPercentage > 100)
                {
                    WarningMsg += 'DEAL OVER-ALLOCATED TO ' + roleType + ' at ' + splitType + ': ' + totalPercentage + '%<br />';
                }
            }
        }
    }
}