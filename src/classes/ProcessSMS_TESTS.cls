@isTest
public class ProcessSMS_TESTS {
	
@isTest 
static void testNewSMS() {
  //setup sample responses

		ProcessSMS_TESTS.setupSMSResponses();
		ProcessSMS_TESTS.setupSMSConfig();
		ProcessSMS_TESTS.setupMockSMSPost();
		ProcessSMS_TESTS.setupMockSMSPost2();

  		String accountSid = 'AC03c2fcd60e144e7cbeed179fcbf812a3';
  
   		String methodAuthToken = '1c892n40nd03kdnc0112slzkl3091j20';
        TwilioRestClient client = new TwilioRestClient(accountSid,methodAuthToken);
        
        // This is the signature we expect
      	String expected_sig = '+MQjITzHBoL492o2O6bi/FyjMqA=';
		
		RestRequest req = ProcessSMS_TESTS.setupRestRequest(methodAuthToken,accountSid,expected_sig);

        String JSONMsg = '{"message":"success"}';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        smsToApex.incomingSMS();
		
		//For new records, check smsrecord record is created        
        SMS_Message_Tracking__c [] smsrecord = [Select Id, TO_Number__c, FROM_Number__c  from SMS_Message_Tracking__c];
       	system.assertequals('12025551234', smsrecord[0].FROM_Number__c);
       	system.assertequals('2026574006', smsrecord[0].To_Number__c);
        
       	//now simulate email to chatter
       	// Create a new test email and envelope object
   		Messaging.InboundEmail emailblank = new Messaging.InboundEmail();
   		Messaging.InboundEnvelope envblank = new Messaging.InboundEnvelope();

		// Create the plainTextBody with no info to parse - this should create an empty lead with last name of unknown
		    emailblank.plainTextBody = 'test params 5';
		    emailblank.fromAddress ='pchurchill1@bfcclient.com';
		    emailblank.subject='NEW:' + smsrecord[0].Id;

		 // call the class and test it with the data in the testMethod
		   EmailtoChatter ebfc = new EmailtoChatter();
		   ebfc.handleInboundEmail(emailblank, envblank );      

		//force reply to be sent
    	test.stopTest();
		
		}

	//Now test new sms to existing smsrecord
	@isTest
	static void testNewSMSforExistingsmsrecord() {

 //setup sample responses
		
		ProcessSMS_TESTS.setupSMSResponses();
		ProcessSMS_TESTS.setupSMSConfig();
		ProcessSMS_TESTS.setupMockSMSPost();
		ProcessSMS_TESTS.setupMockSMSPost2();


  		//Create existing record
  
  		SMS_Message_Tracking__c smsrecordnew = new SMS_Message_Tracking__c(
  			FROM_Number__c = '2025551234', 
  			TO_Number__c = '2026574006',
  			Message__c = 'TEST 123');
  		insert smsrecordnew;
      
  		String accountSid = 'AC03c2fcd60e144e7cbeed179fcbf812a3';
  		String methodAuthToken = '1c892n40nd03kdnc0112slzkl3091j20';
        TwilioRestClient client = new TwilioRestClient(accountSid,methodAuthToken);
       
        // This is the signature we expect
        String expected_sig = '+MQjITzHBoL492o2O6bi/FyjMqA=';
		
		RestRequest req = ProcessSMS_TESTS.setupRestRequest(methodAuthToken,accountSid,expected_sig);

        String JSONMsg = '{"message":"success"}';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        smsToApex.incomingSMS();
		
	  	//now simulate email to chatter
       	// Create a new test email and envelope object
   		Messaging.InboundEmail emailblank = new Messaging.InboundEmail();
   		Messaging.InboundEnvelope envblank = new Messaging.InboundEnvelope();

		// Create the plainTextBody with no info to parse - this should create an empty lead with last name of unknown
		    emailblank.plainTextBody = 'test params 5';
		    emailblank.fromAddress ='pchurchill1@bfcclient.com';
		    emailblank.subject='UPDATE:' + smsrecordnew.Id;

		 // call the class and test it with the data in the testMethod
		   EmailtoChatter ebfc = new EmailtoChatter();
		   ebfc.handleInboundEmail(emailblank, envblank );      

		//force reply to be sent
    	test.stopTest();
	     
	}


