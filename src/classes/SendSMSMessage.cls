public class SendSMSMessage {

public TwilioSms sms {get; private set;}
static TwilioAccount account = TwilioAPI.getDefaultAccount();

public SMS_Message_Tracking__c sendsms(sObject c, String smsmsg, String ToNumber, String fromNumber, Id FeedItemId) {

       Map<String, String> params = new Map<String, String>{
          'From' => fromNumber,
          'To' => ToNumber,
          'Body' => smsmsg,
          'StatusCallback' => SMS_Config__c.getValues('Default').Callback_URL__c
        };
        
        sms = account.getSmsMessages().create(params);
        
        SMS_Message_Tracking__c smstrack = new SMS_Message_Tracking__c();
        smstrack.SID__c = sms.getSid();
        smstrack.Status__c = 'Queued';
        smstrack.Direction__c = 'Outbound';
        smstrack.FROM_Number__c = fromNumber;
        smstrack.Message__c = smsmsg;
        smstrack.TO_Number__c = ToNumber;
        smstrack.Case__c = c.Id;
        insert smstrack; 
        
        if (FeedItemId != null) {
            String s = 'NEW SMS Sent at ' +  system.now().format() + ' FROM Agent'; 
                       s += '\n';
                       s += smsmsg;
                                           
            FeedComment fc = new FeedComment (
            CommentBody = s,
            CommentType = 'TextComment',
            FeedItemId = FeedItemId);
                       
            insert fc;
        }
        
    return smstrack; 
    }
    
    }