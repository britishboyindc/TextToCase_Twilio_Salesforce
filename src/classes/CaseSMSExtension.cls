public class CaseSMSExtension {

//To enable updates for batches to be called via buttons
private final Case scase;
public String smsMessage {get;set;}
public List<SMS_Responses__c> sampleresponses {get;set;}
public List<String> SampleResponseCategories {get;set;}
public Map <String, List<SMS_Responses__c>> sampleresponsemap {get;set;}

Map<String, SMS_Responses__c> smsresponses;
public List<SelectOption> sNumbers {get;set;}
public String fromNumber {get;set;}

public Boolean bsmssent {get;set;}
public SMS_Message_Tracking__c smstrack {get;set;}
SMS_Message_Tracking__c initialsmstrack;

// The extension constructor initializes the private member 
//variable by using the getRecord method from the standard controller.
    public CaseSMSExtension (ApexPages.StandardController stdController) {
        this.scase = (Case)stdController.getRecord();
        sNumbers = new List<SelectOption>();
        fromNumber = scase.SMS_To_Number__c;

        setupSampleResponses();

        if (String.IsEmpty(scase.Contact.MobilePhone)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is no Cell Phone Listed for this Contact!'));
        }
    }

    public pagereference sendsms () {
    Sobject c = scase;
    SendSMSMessage sms = new SendSMSMessage();
    //return null;  
    initialsmstrack = sms.sendsms(c, smsMessage, scase.Contact.MobilePhone, fromNumber, scase.SMS_Feed_Id__c);
    return  null;
    }
     

    public pagereference setsms() {
        String smsid = System.currentPageReference().getParameters().get('msgid');
        smsMessage = smsresponses.get(smsid).message__c;
        return null;
    }
    
    private void setupSampleResponses() {
        smsresponses = SMS_Responses__c.getAll();
        sampleresponses = SMS_Responses__c.getall().values();
        sampleresponsemap = new Map<String, List<SMS_Responses__c>> ();

        SampleResponseCategories = new List<String> ();
        SampleResponseCategories.add('Auto');
        SampleResponseCategories.add('Shelter');
        SampleResponseCategories.add('Technology Specific');
        
        sampleresponsemap.put('Auto', new List<SMS_Responses__c> ());
        sampleresponsemap.put('Shelter', new List<SMS_Responses__c> ());
        sampleresponsemap.put('Technology Specific', new List<SMS_Responses__c> ());
        
        for (String s: smsresponses.keyset() ) {
            if (sampleresponsemap.containskey(smsresponses.get(s).Category__c) ) {
                    List<SMS_Responses__c> clist = sampleresponsemap.get(smsresponses.get(s).Category__c);
                    clist.add(smsresponses.get(s));
                    sampleresponsemap.put(smsresponses.get(s).Category__c, cList);
            }
        }

        //Setup From Numbers
        sNumbers.add(new SelectOption('3012004370','3012004370'));
       
    }//end setup method
}