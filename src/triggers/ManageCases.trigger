/*
With reference to Steve Andersen's post:
http://gokubi.com/archives/two-interesting-ways-to-architect-apex-triggers
*/
 
trigger ManageCases on Case (after update) { 

    if(Trigger.isUpdate && Trigger.isAfter){
          ManageCases.afterUpdate(Trigger.new, Trigger.old, Trigger.oldMap);
    }  
     

}