public without sharing class createAutoSampleHelper {
    
    @AuraEnabled
    public static string createSample(String projId){
        try{
            SampleTriggerHandler.createSampleAndSampleLineItem(new set<Id> {projId});
            return 'success';
        }
        catch(Exception ex){
            system.debug('EXCEPTION EX MSG --' + ex.getMessage());
            system.debug('EXCEPTION EX LINE NO --' + ex.getLineNumber());
            return ex.getMessage();
        }
        
    }
}