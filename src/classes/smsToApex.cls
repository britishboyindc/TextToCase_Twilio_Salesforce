/*
 * SmsToNHTRC.cls
 * Example taken from:
 
 *
 */
@RestResource(urlMapping='/smsToApex')
global class smsToApex {
     
    @HttpPost
    global static void incomingSMS() {
        // This will error out with System.LimitException if we would exceed
        // our daily email limit
        Messaging.reserveSingleEmailCapacity(1);

        String expectedSignature = RestContext.request.headers.get('X-Twilio-Signature');
        system.debug('ES' + expectedSignature);
        String url = 'https://' + RestContext.request.headers.get('Host') + '/services/apexrest' + RestContext.request.requestURI;
        Map <String, String> params = RestContext.request.params;
       
        // Validate signature
        if (!TwilioAPI.getDefaultClient().validateRequest(expectedSignature, url, params)) {
            RestContext.response.statusCode = 403;
            RestContext.response.responseBody = Blob.valueOf('Failure! Rcvd '+expectedSignature+'\nURL '+url/*+'\nHeaders'+RestContext.request.headers*/);
            
            return;
        }
        
        // Twilio likes to see something in the response body, otherwise it reports
        // a 502 error in https://www.twilio.com/user/account/log/notifications
        RestContext.response.responseBody = Blob.valueOf('ok');
                
        processInboundSMS2 smsI = new processInboundSMS2();
        smsI.process(params);
        
     }
}