public class ContractTestClassHelper {

    public static void createTestProducts() {
        Test.loadData(Pricebook2.sObjectType, 'test_data_pricebook2');
        Test.loadData(Product2.sObjectType, 'test_data_product2');
        Test.loadData(PricebookEntry.sObjectType, 'test_data_pricebookentry');
    }
    
    public static void createTestDataCustomer() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer' and sObjectType = 'Account' LIMIT 1];
    
        List<Account> aList = new List<Account>();
        aList.add(new Account(
            Name = 'Account Test Class-1',
            Type = 'Customer',
            Payment_Terms__c = 'Net 30',
            Service_Provider_Type__c = 'Carrier MSP',
            SP_MKTG__c = true,
            SBQQ__RenewalModel__c = 'Contract Based',
            RecordTypeId = rt.Id
        ));
        aList.add(new Account(
            Name = 'Account Test Class-2',
            Type = 'Customer',
            Payment_Terms__c = 'Net 30',
            Service_Provider_Type__c = 'Carrier MSP',
            SP_MKTG__c = true,
            SBQQ__RenewalModel__c = 'Contract Based',
            RecordTypeId = rt.Id
        ));
        aList.add(new Account(
            Name = 'Account Test Class-3',
            Type = 'Customer',
            Payment_Terms__c = 'Net 30',
            Service_Provider_Type__c = 'Carrier MSP',
            SP_MKTG__c = true,
            SBQQ__RenewalModel__c = 'Contract Based',
            RecordTypeId = rt.Id
        ));
        insert aList;
        
        List<Contact> cList = new List<Contact>();
        cList.add(new Contact(
            AccountId = aList[0].Id,
            FirstName = 'TestContactFirstName_1',
            LastName = 'TestContactLastName_1',
            Lead_Status__c = 'Converted to New Opportunity',
            LeadSource = 'Sales'
        ));
        cList.add(new Contact(
            AccountId = aList[1].Id,
            FirstName = 'TestContactFirstName_2',
            LastName = 'TestContactLastName_2',
            Lead_Status__c = 'Converted to New Opportunity',
            LeadSource = 'Sales'
        ));
        cList.add(new Contact(
            AccountId = aList[2].Id,
            FirstName = 'TestContactFirstName_3',
            LastName = 'TestContactLastName_3',
            Lead_Status__c = 'Converted to New Opportunity',
            LeadSource = 'Sales'
        ));
        
        
        List<Opportunity> oList = new List<Opportunity>();
        oList.add(new Opportunity());
        oList.add(new Opportunity());
        oList.add(new Opportunity());
        
    }
}