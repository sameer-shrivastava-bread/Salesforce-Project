@isTest
public class ProjectTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test projects with different statuses
        List<Project__c> testProjects = new List<Project__c>();
        
        testProjects.add(new Project__c(
            Name = 'Test Project 1',
            Project_Code__c = 'TP001',
            Status__c = 'Planned*',  // Fixed: Changed from 'Planned' to 'Planned*'
            Budget__c = 10000.00
        ));
        
        testProjects.add(new Project__c(
            Name = 'Test Project 2',
            Project_Code__c = 'TP002',
            Status__c = 'In Progress',
            Budget__c = 15000.00
        ));
        
        insert testProjects;
    }
    
    @isTest
    static void testBeforeInsert_StatusInProgress() {
        Test.startTest();
        
        Project__c project = new Project__c(
            Name = 'New In Progress Project',
            Project_Code__c = 'NIP001',
            Status__c = 'In Progress',
            Budget__c = 5000.00
        );
        
        insert project;
        
        Test.stopTest();
        
        // Verify Start Date was set
        Project__c insertedProject = [SELECT Id, Start_Date__c FROM Project__c WHERE Id = :project.Id];
        System.assertEquals(Date.today(), insertedProject.Start_Date__c, 'Start Date should be set to today');
    }
    
    @isTest
    static void testBeforeInsert_StatusCompleted() {
        Test.startTest();
        
        Project__c project = new Project__c(
            Name = 'New Completed Project',
            Project_Code__c = 'NCP001',
            Status__c = 'Completed',
            Budget__c = 8000.00,
            Start_Date__c = Date.today().addDays(-30)
        );
        
        insert project;
        
        Test.stopTest();
        
        // Verify End Date was set
        Project__c insertedProject = [SELECT Id, End_Date__c FROM Project__c WHERE Id = :project.Id];
        System.assertEquals(Date.today(), insertedProject.End_Date__c, 'End Date should be set to today');
    }
    
    @isTest
    static void testBeforeUpdate_StatusChangeToInProgress() {
        Test.startTest();
        
        Project__c project = [SELECT Id, Status__c, Start_Date__c FROM Project__c WHERE Project_Code__c = 'TP001' LIMIT 1];
        project.Status__c = 'In Progress';
        
        update project;
        
        Test.stopTest();
        
        // Verify Start Date was set
        Project__c updatedProject = [SELECT Id, Start_Date__c FROM Project__c WHERE Id = :project.Id];
        System.assertEquals(Date.today(), updatedProject.Start_Date__c, 'Start Date should be set when status changes to In Progress');
    }
    
    @isTest
    static void testBeforeUpdate_StatusChangeToCompleted() {
        Test.startTest();
        
        Project__c project = [SELECT Id, Status__c, End_Date__c FROM Project__c WHERE Project_Code__c = 'TP002' LIMIT 1];
        project.Status__c = 'Completed';
        
        update project;
        
        Test.stopTest();
        
        // Verify End Date was set
        Project__c updatedProject = [SELECT Id, End_Date__c FROM Project__c WHERE Id = :project.Id];
        System.assertEquals(Date.today(), updatedProject.End_Date__c, 'End Date should be set when status changes to Completed');
    }
    
    @isTest
    static void testBeforeUpdate_StatusChangeFromCompleted() {
        // First create a completed project
        Project__c project = new Project__c(
            Name = 'Completed Project',
            Project_Code__c = 'CP001',
            Status__c = 'Completed',
            Budget__c = 12000.00,
            Start_Date__c = Date.today().addDays(-30),
            End_Date__c = Date.today().addDays(-5)
        );
        insert project;
        
        Test.startTest();
        
        // Change status from Completed to In Progress
        project.Status__c = 'In Progress';
        update project;
        
        Test.stopTest();
        
        // Verify End Date was cleared
        Project__c updatedProject = [SELECT Id, End_Date__c FROM Project__c WHERE Id = :project.Id];
        System.assertEquals(null, updatedProject.End_Date__c, 'End Date should be cleared when status changes from Completed');
    }
    
    @isTest
    static void testNoDateChangeWhenAlreadySet() {
        Date customStartDate = Date.today().addDays(-10);
        
        Test.startTest();
        
        Project__c project = new Project__c(
            Name = 'Project with Existing Date',
            Project_Code__c = 'PED001',
            Status__c = 'In Progress',
            Budget__c = 7000.00,
            Start_Date__c = customStartDate
        );
        
        insert project;
        
        Test.stopTest();
        
        // Verify Start Date was not overwritten
        Project__c insertedProject = [SELECT Id, Start_Date__c FROM Project__c WHERE Id = :project.Id];
        System.assertEquals(customStartDate, insertedProject.Start_Date__c, 'Existing Start Date should not be overwritten');
    }
}