	@isTest
	static void testNewSMSforExistingCase() {

 //setup sample responses
		ProcessSMS_TESTS.setupSMSResponses();
		ProcessSMS_TESTS.setupSMSConfig();
		ProcessSMS_TESTS.setupMockSMSPost();
		ProcessSMS_TESTS.setupMockSMSPost2();

  		//Create existing record
  		SMS_Message_Tracking__c smsrecordnew = new SMS_Message_Tracking__c(
  			FROM_Number__c = '2025551234', 
  			TO_Number__c = '2026574006',
  			Message__c = 'TEST 123');
  			insert smsrecordnew;
  			
         //now check new update passed to Case Feed
  		String accountSid = 'AC03c2fcd60e144e7cbeed179fcbf812a3';
  		String methodAuthToken = '1c892n40nd03kdnc0112slzkl3091j20';
        TwilioRestClient client = new TwilioRestClient(accountSid,methodAuthToken);
       
        // This is the signature we expect
        String expected_sig = '+MQjITzHBoL492o2O6bi/FyjMqA=';
		
		RestRequest req = ProcessSMS_TESTS.setupRestRequest(methodAuthToken,accountSid,expected_sig);

        String JSONMsg = '{"message":"success"}';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        smsToApex.incomingSMS();
		
	   	//now simulate email to chatter
       	// Create a new test email and envelope object
   		Messaging.InboundEmail emailblank = new Messaging.InboundEmail();
   		Messaging.InboundEnvelope envblank = new Messaging.InboundEnvelope();

		// Create the plainTextBody with no info to parse - this should create an empty lead with last name of unknown
		    emailblank.plainTextBody = 'test params 5';
		    emailblank.fromAddress ='pchurchill1@bfcclient.com';
		    emailblank.subject='UPDATE:' + smsrecordnew.Id;

		 // call the class and test it with the data in the testMethod
		   EmailtoChatter ebfc = new EmailtoChatter();
		   ebfc.handleInboundEmail(emailblank, envblank );      

		  /*
		   			//Now set search for inbound request
             Id [] fixedSearchResultsc = new Id[1];
 	 			fixedSearchResultsc[0] = cons[0].Id;
  			Test.setFixedSearchResults(fixedSearchResultsc);
		 */ 

		//force reply to be sent
    	test.stopTest();
     
	}
	
	@isTest
	static void testOutboundSMSforExistingCase() {
/*
 		//setup sample responses
		ProcessSMS_TESTS.setupSMSResponses();
		ProcessSMS_TESTS.setupSMSConfig();
		ProcessSMS_TESTS.setupMockSMSPost();
		ProcessSMS_TESTS.setupMockSMSPost2();

  		//Create existing record
 			SMS_Message_Tracking__c smsrecordnew = new SMS_Message_Tracking__c(
	  			FROM_Number__c = '2025551234', 
	  			TO_Number__c = '2026574006',
	  			Message__c = 'TEST 123');
  			insert smsrecordnew;
  		

  			caseSMSextension_bfc bcase = new caseSMSextension_bfc(new ApexPages.StandardController(smsrecordCases[0]));
			
			//Check sample messages
			System.currentPageReference().getParameters().put('msgid', 'HELP');
			bcase.setsms();
			system.assertequals('THIS is a HELP TEST', bcase.smsMessage);
    		
    		//Now set manually
    		bcase.smsMessage = 'Test Outbound';
			  bcase.sendsms();
			
			SMS_Message_Tracking__c smstrack = [Select Id, Status__c from SMS_Message_Tracking__c];
			system.assertequals('Queued', smstrack.Status__c);
			bcase.refreshtrack();	
			system.assertequals(FALSE, bcase.bsmssent);
			
			smstrack.Status__c = 'Sent';
			update smstrack;
			
			bcase.refreshtrack();	
			system.assertequals(TRUE, bcase.bsmssent);
			
			bcase.returntocase();

			//Check Feed Comment
			String s = 'NEW SMS Sent at ' + String.valueof(system.now()) + ' FROM NHTRC'; 
                       s += '\n';
                       s += bcase.smsMessage;
                                           
      FeedComment [] fctest = [Select Id, CommentBody from FeedComment WHERE FeedItemId = :testfi[0].Id ORDER BY CreatedDate ASC];
			system.assertequals(2, fctest.size());
			String sComment = 'NEW SMS Sent at ' + String.valueof(system.today());
			system.assertequals(TRUE, fctest[1].CommentBody.Startswith(sComment));
                      
      //now convert feed
     caseSMSextension_bfc bcase2 = new caseSMSextension_bfc(new ApexPages.StandardController(smsrecordCases[0]));
     bcase2.convertfeedtotask();
     system.assertequals(1, [Select Count() from TASK WHERE WhatId = :smsrecordCases[0].Id AND Subject = 'SMS Message Thread']); 
       */  
	
	}

