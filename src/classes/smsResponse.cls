@RestResource(urlMapping='/smsResponse')
global class smsResponse {
     
    @HttpPost
    global static void incomingSMSResponse() {
   
        String expectedSignature = RestContext.request.headers.get('X-Twilio-Signature');
        String url = 'https://' + RestContext.request.headers.get('Host') + '/services/apexrest' + RestContext.request.requestURI;
        Map <String, String> params = RestContext.request.params;
        system.debug('Return Response' + params);

       // Validate signature
      
        if (!TwilioAPI.getDefaultClient().validateRequest(expectedSignature, url, params)) {
            RestContext.response.statusCode = 403;
            RestContext.response.responseBody = Blob.valueOf('Failure! Rcvd '+expectedSignature+'\nURL '+url+'\nHeaders'+RestContext.request.headers);
            return;
        }
        
        //search for case where message sent from
        system.debug('Sid' + params.get('SmsSid'));
        system.debug('Status' + params.get('SmsStatus'));

        SMS_Message_Tracking__c smstrack = new SMS_Message_Tracking__c();
        smstrack.SID__c = params.get('SmsSid');
        smstrack.Status__c = params.get('SmsStatus');

        upsert smstrack SID__c;

        //SMS_Message_Status__c
        
     }
}