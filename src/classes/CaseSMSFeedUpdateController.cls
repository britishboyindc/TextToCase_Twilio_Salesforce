public with sharing class CaseSMSFeedUpdateController {

private final case scase;

private CaseFeed originalfeeditem;
private FeedItem casefeeditem;
private Boolean bDeleteExistingComments;

public List<CaseFeedFix> casefeeddata {get;set;}

private String initialFeedComment;

public Integer iCommentUp {get;set;} 


    public caseSMSFeedUpdateController(ApexPages.StandardController stdController) {
        this.scase = (Case)stdController.getRecord();
        getCurrentFeedData();
        bDeleteExistingComments = TRUE;
    }


public pagereference moveCommentUp() {

CaseFeedFix cup = casefeeddata[iCommentUp-1];
CaseFeedFix cdown = casefeeddata[iCommentUp-2];

cup.iOrder --;
cdown.iOrder ++;

casefeeddata[iCommentUp-2] = cup;
casefeeddata[iCommentUp-1] = cdown;


return null;

}

public pagereference mergeCommentUp() {

CaseFeedFix cmremove = casefeeddata[iCommentUp-1];
CaseFeedFix cmstay = casefeeddata[iCommentUp-2];

String sCommentToAdd = cmremove.Comment.substringAfterLast(':');
cmstay.Comment += sCommentToAdd;

casefeeddata.remove(iCommentUp-1);

//Now we need to update order of any rows below deleted row...

        for (Integer j = iCommentUp-1; j < casefeeddata.size(); j++) {
 
                casefeeddata[j].iOrder --;
            }



return null;

}


public pagereference getCurrentFeedData() {
       
    casefeeddata = new List<CaseFeedFix> ();

    List<CaseFeed> smscasefeed = [
                SELECT ID, CreatedDate, ParentId, Body,
                    (Select CommentBody from FeedComments ORDER BY CreatedDate Asc)
                    FROM CaseFeed 
                    WHERE ParentId = :scase.Id AND Id = :scase.SMS_Feed_Id__c 
                    ORDER BY CreatedDate Asc];

                    if (smscasefeed.size() > 0) {
                        originalfeeditem = smscasefeed[0];

                        casefeeddata.add(new CaseFeedFix (1,originalfeeditem.Body)  );
                        initialFeedComment = originalfeeditem.body;
                                    
                        Integer ic = 2;
                    
                      for (FeedComment fc: originalfeeditem.FeedComments) {
                            if (fc.CommentBody != null) {
                                casefeeddata.add(new CaseFeedFix (ic,fc.CommentBody)  );
                                ic ++;  
                            }
                        }
                    }                  
return null;
}    


public pageReference updateFeed () {

Id FeedItemId;
//Is the First Post the same?
    if (initialFeedComment != casefeeddata[0].Comment) {
        
        //Can't Update a Feed Item so we'll create a new one
            FeedItem ufcase = new FeedItem (
            CreatedById = SMS_Config__c.getValues('Default').SMS_User_Id__c,
            parentId = scase.Id,
            Body = casefeeddata[0].Comment,
            Title = 'New SMS Thread',
            Type = 'TextPost');
            insert ufcase;
            FeedItemId = ufcase.Id;
        
            delete originalfeeditem;
            bDeleteExistingComments = FALSE;


    }
    else {
            FeedItemId = originalfeeditem.Id;
    }
        //Just delete comments and recreate
        List<FeedComment> newFC = new List<FeedComment> ();

        for (Integer j = 1; j < casefeeddata.size(); j++) {
 
                            FeedComment fc = new FeedComment (
                            CreatedById = SMS_Config__c.getValues('Default').SMS_User_Id__c,
                            CommentBody = casefeeddata[j].Comment,
                            CommentType = 'TextComment',
                            FeedItemId = FeedItemId);
                            newFC.add(fc);
            }
            
            insert newFC;   
            
            if (bDeleteExistingComments) {
                delete originalfeeditem.FeedComments;
            }

            scase.SMS_Feed_Id__c = FeedItemId;
            update scase;

            //return new ApexPages.StandardController(scase).view();
            //return new pageReference('/'+scase.Id);
        
            return null;

    
return null;
}

public class CaseFeedFix {

public Integer iOrder {get;set;}
public Integer newiOrder {get;set;}
public String Comment {get;set;}
public Boolean bDelete {get;set;}
public Boolean bMerge {get;set;}


    public  CaseFeedFix(Integer i, String sComment) {
        iOrder = i;
        newiOrder = i;
        Comment = sComment;
        bDelete = FALSE;
        bMerge = FALSE;
      }

    }



}