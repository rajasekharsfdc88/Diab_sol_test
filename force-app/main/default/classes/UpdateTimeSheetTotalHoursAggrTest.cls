@isTest
public class UpdateTimeSheetTotalHoursAggrTest {
    
    @TestSetup
    public static void testData(){
        
        createData(1);
        createData(2);
        
    }
    
    public static void   createData(Integer count){
        Project__c proj = new Project__c();
        proj.Name='Diab Salesforce Project'+count;
        
        insert proj ;
        
        Timesheet__c tc1 = new Timesheet__c();
        tc1.name = 'raj NB'+count;
        tc1.Project__c = proj.Id;
        tc1.Billable__c=false;
        tc1.Hours__c=5+count;        
        insert tc1;
        
        Timesheet__c tc3 = new Timesheet__c();
        tc3.name = 'raj NB-2-'+count;
        tc3.Project__c = proj.Id;
        tc3.Billable__c=false;
        tc3.Hours__c=5+count;        
        insert tc3;
        
        Timesheet__c tc2 = new Timesheet__c();
        tc2.name = 'raj B';
        tc2.Project__c = proj.Id;
        tc2.Billable__c=true;
        tc2.Hours__c=3+count;        
        insert tc2;
        
    }
    
    @isTest
    public static void  test_TimesheetInsert(){
        List<Project__c> lstproj =[Select Id ,Total_Billable_Hours__c,Total_Non_Billable_Hours__c from project__c];
        Assert.areEqual(2, lstproj.size());
        
        Project__c proj1 =[Select Id ,Total_Billable_Hours__c,Total_Non_Billable_Hours__c from project__c where name = 'Diab Salesforce Project1' limit 1];
        Assert.areEqual(4, proj1.Total_Billable_Hours__c);
        Assert.areEqual(12, proj1.Total_Non_Billable_Hours__c);
        
    }
    
    
    @isTest
    public static void  test_TimesheetDelete(){
        
        System.debug('---------test_TimesheetDelete Start---------------');
        Project__c proj1 =[Select Id ,Total_Billable_Hours__c,Total_Non_Billable_Hours__c from project__c where name = 'Diab Salesforce Project1' limit 1];
        
        List< Timesheet__c> tsList =[Select Id ,name,Hours__c,Billable__c,project__c from Timesheet__c where project__c =: proj1.Id ];
        
        Test.startTest();
        
        delete tsList;
        
        Test.stopTest();
        
        Project__c proj2 =[Select Id ,Total_Billable_Hours__c,Total_Non_Billable_Hours__c from project__c where id=: proj1.Id limit 1];
        Assert.areEqual(0, proj2.Total_Billable_Hours__c);
        Assert.areEqual(0, proj2.Total_Non_Billable_Hours__c);
        List< Timesheet__c> tsList2 =[Select Id ,name,Hours__c,Billable__c,project__c from Timesheet__c where project__c =: proj1.Id ];
       Assert.areEqual(0, tsList2.size());
      
      
        System.debug('---------test_TimesheetDelete End---------------');
    }
    
}