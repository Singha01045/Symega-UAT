public class TriggerOnVisitHelper {
    public static void updateDistanceOnRelatedDatVisit(List<Visit__c> updatedVisits, Map<Id, Visit__c> oldVisitMap) {
        Map<Id, List<Visit__c>> dayVisitMap = new Map<Id, List<Visit__c>>();
        
        for (Visit__c newVisit : updatedVisits) {
            if (newVisit.Visit_Plan__c != null) {
                if (!dayVisitMap.containsKey(newVisit.Visit_Plan__c)) {
                    dayVisitMap.put(newVisit.Visit_Plan__c, new List<Visit__c>());
                }
                dayVisitMap.get(newVisit.Visit_Plan__c).add(newVisit);
            }
        }

        List<Day_Visit_Plan__c> dayVisitToBeUpdatedDistance = new List<Day_Visit_Plan__c>();
        
        for (Id dayVisitId : dayVisitMap.keySet()) {
            Day_Visit_Plan__c toUpdateDis = new Day_Visit_Plan__c(Id = dayVisitId);
            Double totalDistance = 0;
            for (Visit__c visit : dayVisitMap.get(dayVisitId)) {
                try {
                    // Make sure Distance__c is populated before using it
                    if (visit.Distance__c != null) {
                        totalDistance += visit.Distance__c;
                    }
                } catch (Exception e) {
                    System.debug('Exception occurred: ' + e.getMessage());
                    System.debug('Exception occurred at Line: ' + e.getLineNumber());
                    // Log additional information about the exception for debugging
                }
            }

            // Retrieve existing Total_Covered_Distance__c and add the new distance
            toUpdateDis = [SELECT Id, Total_Covered_Distance__c FROM Day_Visit_Plan__c WHERE Id = :dayVisitId LIMIT 1];
            toUpdateDis.Total_Covered_Distance__c += totalDistance;
            dayVisitToBeUpdatedDistance.add(toUpdateDis);
        }

        if (!dayVisitToBeUpdatedDistance.isEmpty()) {
            try {
                System.debug('dayVisitToBeUpdatedDistance: ' + dayVisitToBeUpdatedDistance);
                update dayVisitToBeUpdatedDistance;
            } catch (Exception e) {
                System.debug('Exception occurred during update: ' + e.getMessage());
                System.debug('Exception occurred at Line: ' + e.getLineNumber());
                // Log additional information about the exception for debugging
            }
        }
    }
}