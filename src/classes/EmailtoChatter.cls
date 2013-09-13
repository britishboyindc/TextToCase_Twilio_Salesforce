global class EmailtoChatter implements Messaging.InboundEmailHandler {
 
  global Messaging.InboundEmailResult handleInboundEmail(
  Messaging.inboundEmail email, Messaging.InboundEnvelope env){
 
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
  
    ProcessSMStoCase psms = new ProcessSMStoCase();
    result.success = psms.processsms(email.Subject);
    // Return the result for the Apex Email Service 
    
    return result;
  }
}