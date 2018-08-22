@isTest
public class AssetTriggerHandlerTest {
    @testsetup
    public static void setupTestData() {
        ContractTestClassHelper.createTestProducts();
        ContractTestClassHelper.createTestDataCustomer();
    }
    
    public testmethod static void testHardware() {
        System.assertEquals([SELECT Id, Name FROM Product2 LIMIT 10]+'', ' ');
    }
    
    
}