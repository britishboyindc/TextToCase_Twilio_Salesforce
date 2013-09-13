Public Class SMSUtilities {

public static String formatphonenumber(String cphone) {
String fphone = cphone.replaceAll('\\D','');

if (fphone.length() == 10) {
fphone = formatphonenum(fphone);
return fphone;
}
else {
return cphone;
}

}

static String formatphonenum (String s) {
s = '(' + s.substring(0, 3) + ') ' + s.substring(3, 6) + '-' + s.substring(6);
return s;
}

public static String removeformatphonenumber(String cphone) {
return cphone.replaceAll('\\D','');
}

public static String getAutoReponse (String stype) {

       Map<String, SMS_Responses__c> smsresponses = SMS_Responses__c.getAll();
                        
            String sresponse = smsresponses.get('DEFAULT').Message__c;
                        
                        //But if they used a short code we recognize
                if (smsresponses.containskey(stype)) {
                    sresponse = smsresponses.get(stype).Message__c;
                }
    return sresponse;
}

public static case createNewSMSCase (SMS_Message_Tracking__c sms) {
Case c = new Case ();
 //Case__r.ContactId,
c.SMS_To_Number__c = sms.TO_Number__c;
c.Origin = 'SMS';
return c; 
}    

public static Contact setupNewSMSCaller (String sPhone) {
        String sPhoneSearch = SMSUtilities.formatphonenumber(sPhone.removeStart('1'));
        //Search for Contact by Phone
        Contact [] cons = SMSUtilities.SearchviaSOSL(sPhoneSearch);

        if (cons.size() > 0) {
        return cons[0];  
        }
        else {
        Contact con = new Contact();
        con.LastName = 'Unknown';
        con.Phone = sPhoneSearch;
        con.MobilePhone = sPhoneSearch;
        return con;
        }  
} //end set up con


public Static List<Contact> SearchviaSOSL (String sText) {
List<Contact> searchresults = new List<Contact> ();

if (sText.length() > 1) {
    String myString1 = string.escapeSingleQuotes(sText) + '*';
    List<List<SObject>> searchList = [FIND :myString1 IN ALL FIELDS RETURNING Contact];
    Contact [] cons = ((List<Contact>)searchList[0]);
    return cons;
}
else {
    return null;
}
}

} //end class