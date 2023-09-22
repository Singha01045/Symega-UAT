public without sharing class Optiva_LWC_NPD_Controller {
    
    @AuraEnabled
    public static Project__c getRecordTypeName(String recId){
        try {
            return [Select Id,RecordType.name,Submitted_To_SAP_Optiva__c FROM Project__c where Id =:recId];
        } catch (Exception e) {
            HandleBusinessException.captureError('Optiva_LWC_NPD_Controller','getRecordTypeName',e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,String> syncSample(String recId, String recType){
        try {
            if(recType=='Project'){
                return Optiva_Callout.projectCreation(recId);
            }else if(recType=='Application'){
                return Optiva_Callout.applicationCreation(recId);
            }else if(recType=='Sample'){
                return Optiva_Callout.sampleCreation(recId); // create sample in optiva or create task for SAP
            }else{
                System.debug('SOSOSOS----'+recType);
                return Optiva_Callout.techDocCreation(recId);
            }
        } catch (Exception e) {
            HandleBusinessException.captureError('Optiva_LWC_NPD_Controller','syncSample',e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}