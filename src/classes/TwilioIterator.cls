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
global class TwilioIterator {

    /**
     * The Class ObjectIteratorSupport
     */
    global abstract class ObjectIteratorSupport {

        /** The itr. */
        private Iterator<Object> itr;
        
        private TwilioResource.ListResource twlist;

        protected ObjectIteratorSupport(TwilioResource.ListResource twlist) {
            this.itr = twlist.getObjectPageData().iterator();
            this.twlist = twlist;
        }

        global boolean hasNext() {
            return itr.hasNext() || twlist.hasNextPage();
        }

        protected Object getNext() {
            // If we still have results on this page
            if (itr.hasNext()) {
                return itr.next();
            }

            // Otherwise fetch the next page
            twlist.fetchNextPage();
            
            itr = twlist.getObjectPageData().iterator();
            return itr.next();
        }
    }
    
    
     
    global class SmsIterator extends ObjectIteratorSupport implements Iterator<TwilioSms> {
        global SmsIterator(TwilioSmsList twlist) {
            super(twlist);
        }
        
        global TwilioSms next() {
            return (TwilioSms)getNext(); 
        }
    }
    
    
    global class TwilioUnsupportedOperationException extends Exception {}
}