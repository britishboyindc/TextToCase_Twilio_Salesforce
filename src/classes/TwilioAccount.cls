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
/*
 * The Account class, representing a Twilio customer account.
 * For more information see http://www.twilio.com/docs/api/rest/account
 */
global class TwilioAccount extends TwilioResource.InstanceResource {

    /* property keys */
    private static final String DATE_UPDATED_PROPERTY = 'date_updated';
    private static final String DATE_CREATED_PROPERTY = 'date_created';
    private static final String STATUS_PROPERTY = 'status';
    private static final String FRIENDLY_NAME_PROPERTY = 'friendly_name';
    private static final String ACCOUNT_SID_PROPERTY = 'sid';
    private static final String AUTH_TOKEN_PROPERTY = 'auth_token';
    private static final String TYPE_PROPERTY = 'type';
    private static final String OWNER_ACCOUNT_SID_PROPERTY = 'owner_account_sid';
    private static final String CONNECT_APP_SID_PROPERTY = 'connect_app_sid';

    /* Constructor */
    public TwilioAccount(TwilioRestClient client) {
        super(client);
    }

    /* Constructor, using predefined set of property values */
   /*
    public TwilioAccount(TwilioRestClient client, Map<String, Object> properties) {
        super(client, properties);
        Object ac = properties.get(ACCOUNT_SID_PROPERTY);
        if (ac != null && ac instanceof String) {
            String accountSid = (String) ac;
            this.setRequestAccountSid(accountSid);
        }
    }
    */

    /* Sid field accessor */
    public String getSid() {
        if (this.getRequestAccountSid() != null)
            return this.getRequestAccountSid();
        else
            return this.getProperty(ACCOUNT_SID_PROPERTY);
    }

    /* Sid field accessor */
    public void setSid(String accountSid) {
        this.setRequestAccountSid(accountSid);
        this.setProperty(ACCOUNT_SID_PROPERTY, accountSid);
        
    }
    
    /** Returns the sid for the ConnectApp using this Account */
  /*
    public String getConnectAppSid() {
        return this.getProperty(CONNECT_APP_SID_PROPERTY);
    }
  */
    
    /** Returns the AccountSid of the primary account */
    public String getOwnerAccountSid() {
        return this.getProperty(OWNER_ACCOUNT_SID_PROPERTY);
    }

    /** Returns the API auth token (secret) for this account */
    public String getAuthToken() {
        return this.getProperty(AUTH_TOKEN_PROPERTY);
    }

    /** Sets the API auth token (secret) for this account */
    public void setAuthToken(String authToken) {
        this.setProperty(AUTH_TOKEN_PROPERTY, authToken);
    }

    /** Returns the human-readable label for this account */
    public String getFriendlyName() {
        return this.getProperty(FRIENDLY_NAME_PROPERTY);
    }

    /** Returns the status value for this account */
    public String getStatus() {
        return this.getProperty(STATUS_PROPERTY);
    }

    /** Returns the date and time this account was created */
    public Datetime getDateCreated() {
        return this.getPropertyDatetime(DATE_CREATED_PROPERTY);
    }

    /** Returns the date and time this account was last updated */
    public Datetime getDateUpdated() {
        return this.getPropertyDatetime(DATE_UPDATED_PROPERTY);
    }
     
    /** Returns the account type */
    public String getType() {
        return this.getProperty(TYPE_PROPERTY);
    }
    
    /** Return the Twilio URI for this resource. */
    public String getUri() {
        return this.getProperty('uri');
    }
    
    /** Returns the URIs for resources under this account */
    public Map<String,Object> getSubresourceUris() {
        return (Map<String,Object>)this.getObject('subresource_uris');
    }

    /** Constructs a Twilio API resource URI for this Account. Overrides method from TwilioResource. */
    public override String getResourceLocation() {
        return '/' + TwilioRestClient.DEFAULT_VERSION + '/Accounts/'
                + this.getRequestAccountSid() + '.json';
    }


    /**
     * Returns the sms message list.
     * See http://www.twilio.com/docs/api/rest/sms
     */
    public TwilioSmsList getSmsMessages() {
        return this.getSmsMessages(new Map<String, String>());
    }

    /**
     * Returns the SMS messages list, applying the supplied filters.
     * See http://www.twilio.com/docs/api/rest/sms
     */
    public TwilioSmsList getSmsMessages(Map<String, String> filters) {
        TwilioSmsList sms = new TwilioSmsList(this.getClient(), filters);
        sms.setRequestAccountSid(this.getRequestAccountSid());

        return sms;
    }
    
    /** Returns a given SMS message by sid */
    public TwilioSms getSms(String sid) {
        TwilioSms sms = new TwilioSms(this.getClient(), sid);
        sms.setRequestAccountSid(this.getRequestAccountSid());
        return sms;
    }
    
   
}