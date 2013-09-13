public class ManageCases {
/* With reference to Steve Andersen's post: http://gokubi.com/archives/two-interesting-ways-to-architect-apex-triggers */ 


public static void afterUpdate(Case [] newCases, Case [] oldCases, Map<Id, Case> oldCaseMap) {

List<FeedItem> fitems = new List<FeedItem> ();

for (Case c: newCases) {

if (c.OwnerId != oldCaseMap.get(c.Id).OwnerId) {

  if (c.Group_Chatter_Thread__c != null) {
    fitems.add(new FeedItem(Id = c.Group_Chatter_Thread__c));
  }

}

}
delete fitems;
}

}