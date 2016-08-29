@isTest
public class CheckForPrimayContractTest {
    @isTest
    static void test1()
    {
    Account acc = new Account(Name='acme');
    insert acc;
    Contract newCont1 = new Contract();
    newCont1.AccountId = acc.Id;
    newCont1.Status = 'Draft';
    newCont1.Contract_Type__c = 'Gold';
    newCont1.StartDate = date.today();
    newCont1.EndDate = date.today();
    newCont1.SP_Contract_Number__c = 'zzz333tq';
    insert newCont1;
    
    Contract newCont2 = new Contract();
    newCont2.AccountId = acc.Id;
    newCont2.Status = 'Draft';
    newCont2.Contract_Type__c = 'Gold';
    newCont2.StartDate = date.today();
    newCont2.EndDate = date.today();
    newCont2.SP_Contract_Number__c = 'zyz313tq';
    newCont2.SBQQ__MasterContract__c = true;
    insert newCont2;
    
    Contract newCont3 = new Contract();
    newCont3.AccountId = acc.Id;
    newCont3.Status = 'Draft';
    newCont3.Contract_Type__c = 'Gold';
    newCont3.StartDate = date.today();
    newCont3.EndDate = date.today();
    newCont3.SP_Contract_Number__c = 'zwz349tr';
    newCont3.SBQQ__MasterContract__c = true;
    try{
        insert newCont3;    
    }catch(Exception e) {
        System.Debug(e);
    }
    }
}