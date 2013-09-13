public with sharing class ProcessInboundSMS2 {

 String fromNumber;
 String toNumber;
 

public void process(Map<String, String> params) {
    system.debug(params);   
        //Assume New Message with one part
    String sAction = 'NEW';
    String sMsgType = 'Single';
    Boolean bSendAutoResponse = FALSE;
    Boolean bProcess = FALSE;
 
    Id RecordId;
    String sResponse; 
          
    fromNumber = params.get('From');
    toNumber = params.get('To');
    String message = params.get('Body');
    String plainnumber = SMSUtilities.removeformatphonenumber(fromNumber);
    toNumber = SMSUtilities.removeformatphonenumber(toNumber);
    tonumber = tonumber.removeStart('1');
     
        //Setup New SMS Object
      SMS_Message_Tracking__c newsms = new SMS_Message_Tracking__c();
          newsms.Direction__c = 'Inbound';
          newsms.SID__c = params.get('SmsSid');
          newsms.Status__c = 'Received';
          newsms.FROM_Number__c = plainnumber;
          newsms.TO_Number__c = tonumber;
          newsms.Request_Type__c = message.substringBefore(' ').toUpperCase();
          newsms.Message__c = message;

        //Do we have a previous sms from this number?
        List<SMS_Message_Tracking__c> lastmessage = 
          [Select Id, Name, Matched_Case__c, Related_Message__c, Status__c,
             Total_Message_Parts_Received__c, CreatedDate
            FROM SMS_Message_Tracking__c
            WHERE Direction__c = 'Inbound' AND FROM_Number__c = :plainnumber 
            ORDER BY CreatedDate DESC];

    //Process based on previous message    
    if (lastmessage.size() == 0) {//mo matches, so brand new message
            bSendAutoResponse = TRUE;
            bProcess = TRUE;
        }

   else {//at least one previous message
         SMS_Message_Tracking__c  previousmessage = lastmessage[0];
         system.debug('PM' + previousmessage);
   
            if (previousmessage.Matched_Case__c == null) { //update to a non-processed message
                //No Auto Response, but attached to existing message
                        newsms.Related_Message__c = previousmessage.Id;
                        sAction = 'UPDATE TO PENDING';
                 }    

            else {//Previous message has Case, but is it a current Case?
                    
                        Long iCurrent = system.now().getTime() - previousmessage.CreatedDate.getTime();
      
                       if (iCurrent < 86400000) {//less than 24 hours
                            newsms.Matched_Case__c = previousmessage.Matched_Case__c; 
                            sAction = 'UPDATE TO CASE';
                            bProcess = TRUE;
                        }
           
                        else {//Treat as new Case
                            bSendAutoResponse = TRUE;
                            bProcess = TRUE;
                        }
                  }
            
            //Update based on multi part
            //if part of multi part, link to first part of message
          }
   
        newsms.Type__c = sAction;
        
        try {
        insert newsms;
        if (RecordId == null) {
          RecordId = newsms.Id;
        }
      }
   
      catch (Exception Ex) {
        system.debug(ex);   
      }

          if (bSendAutoResponse) {//For new, check if we send AutoReponse        
            if (SMS_Config__c.getValues('Default').Send_Default_Responses__c) {
                    sResponse = SMSUtilities.getAutoReponse (newsms.Request_Type__c);
                Id arsmsid = createAutoResponseSMSTracking(sResponse, newsms.Id);
                reply(toNumber,fromNumber, sResponse, arsmsid);
          }
      } 
                
          //post to chatter feed - use an email service to post it into Chatter
          if (bProcess) {
            List<String> sChatter = new List<String> {SMS_Config__c.getValues('Default').Email_to_Chatter_Address__c};
            
            String sSubject = RecordId;
               
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              mail.setToAddresses(sChatter);
              mail.setSenderDisplayName('Chatter Post');
              mail.setSubject(sSubject);
              mail.setPlainTextBody(message);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           }
      }

 @future(callout=true)
    public static void reply(String fromNumber, String toNumber, String message, Id smsmessageId) {

      TwilioAccount account = TwilioAPI.getDefaultAccount();
    
        Map<String, String> params = new Map<String, String>{
          'From' => fromNumber,
          'To' => toNumber,
          'Body' => message,
          'StatusCallback' => SMS_Config__c.getValues('Default').Callback_URL__c
        };
        
        TwilioSms sms = account.getSmsMessages().create(params);
        SMS_Message_Tracking__c smstrack = new SMS_Message_Tracking__c(Id = smsmessageId);
        smstrack.SID__c = sms.getSid();
        update smstrack;
        System.debug('Sent SMS SID: '+sms.getSid());
    }

private Id createAutoResponseSMSTracking (String armessage, Id relatedmessageid) {

        SMS_Message_Tracking__c smstrack = new SMS_Message_Tracking__c();
          smstrack.FROM_Number__c = toNumber;
          smstrack.TO_Number__c = fromNumber;
          smstrack.Message__c = armessage;
          smstrack.Type__c = 'Auto';
          smstrack.Direction__c = 'Outbound';
          smstrack.Status__c = 'Queued';
          smstrack.Related_Message__c = relatedmessageid;
        insert smstrack;

return smstrack.Id;
}

} //End Class