	@isTest
	static void testNewSMSBadSignature() {
  //setup sample responses

		ProcessSMS_TESTS.setupMockSMSPost();
		ProcessSMS_TESTS.setupSMSConfig();

  		String accountSid = 'AC03c2fcd60e144e7cbeed179fcbf812a3';
  
   		String methodAuthToken = '1c892n40nd03kdnc0112slzkl3091j20';
        TwilioRestClient client = new TwilioRestClient(accountSid,methodAuthToken);
        
        // This is NOT the signature we expect, since body different
        String expected_sig = '+MQjITzHBoL492o2O6bi/FyjMqA=';

        RestRequest req = new RestRequest();
        req.addParameter('AuthToken',methodAuthToken);
        req.addParameter('AccountSid',accountSid);
        req.addParameter('Body','test params 6');
        req.addParameter('From','+2025551234');
        req.addParameter('To','+12026574006');
        req.addParameter('ApiVersion','2010-04-01');
         
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.addHeader('X-Twilio-Signature', expected_sig); // Add a signature
        
        req.requestURI = '/services/apexrest/smstoNHTRC/';
        req.httpMethod = 'POST';
    
        String JSONMsg = '{"message":"success"}';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        smsToApex.incomingSMS();
       
	}
	
	@isTest
	static void testSMSAutoResponse() {
  //setup sample responses

		ProcessSMS_TESTS.setupSMSResponses();
		ProcessSMS_TESTS.setupSMSConfig();
		ProcessSMS_TESTS.setupMockSMSPost();
		ProcessSMS_TESTS.setupMockSMSPost2();

  		String accountSid = 'AC03c2fcd60e144e7cbeed179fcbf812a3';
  
   		String methodAuthToken = '1c892n40nd03kdnc0112slzkl3091j20';
        TwilioRestClient client = new TwilioRestClient(accountSid,methodAuthToken);
        
        // This is NOT the signature we expect, since body different
        String expected_sig = 'sr6pf5xYlIENJlxVIFGoksan4h4=';

        RestRequest req = new RestRequest();
        req.addParameter('AuthToken',methodAuthToken);
        req.addParameter('AccountSid',accountSid);
        req.addParameter('Body','HELP Test');
        req.addParameter('From','+2025551234');
        req.addParameter('To','+12026574006');
        req.addParameter('ApiVersion','2010-04-01');
         
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.addHeader('X-Twilio-Signature', expected_sig); // Add a signature
        
        req.requestURI = '/services/apexrest/smstoNHTRC/';
        req.httpMethod = 'POST';
    
        String JSONMsg = '{"message":"success"}';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        smsToApex.incomingSMS();
		
       
	}

