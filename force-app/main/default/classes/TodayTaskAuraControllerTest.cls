@isTest(SeeAllData=true)
public class TodayTaskAuraControllerTest {

    @isTest
    public static void createVisitActivityTest(){
        
        List<Visit__c> getAllvisitRecordList = new List<Visit__c>();
        
        Account accRec = new Account();
        accRec.Name = 'Test FSL';
        accRec.BillingStreet = 'JP nagar';
        accRec.BillingCity = 'Bangalore';
        accRec.SAP_Update_Customer__c = true;
        insert accRec;
        
        Opportunity oppRec = new Opportunity();
        oppRec.Name = 'Test Opp';
        oppRec.CloseDate = system.today();
        oppRec.CurrencyIsoCode = 'INR';
        oppRec.Annual_Volume_Full__c = 12.01;
        oppRec.Annual_Volume_in_units__c = 'Kg';
        oppRec.End_Use_Category__c = 'Beverages';
        oppRec.End_Use_Application__c = 'Beer';
        oppRec.Target_Price_Kg__c = 30;
        oppRec.AccountId = accRec.Id;
        oppRec.StageName = 'New';
        insert oppRec;
        
        Task taskRec = new Task();
        taskRec.Subject = 'Test';
        insert taskRec;
        
        Case caseRec = new Case();
        caseRec.Subject = 'Testing Subject Case';
        caseRec.Status = 'New';
        caseRec.Origin = 'Email';
        caseRec.Description = 'Test Description';
        insert caseRec;
        
        Roles_and_KPI__c roleKpiRec = new Roles_and_KPI__c();
        roleKpiRec.Name = 'Test Role and Kpi';
        insert roleKpiRec;
        
        KPI_Target__c kpiTarRec = new KPI_Target__c();
        kpiTarRec.Roles_and_KPI__c = roleKpiRec.Id;
        insert kpiTarRec;
        
        Visit__c visirtRec = new Visit__c();
        visirtRec.Actual_visit_date__c = System.today();
        visirtRec.KPI_Target__c = kpiTarRec.Id;
        visirtRec.Account__c = accRec.Id;
        visirtRec.Planned_visit_date__c = system.today();
        visirtRec.Assigned_User__c = UserInfo.getUserId();
        insert visirtRec;
        getAllvisitRecordList.add(visirtRec);
        
        Monthly_Travel_Expense__c mteRec = new Monthly_Travel_Expense__c();
        mteRec.Name = 'Test';
        insert mteRec;
        
        Day_Visit_Plan__c dvpRec= new Day_Visit_Plan__c();
        dvpRec.Start_Date__c= System.today();
        dvpRec.Monthly_Travel_Expense__c= mteRec.Id;
        dvpRec.End_Location__Latitude__s = 12.890992;
        dvpRec.End_Location__Longitude__s = 77.570802;
        insert dvpRec;
        
        TodayTaskAuraController.createVisitActivity(oppRec.Id,visirtRec.Id);
        TodayTaskAuraController.getAllVisitTodays('11-11-2023');
        TodayTaskAuraController.getSelectedVisitDetails(visirtRec.Id);
        TodayTaskAuraController.StartDayVisitForVistitRecord('12.890992','77.570802',getAllvisitRecordList);
        TodayTaskAuraController.updateEndDayVisitRecord('12.890992','77.570802');
        TodayTaskAuraController.updateAmendVisitRecord(visirtRec);
        TodayTaskAuraController.saveTask(taskRec);
        TodayTaskAuraController.LogCall(taskRec);
        TodayTaskAuraController.saveOpportunity(oppRec);
        TodayTaskAuraController.saveCase(caseRec);
    }
}