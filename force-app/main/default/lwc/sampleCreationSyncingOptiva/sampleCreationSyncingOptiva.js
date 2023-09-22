import { LightningElement,wire,track,api} from 'lwc';
import getRecord from '@salesforce/apex/Optiva_LWC_NPD_Controller.getRecordTypeName'
import syncSample from '@salesforce/apex/Optiva_LWC_NPD_Controller.syncSample'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {CloseActionScreenEvent} from 'lightning/actions';

export default class SampleCreationSyncingOptiva extends LightningElement {
    @api recordId;
    @track isLoading = true;
    @track responseMsg='';
    @track response;
    @track msgStyle = 'color:green;'
    

    connectedCallback() {
        setTimeout(() => {
            this.goalTrackingRecordDetails();
        }, 300);
    }

    goalTrackingRecordDetails() {
        getRecord({ recId: this.recordId })
            .then(data => {
                if(data){
                    console.log('Data',data);
                    if(!data.Submitted_To_SAP_Optiva__c){
                        if(data.RecordType && data.RecordType.Name){
                            this.submitProject(data.RecordType.Name);
                        }
                    }else{
                        this.showToast('Failed','Already synced to optiva');
                        this.closePopup();
                    }
                    
                } else {
                    console.log('error',error);
                    this.closePopup();
                }
        })
    }

    submitProject(recTypeName){
        this.isLoading = true;
        syncSample({recId:this.recordId,recType:recTypeName}).then(result=>{
            console.log('Result---->',result);
            if(result){
                this.response = result;
                this.responseMsg = result.message;
                if(result.status=='Success'){
                    this.showToast('Success',`${recTypeName} Synced Successfully!`,'success');
                    //setTimeout(() => window.location.reload(), 2000);
                }else{
                    this.msgStyle = 'color:red;';
                    this.showToast('Failed','','warning');
                }
                this.isLoading = false;
            }
            //this.closePopup();
        }).catch(error=>{
            this.responseMsg = error;
            this.msgStyle = 'color:red;';
            this.showToast('error',error,'error');
            this.isLoading = false;
            //this.closePopup();
        })
    }

    closePopup(){
        if(this.response && this.response.status=='Success'){
            setTimeout(() => window.location.reload(), 2000);
        }
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}