	@isTest 
	static void testSMSResponse() {
  //setup sample responses
		system.debug('### Response');
		//Put sample inbound sms
		SMS_Message_Tracking__c smstrack = new SMS_Message_Tracking__c();
		smstrack.SID__c = 'SIM1234567890';
		smstrack.Status__c = 'Queued';
		upsert smstrack SID__c;
  		
  		String accountSid = 'AC03c2fcd60e144e7cbeed179fcbf812a3';
   		String methodAuthToken = '1c892n40nd03kdnc0112slzkl3091j20';
        TwilioRestClient client = new TwilioRestClient(accountSid,methodAuthToken);
        
        // This is the signature we expect
      	String expected_sig = 'npY4VZv3MbatpjagcIXzzkqavLs=';
		
		RestRequest req = new RestRequest();
        req.addParameter('AuthToken',methodAuthToken);
        req.addParameter('AccountSid',accountSid);
        req.addParameter('ApiVersion','2010-04-01');
        
        req.addParameter('SmsSid','SIM1234567890');
        req.addParameter('SmsStatus','Sent');
         
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.addHeader('X-Twilio-Signature', expected_sig); // Add a signature
        
        req.requestURI = '/services/apexrest/smstoNHTRC/';
        req.httpMethod = 'POST';
        
        String JSONMsg = '{"message":"success"}';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        smsResponse.incomingSMSResponse();
		test.stopTest();

		//Check Message update		
		SMS_Message_Tracking__c smstest = [Select Id, Status__c from SMS_Message_Tracking__c WHERE SID__c = 'SIM1234567890'];
		system.assertequals('Sent', smstest.Status__c);
		}

@isTest 
	static void testBadSMSResponse() {
  		//Since bad signature, should not update this SMS Track record
		system.debug('### Response');
		//Put sample inbound sms
		SMS_Message_Tracking__c smstrack = new SMS_Message_Tracking__c();
		smstrack.SID__c = 'SIM1234567890';
		smstrack.Status__c = 'Queued';
		upsert smstrack SID__c;
  		
  		String accountSid = 'AC03c2fcd60e144e7cbeed179fcbf812a3';
   		String methodAuthToken = '1c892n40nd03kdnc0112slzkl3091j20';
        TwilioRestClient client = new TwilioRestClient(accountSid,methodAuthToken);
        
        // This is the signature we expect
      	String expected_sig = 'npY4VZv3MbatpjagcIXzzkqavLs=';
		
		RestRequest req = new RestRequest();
        req.addParameter('AuthToken',methodAuthToken);
        req.addParameter('AccountSid',accountSid);
        req.addParameter('ApiVersion','2010-04-01');
        //This Param is different (SMS in Capitals) = bad signature match
        req.addParameter('SMSSid','SIM1234567890');
        req.addParameter('SmsStatus','Sent');
         
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.addHeader('X-Twilio-Signature', expected_sig); // Add a signature
        
        req.requestURI = '/services/apexrest/smstoNHTRC/';
        req.httpMethod = 'POST';
        
        String JSONMsg = '{"message":"success"}';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        smsResponse.incomingSMSResponse();
		test.stopTest();

		//Check Message update		
		SMS_Message_Tracking__c smstest = [Select Id, Status__c from SMS_Message_Tracking__c WHERE SID__c = 'SIM1234567890'];
		system.assertequals('Queued', smstest.Status__c);
		}


public static void setupSMSResponses() {

		List<SMS_Responses__c> smsresponses = new List<SMS_Responses__c> ();
		smsresponses.add(new SMS_Responses__c(Name = 'DEFAULT', Message__c = 'THIS is a TEST'));
		smsresponses.add(new SMS_Responses__c(Name = 'HELP', Message__c = 'THIS is a HELP TEST'));

		insert smsresponses;
                    

}

//set mock post
public static void setupMockSMSPost() {

string accountJsonResponseBody='{'
        +'"account_sid": "AC03c2fcd60e144e7cbeee413fcbf812a3",'
        +'"api_version": "2008-08-01",'
        +'"body": "Test sending sms from twilio",'
        +'"date_created": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"date_sent": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"date_updated": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"direction": "outbound-api",'
        +'"from": "+14158141829",'
        +'"price": "-0.02000",'
        +'"sid": "SM800f449d0399ed014aae2bcc0cc2f2ec",'
        +'"status": "queued",'
        +'"to": "+14159978453",'
        +'"uri": "/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages/SM800f449d0399ed014aae2bcc0cc2f2ec.json"'
        +'}';
        Twilio_TestHTTPMock.getInstance().putResponse(
            'POST',
            'https://api.twilio.com/2010-04-01/Accounts/AC03c2fcd60e144e7cbeee413fcbf812a3/SMS/Messages.json',
            new Twilio_TestHTTPMock.Response(accountJsonResponseBody,200)
            );
}
public static void setupMockSMSPost2() {

string accountJsonResponseBody='{'
        +'"account_sid": "AC03c2fcd60e144e7cbeee413fcbf812a3",'
        +'"api_version": "2008-08-01",'
        +'"body": "Test sending sms from twilio",'
        +'"date_created": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"date_sent": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"date_updated": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"direction": "outbound-api",'
        +'"from": "+14158141829",'
        +'"price": "-0.02000",'
        +'"sid": "SM800f449d0399ed014aae2bcc0cc2f2ec",'
        +'"status": "queued",'
        +'"to": "+14159978453",'
        +'"uri": "/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages/SM800f449d0399ed014aae2bcc0cc2f2ec.json"'
        +'}';
        Twilio_TestHTTPMock.getInstance().putResponse(
            'POST',
            'https://api.twilio.com/2010-04-01/Accounts/ACba8bc05eacf94afdae398e642c9cc32d/SMS/Messages.json',
            new Twilio_TestHTTPMock.Response(accountJsonResponseBody,200)
            );

}

public static RestRequest setupRestRequest(String mat, String asid, String expected_sig) {
 RestRequest req = new RestRequest();
        req.addParameter('AuthToken',mat);
        req.addParameter('AccountSid',asid);
        req.addParameter('Body','test params 5');
        req.addParameter('From','+12025551234');
        req.addParameter('To','+12026574006');
        req.addParameter('ApiVersion','2010-04-01');
         
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.addHeader('X-Twilio-Signature', expected_sig); // Add a signature
        
        req.requestURI = '/services/apexrest/smstoNHTRC/';
        req.httpMethod = 'POST';
        return req;
}

private static void setupSMSConfig() {

String sGroupNew = 'SMS Notifications New for ' + system.today().format();
String sGroupUpdate = 'SMS Notifications Update for ' + system.today().format();
String sGroupInfo = 'SMS Notifications New Info ' + system.today().format();

List<CollaborationGroup> cg = new List<CollaborationGroup> ();
cg.add(new CollaborationGroup(Name = sGroupNew, CollaborationType = 'Public', OwnerId = userinfo.getUserId()));
cg.add(new CollaborationGroup(Name = sGroupUpdate, CollaborationType = 'Public', OwnerId = userinfo.getUserId()));
cg.add(new CollaborationGroup(Name = sGroupInfo, CollaborationType = 'Public', OwnerId = userinfo.getUserId()));
insert cg;

SMS_Config__c smsc = new SMS_Config__c(Name = 'Default');
smsc.SMS_User_Id__c = userinfo.getUserId();
smsc.Email_to_Chatter_Address__c = 'email_to_chatter@test.apex.sandbox.salesforce.com';
smsc.SMS_Group_id__c = cg[0].Id;
smsc.SMS_Info_Group_Id__c = cg[1].Id;
smsc.SMS_Update_Group_Id__c = cg[2].Id;
smsc.Callback_URL__c = 'https://www.bfclient.com';
smsc.send_Default_Responses__c = TRUE;



insert smsc;

}

}