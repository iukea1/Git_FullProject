@isTest
global class PerfHelpEmailHandlerTest {

@isTest
  static void testIsDuplicateCase()
  {
      Contact newContact = new Contact(LastName = 'acmeLastName', Email='acme@mail.com');
      insert newContact;
      Case newCase = new Case(Subject='acme 1981', ContactId=newContact.Id);
      insert newCase;
      System.assertEquals(true, PerfHelpEmailHandler.isDuplicateCase('acme 1981', 'acme@mail.com'));
  }
  
    @isTest 
    static void testParseCaseNumber()
    {
        String[] caseNumbers = PerfHelpEmailHandler.parseCaseNumber('test[20100101-2015]');
        System.assertEquals(1, caseNumbers.size());
        System.assertEquals('20100101-2015', caseNumbers[0]);
        
        caseNumbers = PerfHelpEmailHandler.parseCaseNumber('test[2015]');
        System.assertEquals(0, caseNumbers.size());
        
        caseNumbers = PerfHelpEmailHandler.parseCaseNumber('test[20100101-2015]ab[abcdefg]');
        System.assertEquals(1, caseNumbers.size());
        System.assertEquals('20100101-2015', caseNumbers[0]);
        
        caseNumbers = PerfHelpEmailHandler.parseCaseNumber('test[20100101-2015]ab[20110101-34567]');
        System.assertEquals(2, caseNumbers.size());
        System.assertEquals('20100101-2015', caseNumbers[0]);
        System.assertEquals('20110101-34567', caseNumbers[1]);
    }
  
  @isTest
  static void testCreateContactByMail()
  {
      PerfHelpEmailHandler.createContactByMail('test@test.com', 'kevin chong');
      List<Contact> contacts = [select Id, FirstName, lastName, Email from Contact where Email='test@test.com' and FirstName='kevin' and LastName='chong' limit 1];
      System.assertEquals(1, contacts.size());
  }
  
  @isTest
  static void testPerfHelpCaseSupportEmailHandler()
  {
    Messaging.Inboundemail testEmail = new Messaging.Inboundemail();
    testEmail.subject = 'acme subject';
    testEmail.fromAddress = 'Acme.InTestMethod@acme.com';
    testEmail.plainTextBody = 'This is a test Email plainTextBody !';
    List<Messaging.Inboundemail.Binaryattachment> bAttachments = new List<Messaging.Inboundemail.Binaryattachment>();
    List<Messaging.Inboundemail.Textattachment> tAttachments = new List<Messaging.Inboundemail.Textattachment>();
    Messaging.Inboundemail.Binaryattachment bAttachment = new Messaging.Inboundemail.Binaryattachment();
    bAttachment.body = Blob.valueOf('acme');
    bAttachment.fileName = 'binary attachment';
    bAttachments.add(bAttachment);
    testEmail.binaryAttachments = bAttachments;
    Messaging.Inboundemail.Textattachment tAttachment = new Messaging.Inboundemail.Textattachment();
    tAttachment.body = 'acme';
    tAttachment.fileName = 'text attachment';
    tAttachments.add(tAttachment);
    testEmail.textAttachments = tAttachments;
    Messaging.Inboundenvelope testEnvelope = new Messaging.Inboundenvelope();
    (new PerfHelpEmailHandler()).handleInboundEmail(testEmail, testEnvelope);
    Case tempCase = [select Id, CaseNumber from Case where Subject = :testEmail.subject];
    testEmail.subject = 'acme subject['+tempCase.CaseNumber+']';
    (new PerfHelpEmailHandler()).handleInboundEmail(testEmail, testEnvelope);
    //Test for illegal condition.
    Messaging.Inboundemail illegalFromNameEmail = new Messaging.Inboundemail();
    illegalFromNameEmail.fromName = 'system administrator';
    try
    {
    (new PerfHelpEmailHandler()).handleInboundEmail(illegalFromNameEmail, testEnvelope);
    }
    catch(Exception ex)
    {}
  }
    
}