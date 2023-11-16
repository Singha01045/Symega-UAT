@isTest
public with sharing class Scheduler_Insight_MonthYearTest {

    @isTest(SeeAllData=true)
    public static void Scheduler_Insight_MonthYearTest() {

        Scheduler_Insight_MonthYear_handler.getMonthBeatPlan('November','2023');
        Scheduler_Insight_MonthYear_handler.getMonthlyRecord('November','2023');
    }
}