/*
Copyright (c) 2012 Twilio, Inc.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
@isTest
private class Twilio_TestSms 
{

final static String authToken = '12345678901234567890123456789012';
    static testmethod void testTwilioSMSList_get_filter() {
        string accountJsonResponseBody='{"page": 0,"num_pages": 1,"page_size": 50,"total": 10,"start": 0,"end": 9,'
        +'"uri": "/2010-04-01/Accounts/ACdc5f1e6f7a0441659833ca940b72503d/SMS/ShortCodes.json",'
        +'"first_page_uri": "/2010-04-01/Accounts/ACdc5f1e6f7a0441659833ca940b72503d/SMS/ShortCodes.json?Page=0&PageSize=50",'
        +'"previous_page_uri": null,'
        +'"next_page_uri": null,'
        +'"last_page_uri": "/2010-04-01/Accounts/ACdc5f1e6f7a0441659833ca940b72503d/SMS/ShortCodes.json?Page=0&PageSize=50",'
        +'"sms_messages": [{'
        +'"account_sid": "AC03c2fcd60e144e7cbeee413fcbf812a3",'
        +'"api_version": "2008-08-01",'
        +'"body": "Hey Jenny why aren\'t you returning my calls?",'
        +'"date_created": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"date_sent": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"date_updated": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"direction": "outbound-api",'
        +'"from": "+14158141829",'
        +'"price": "-0.02000",'
        +'"sid": "SM800f449d0399ed014aae2bcc0cc2f2ec",'
        +'"status": "sent",'
        +'"to": "+14159978453",'
        +'"uri": "/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages/SM800f449d0399ed014aae2bcc0cc2f2ec.json"'
        +'}]}';
        Twilio_TestHTTPMock.getInstance().putResponse(
            'GET',
            'https://api.twilio.com/2010-04-01/Accounts/AC03c2fcd60e144e7cbeee413fcbf812a3/SMS/Messages.json',
            new Twilio_TestHTTPMock.Response(accountJsonResponseBody,200)
            );
        
        map<string,string> params=new map<string,string>();
        params.put('to','+14159978453');
        // Get an API client and request the Twilio Account
        TwilioRestClient client = new TwilioRestClient('AC03c2fcd60e144e7cbeee413fcbf812a3', authToken);
        Twiliosmslist tsmslist = client.getAccount().getSmsMessages();
        List<Twiliosms> tsms=tsmslist.getpagedata();
        system.assertEquals(1,tsms.size());
        
        Twiliosms sms=tsms.get(0);
        System.assertEquals('SM800f449d0399ed014aae2bcc0cc2f2ec', sms.getsid());
        System.assertEquals('AC03c2fcd60e144e7cbeee413fcbf812a3', sms.getaccountsid());
        System.assertEquals('+14159978453',sms.getto());
        System.assertEquals('+14158141829',sms.getfrom());
        System.assertEquals('Hey Jenny why aren\'t you returning my calls?',sms.getbody());
        System.assertEquals('sent',sms.getStatus());
        System.assertEquals('-0.02000',sms.getPrice());
        System.assertEquals('outbound-api',sms.getDirection());
        System.assertEquals('2008-08-01',sms.getApiVersion());
        System.assertEquals(Datetime.newInstanceGmt(2012,2,1,10,49,17),sms.getDateCreated());
        System.assertEquals(Datetime.newInstanceGmt(2012,2,1,10,49,17),sms.getDateUpdated());
        System.assertEquals(Datetime.newInstanceGmt(2012,2,1,10,49,17),sms.getDatesent());
        
        Twilio_TestHTTPMock.getInstance().putResponse(
            'GET',
            'https://api.twilio.com/2010-04-01/Accounts/AC03c2fcd60e144e7cbeee413fcbf812a3/SMS/Messages.json?to=%2B14159978453',
            new Twilio_TestHTTPMock.Response(accountJsonResponseBody,200)
            );
        
        tsmslist = client.getAccount().getSmsMessages(params);
        
        Iterator<Twiliosms> it = tsmslist.iterator();
        System.assertEquals(true, it.hasNext());
        
        sms=it.next();      
        
        System.assertEquals('SM800f449d0399ed014aae2bcc0cc2f2ec', sms.getsid());
        System.assertEquals('AC03c2fcd60e144e7cbeee413fcbf812a3', sms.getaccountsid());
        System.assertEquals('+14159978453',sms.getto());
        System.assertEquals('+14158141829',sms.getfrom());
        System.assertEquals('Hey Jenny why aren\'t you returning my calls?',sms.getbody());
        System.assertEquals('sent',sms.getStatus());
        System.assertEquals('-0.02000',sms.getPrice());
        System.assertEquals('outbound-api',sms.getDirection());
        System.assertEquals('2008-08-01',sms.getApiVersion());
        System.assertEquals(Datetime.newInstanceGmt(2012,2,1,10,49,17),sms.getDateCreated());
        System.assertEquals(Datetime.newInstanceGmt(2012,2,1,10,49,17),sms.getDateUpdated());
        System.assertEquals(Datetime.newInstanceGmt(2012,2,1,10,49,17),sms.getDatesent());
        System.assertEquals(false, it.hasNext());
    }

    static testmethod void testTwilioSMS_send() {
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
        
        
        // Get an API client and request the Twilio Account
        TwilioRestClient client = new TwilioRestClient('AC03c2fcd60e144e7cbeee413fcbf812a3', authToken);
        Map<String,String>  params=new Map<String,String>();
        params.put('From','+919902400323' );
        params.put('To', '+919902400323');
        params.put('Body', 'Test sending sms from twilio');
        Twiliosms sms= client.getAccount().getSMSMessages().create(params);
        
        System.assertEquals('SM800f449d0399ed014aae2bcc0cc2f2ec', sms.getsid());
        System.assertEquals('AC03c2fcd60e144e7cbeee413fcbf812a3', sms.getaccountsid());
        System.assertEquals('+14159978453',sms.getto());
        System.assertEquals('+14158141829',sms.getfrom());
        System.assertEquals('Test sending sms from twilio',sms.getbody());
        System.assertEquals('queued',sms.getStatus());
        System.assertEquals('-0.02000',sms.getPrice());
        System.assertEquals('outbound-api',sms.getDirection());
        System.assertEquals('2008-08-01',sms.getApiVersion());
        System.assertEquals(Datetime.newInstanceGmt(2012,2,1,10,49,17),sms.getDateCreated());
        System.assertEquals(Datetime.newInstanceGmt(2012,2,1,10,49,17),sms.getDateUpdated());
        System.assertEquals(Datetime.newInstanceGmt(2012,2,1,10,49,17),sms.getDatesent());
    }
    
    static testmethod void testTwilioSMS_get() {
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
            'GET',
            'https://api.twilio.com/2010-04-01/Accounts/AC03c2fcd60e144e7cbeee413fcbf812a3/SMS/Messages/SM800f449d0399ed014aae2bcc0cc2f2ec.json',
            new Twilio_TestHTTPMock.Response(accountJsonResponseBody,200)
            );
        
        
        // Get an API client and request the Twilio Account
        TwilioRestClient client = new TwilioRestClient('AC03c2fcd60e144e7cbeee413fcbf812a3', authToken);        
        Twiliosms sms= client.getAccount().getsms('SM800f449d0399ed014aae2bcc0cc2f2ec');
        
        System.assertEquals('SM800f449d0399ed014aae2bcc0cc2f2ec', sms.getsid());
        System.assertEquals('AC03c2fcd60e144e7cbeee413fcbf812a3', sms.getaccountsid());
        System.assertEquals('+14159978453',sms.getto());
        System.assertEquals('+14158141829',sms.getfrom());
        System.assertEquals('Test sending sms from twilio',sms.getbody());
        System.assertEquals('queued',sms.getStatus());
        System.assertEquals('-0.02000',sms.getPrice());
        System.assertEquals('outbound-api',sms.getDirection());
        System.assertEquals('2008-08-01',sms.getApiVersion());
        System.assertEquals(Datetime.newInstanceGmt(2012,2,1,10,49,17),sms.getDateCreated());
        System.assertEquals(Datetime.newInstanceGmt(2012,2,1,10,49,17),sms.getDateUpdated());
        System.assertEquals(Datetime.newInstanceGmt(2012,2,1,10,49,17),sms.getDatesent());

    }
    
    }