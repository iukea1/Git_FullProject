@IsTest
public class TEstDataClass {

    @isTest
    static void testLinkRVMemberWithContact()
    {
        Contact contact1 = new Contact(LastName = 'contact acme 1', Email = 'rvmembertest@silverpeak.acme');
        Contact contact2 = new Contact(LastName = 'contact acme 2', Email = 'rvmembertest@silverpeak.acme');
        insert new List<Contact> { contact1, contact2 };
        
        rvpe__RVMember__c rvMember1 = new rvpe__RVMember__c(Name = 'rv member acme 1', rvpe__UserName__c = 'rv member acme 1', rvpe__ExtMemberId__c = 999991, rvpe__Email__c = 'rvmembertest@silverpeak.acme');
        rvpe__RVMember__c rvMember2 = new rvpe__RVMember__c(Name = 'rv member acme 2', rvpe__UserName__c = 'rv member acme 2', rvpe__ExtMemberId__c = 999992, rvpe__Email__c = 'rvmembertest@silverpeak.acme');
        rvpe__RVMember__c rvMember3 = new rvpe__RVMember__c(Name = 'rv member acme 3', rvpe__UserName__c = 'rv member acme 3', rvpe__ExtMemberId__c = 999993, rvpe__Email__c = 'rvmembertest2@silverpeak.acme');
        insert new List<rvpe__RVMember__c> { rvMember1, rvMember2, rvMember3 };
        
        system.assertEquals(rvMember2.Id, [select RV_Member__c from Contact where Id = :contact1.Id limit 1].RV_Member__c);
        List<Contact> newContacts = [select Id, RV_Member__c from Contact where Email = 'rvmembertest2@silverpeak.acme'];
        system.assertEquals(rvMember3.Id, newContacts[0].RV_Member__c);
        system.assertEquals(newContacts[0].Id, [select rvpe__SFContact__c from rvpe__RVMember__c where Id = :rvMember3.Id limit 1].rvpe__SFContact__c);
    }
}