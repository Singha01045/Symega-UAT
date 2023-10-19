public class SchedulerInsightsProgressRing_Handler {

    @AuraEnabled
    public static List<Roles_and_KPI__c> getRoleAndKPI(){
        //List<Roles_and_KPI__c> getAllRAKList = [Select Id,Name From Roles_and_KPI__c Where Sales_User__c =: userInfo.getUserId() ];
         List<Roles_and_KPI__c> getAllRAKList = [Select Id,Name From Roles_and_KPI__c];
        //System.debug('getAllRAKList ==>'+getAllRAKList.Sales_User__r.Name);
         System.debug('getAllRAKList ==>'+getAllRAKList);
        return getAllRAKList;
    }
}