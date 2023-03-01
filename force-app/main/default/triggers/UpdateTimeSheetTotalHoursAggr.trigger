trigger UpdateTimeSheetTotalHoursAggr on Timesheet__c (after insert, after update, after delete,after undelete) {
    
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
          Set<Id> projectIds = new Set<Id>();
   		  Map<Id,Project__c> projectsToUpdateMap = new Map<Id,Project__c>();  
        for (Timesheet__c ts : Trigger.new) {
            projectIds.add(ts.Project__c);
        }
        //Grouping  results using project and Billable(true/false)
        for (AggregateResult ar : [SELECT Project__c,Billable__c, SUM(Hours__c) totalHours
                                   FROM Timesheet__c
                                   WHERE Project__c IN :projectIds 
                                   GROUP BY Project__c,Billable__c]){
                                       //put results in map so that we can always have unqiue project in map         
                                       if(projectsToUpdateMap.containsKey((Id)ar.get('Project__c')))  {
                                           Project__c proj = projectsToUpdateMap.get((Id)ar.get('Project__c'));
                                           if((Boolean)ar.get('Billable__c')){
                                               proj.Total_Billable_Hours__c = (Decimal)ar.get('totalHours');
                                           }else{
                                               proj.Total_Non_Billable_Hours__c = (Decimal)ar.get('totalHours');
                                           }
                                           projectsToUpdateMap.put((Id)ar.get('Project__c'),proj); 
                                           
                                       }  else{
                                           Project__c proj = new Project__c(Id = (Id)ar.get('Project__c'));
                                           if((Boolean)ar.get('Billable__c')){
                                               proj.Total_Billable_Hours__c = (Decimal)ar.get('totalHours');
                                           }else{
                                               proj.Total_Non_Billable_Hours__c = (Decimal)ar.get('totalHours');
                                           }
                                           projectsToUpdateMap.put((Id)ar.get('Project__c'),proj);
                                       }                                                   
                                   }
        update projectsToUpdateMap.values();
    } else if (Trigger.isDelete) {
        System.debug('------------Trigger.isDelete-------------------------------'+Trigger.isDelete);
        Map<Id,List<Timesheet__c>> projectTSToDeleteMap = new Map<Id,List<Timesheet__c>>();
        for (Timesheet__c ts : Trigger.old) {
            if(projectTSToDeleteMap.containsKey(ts.Project__c))  {
                List<Timesheet__c> tsList = projectTSToDeleteMap.get(ts.Project__c);
                tsList.add(ts);
                projectTSToDeleteMap.put(ts.Project__c,tsList);
            }else{
                List<Timesheet__c> tsList = new List<Timesheet__c>();
                tsList.add(ts);
                projectTSToDeleteMap.put(ts.Project__c,tsList);
            }
            
        }
        
        List< Project__c > projList =[Select Id ,Total_Billable_Hours__c,Total_Non_Billable_Hours__c from project__c where id in : projectTSToDeleteMap.keySet()];
        
        for(Project__c proj : projList){
            List<Timesheet__c> tsList =    projectTSToDeleteMap.get(proj.id);
            for(Timesheet__c ts : tsList){
                if(ts.Billable__c){
                    proj.Total_Billable_Hours__c =proj.Total_Billable_Hours__c - ts.Hours__c;
                }else{
                    proj.Total_Non_Billable_Hours__c =proj.Total_Non_Billable_Hours__c - ts.Hours__c;
                }
            }
        }
        
        update projList;
    }
    
    
}