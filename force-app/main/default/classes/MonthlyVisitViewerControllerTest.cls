@IsTest(SeeAllData=true)
public class MonthlyVisitViewerControllerTest {
    
    @isTest
    public static void fetchPageDataTest() {
        
        List<Visit__c> getAllvisitRecordList = new List<Visit__c>();
        List<Monthly_Beat_Plan__c> mbpRecList = new List<Monthly_Beat_Plan__c>();
        List<String> routeList = new List<String>();
        List<Assignment_Group_Member__c> asigGroupMemberRecList = new List<Assignment_Group_Member__c>();
        
        Location__c locaRec = new Location__c();
        locaRec.Name = 'Test Location';
        insert locaRec;
        
        Account accRec = new Account();
        accRec.Name = 'Test FSL';
        accRec.BillingStreet = 'JP nagar';
        accRec.BillingCity = 'Bangalore';
        accRec.SAP_Update_Customer__c = true;
        //accRec.Location__c = locaRec.Id;
        insert accRec;
        
        Contact conRec = new Contact();
        conRec.LastName = 'test Contact';
        conRec.CurrencyIsoCode = 'INR';
        conRec.Email = 'Test@email.com';
		conRec.Phone = '928468939';
        conRec.AccountId = accRec.Id;
        insert conRec;
        
        Lead ledRec = new Lead();
        ledRec.FirstName = 'Test';
        ledRec.LastName = 'Lead';
        ledRec.AccountId__c = accRec.Id;
        ledRec.Company = 'Test PVT.';
        ledRec.CurrencyIsoCode = 'INR';
        ledRec.Status = 'Sales Qualification';
        //ledRec.Location__c = locaRec.Id;
        insert ledRec;
        
        Assignment_Group__c asigGroupRec = new Assignment_Group__c();
        asigGroupRec.Name = 'Test AssigGroup';
        insert asigGroupRec;
        
        Assignment_Group_Member__c asigGroupMemberRec = new Assignment_Group_Member__c();
        asigGroupMemberRec.Assignment_Group__c = asigGroupRec.Id;
        asigGroupMemberRec.Assignment_Id__c = 0020;
        asigGroupMemberRec.Group_Member__c = UserInfo.getUserId();
        insert asigGroupMemberRec;
        asigGroupMemberRecList.add(asigGroupMemberRec);
        
        Dispatch_Address__c disAddress = new Dispatch_Address__c();
        disAddress.Account__c = accRec.Id;
        
        Route__c routeRec = new Route__c();
        routeRec.Predefined_Area__c = 'test';
        routeRec.Route_Name_del__c = 'JP Nagar';
        insert routeRec;
        routeList.add(routeRec.Route_Name_del__c);
        
        Roles_and_KPI__c roleKpiRec = new Roles_and_KPI__c();
        roleKpiRec.Name = 'Test Role and Kpi';
        roleKpiRec.Sales_User__c = UserInfo.getUserId();
        insert roleKpiRec;
        
        KPI_Target__c kpiTarRec = new KPI_Target__c();
        kpiTarRec.Roles_and_KPI__c = roleKpiRec.Id;
        insert kpiTarRec;
        
        Visit__c visirtRec = new Visit__c();
        visirtRec.Actual_visit_date__c = System.today();
        visirtRec.KPI_Target__c = kpiTarRec.Id;
        visirtRec.Account__c = accRec.Id;
        insert visirtRec;
        getAllvisitRecordList.add(visirtRec);
        
        Monthly_Beat_Plan__c mbpRec = new Monthly_Beat_Plan__c();
        mbpRec.Approval_Status__c = 'Approved';
        mbpRec.Start_Date__c = Date.newInstance(2023, 11, 9);
        mbpRec.CurrencyIsoCode = 'INR';
        mbpRec.Status__c = 'Approved';
        mbpRec.Month_year__c = '2023';
        mbpRec.Month_Name__c = 'November';
        insert mbpRec;
        
        Weekly_Beat_Plan__c wbpRec = new Weekly_Beat_Plan__c();
        wbpRec.Monthly_Beat_Plan__c = mbpRec.Id;
        insert wbpRec;
        test.startTest();
        
        MonthlyVisitViewerController.getcurrentUserRoutes();
        MonthlyVisitViewerController.fetchPageData('2023-November-11');
        MonthlyVisitViewerController.getAllLocationRecords();
        MonthlyVisitViewerController.getSelectedObjectRecord(ledRec.Id,locaRec.Id);
        MonthlyVisitViewerController.getSelectedAccountRecords(accRec.Id,locaRec.Id);
        MonthlyVisitViewerController.createVisits(getAllvisitRecordList);
        MonthlyVisitViewerController.showKpi(visirtRec.Id);
        MonthlyVisitViewerController.tagKIPToVisit(visirtRec.Id,kpiTarRec.Id);
        MonthlyVisitViewerController.getCurrentRecordGeoLocation(ledRec.Id);
        MonthlyVisitViewerController.getCurrentRecordGeoLocation(accRec.Id);
        MonthlyVisitViewerController.createVisitObjectTypev1(ledRec.Id, '2023-11-11', '12.890992','77.570802','6:32:00','7:32:00');
        MonthlyVisitViewerController.createVisitObjectTypev1(accRec.Id, '2023-11-11', '12.890992','77.570802','6:32:00','7:32:00');
        MonthlyVisitViewerController.createVisitObjectType(ledRec.Id, '2023-11-11', '12.890992','77.570802');
        MonthlyVisitViewerController.createVisitObjectType(accRec.Id, '2023-11-11', '12.890992','77.570802');
        MonthlyVisitViewerController.getUserVisits('JP Nagar');
        MonthlyVisitViewerController.fetchGroupmemeber('JP Nagar');
        MonthlyVisitViewerController.deleteEvent(visirtRec.Id);
    }
    
    
   
}