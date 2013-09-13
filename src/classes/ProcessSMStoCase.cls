public with sharing class ProcessSMStoCase {

    String sSubject; 
    String sautoresponse;
    String smessageThread;
    Case smscase;
    String sFinalMessage;
    String scode;
    Boolean bSuccess;
    List<String> AdditionalMessages;
    String sChatterMessage;
    List<SMS_Message_Tracking__c> smsmessageupdates;
    SMS_Message_Tracking__c msgtoprocess; 
    List<SMS_Message_Tracking__c> smsmessages;
    String sDate;
    Id GroupId; //Which Chatter Group Id to post notification in

public Boolean processsms(String emailSubject) {
    //Sandbox is added for Sandboxes
    sSubject = emailSubject.replace('Sandbox: ',''); 
    bSuccess = FALSE;
    AdditionalMessages = new List<String> ();
    smsmessageupdates = new List<SMS_Message_Tracking__c>();
    sDate = system.now().format();
    

    //Retrieve Inbound Message from Subject
    smsmessages = 
      [SELECT Id, Message__c, TO_Number__c, FROM_Number__c, Request_Type__c,
      Matched_Case__c, Type__c, Message_Part__c, Related_Message__c, 
      Related_Message__r.Case__c,
        (Select Id, Type__c, Message__c
          FROM RelatedMessages__r 
          ORDER By Message_Part__c ASC) 
      FROM SMS_Message_Tracking__c
      WHERE Id = :sSubject];

    if (smsmessages.size() > 0) {//record found
        msgtoprocess = smsmessages[0];
    
        String myPlainText= '';
        myPlainText = msgtoprocess.message__c;
       
       for (SMS_Message_Tracking__c s: msgtoprocess.RelatedMessages__r) {
                  if (s.Type__c == 'AUTO') {//auto response
                    sautoresponse = s.message__c;
                    s.Status__c = 'Processed';
                    smsmessageupdates.add(s);
                  }
                  else if (s.Type__c == 'UPDATE TO PENDING') {//auto response
                    s.Status__c = 'Process';
                    smsmessageupdates.add(s);
                  }
             }

             sFinalMessage = msgtoprocess.message__c;  

          if (msgtoprocess.type__c.equals('NEW') ) {
            //Should be a related message for Auto-Response
            
            smscase = SMSUtilities.createNewSMSCase(msgtoprocess);
            Contact caller = SMSUtilities.setupNewSMSCaller(msgtoprocess.FROM_Number__c);
            if (caller.Id == null) {
              insert caller;
            }

                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                smscase.setOptions(dmo);
            smscase.ContactId = caller.Id;
            insert smscase;

              GroupId = SMS_Config__c.getValues('Default').SMS_Group_id__c;
                //Depending on the text of the SMS, we post into differnt groups for new messages
                //INFO goes into a separate group
                if (msgtoprocess.Request_Type__c == 'INFO') {
                  GroupId = SMS_Config__c.getValues('Default').SMS_Info_Group_Id__c;
                }

               
            scode = msgtoprocess.message__c.substringBefore(' ').toUpperCase(); 
            sChatterMessage = 'New SMS Thread started at ' + sDate + ' FROM New Caller'; 
                sChatterMessage += '\n';
                    if (sFinalMessage != null) {
                            sChatterMessage += ' Message: ' + sFinalMessage;
                    }     
       
            msgtoprocess.Status__c = 'Processed';
            smsmessageupdates.add(msgtoprocess);
            updateChatterforNewCases();
            updateSMSMessages(smscase.Id);
      
          } //end master if for NEW

          else if (msgtoprocess.type__c.equals('UPDATE TO PENDING') ) {
          //Find SMS Thread 
            smscase = [Select Id, CaseNumber, SMS_Feed_Id__c  from Case WHERE Id = :msgtoprocess.Related_Message__r.Case__c];

            String s = 'SMS Update received at ' + sDate + ' FROM Existing Caller'; 
                       s += '\n';
                       if (sFinalMessage != null) {
                       s += ' Message: ' + sFinalMessage;
                       }        
           
            FeedComment fc = new FeedComment (
            CreatedById = SMS_Config__c.getValues('Default').SMS_User_Id__c,
            CommentBody = s,
            CommentType = 'TextComment',
            FeedItemId = smscase.SMS_Feed_Id__c);
            insert fc;

            msgtoprocess.Status__c = 'Processed';
            smsmessageupdates.add(msgtoprocess);
            updateSMSMessages(msgtoprocess.Related_Message__r.Case__c);
            }


          else if (msgtoprocess.type__c.equals('UPDATE TO CASE') ) {
       //Find SMS Thread 
            smscase = [Select Id, CaseNumber, SMS_Feed_Id__c  from Case WHERE Id = :msgtoprocess.Matched_Case__c];

            String s = 'SMS Update received at ' + sDate + ' FROM Existing Caller'; 
                       s += '\n';
                       if (sFinalMessage != null) {
                       s += ' Message: ' + sFinalMessage;
                       }        
            
            FeedComment fc = new FeedComment (
            CreatedById = SMS_Config__c.getValues('Default').SMS_User_Id__c,
            CommentBody = s,
            CommentType = 'TextComment',
            FeedItemId = smscase.SMS_Feed_Id__c);
            insert fc;

            FeedItem groupfeeditem = new FeedItem (
            parentId = SMS_Config__c.getValues('Default').SMS_Update_Group_Id__c,
            CreatedById = SMS_Config__c.getValues('Default').SMS_User_Id__c,
            Body = s,
            Title = 'Update to SMS Case Number ' + smscase.caseNumber,// + sid[2],
            LinkURL = '/'+ msgtoprocess.Matched_Case__c,
            Type = 'LinkPost' );
            insert groupfeeditem;

            msgtoprocess.Status__c = 'Processed';
            smsmessageupdates.add(msgtoprocess);
            updateSMSMessages(smscase.Id);
            
      } //end master UPDATE if

  }//end the msg check if
      return bSuccess;
     
}

private void updateChatterforNewCases () {

 List<FeedItem> newfeeditems = new List<FeedItem>();
 
        FeedItem ufgroup = new FeedItem (
            CreatedById = SMS_Config__c.getValues('Default').SMS_User_Id__c,
            parentId = GroupId,
            Body = sFinalMessage,
            Title = 'New SMS Thread',
            LinkURL = '/'+ smscase.Id,
            Type = 'LinkPost' );
    newfeeditems.add(ufgroup);
    
        FeedItem ufcase = new FeedItem (
            CreatedById = SMS_Config__c.getValues('Default').SMS_User_Id__c,
            parentId = smscase.Id,
            Body = sChatterMessage,
            Title = 'New SMS Thread',
            Type = 'TextPost');
    newfeeditems.add(ufcase);
    
    
    List<FeedComment> fc = new List<FeedComment> ();
    fc.add(new FeedComment(
            CreatedById = SMS_Config__c.getValues('Default').SMS_User_Id__c,
            CommentBody = 'Auto Response Sent: ' + sautoresponse,
            CommentType = 'TextComment'));
   
  try {
        insert newfeeditems;
        for (FeedComment fu: fc) {
              fu.FeedItemId = newfeeditems[1].Id;
        }
        
        insert fc;

        //now store the chatter ids (Group and Feed)
        smscase.Group_Chatter_Thread__c = ufgroup.Id;
        smscase.SMS_Feed_Id__c = newfeeditems[1].Id;
        update smscase;
        bSuccess = TRUE;
        }


        catch (Exception Ex) {
          system.debug('### Email Failed' + Ex);    
          bSuccess =  FALSE;  
        }
     
} //end updateChatter

private void updateSMSMessages(Id CaseId) {
for (SMS_Message_Tracking__c s:  smsmessageupdates) {
            s.Matched_Case__c = CaseId;
            s.Case__c = CaseId;
            }
            
            update smsmessageupdates;
}



}