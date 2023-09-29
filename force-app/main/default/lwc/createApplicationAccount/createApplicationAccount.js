import { LightningElement,api,wire,track} from 'lwc';
import getRecordDetails from '@salesforce/apex/ProjectHanlder.getOppRecord';
import getRecordTypeId from '@salesforce/apex/ProjectHanlder.getProjectRecordTypeId';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateApplicationAccount extends NavigationMixin(LightningElement) {
    @api recordId;
    @track recordTypeSelected;

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }

    //@wire(getRecordDetails,{ accId : '$recordId'})

    getRecordDetails(){
        getRecordDetails({id : this.recordId}).then(data=>{
            if(data){
                this.oppRecord = data;
                console.log('RecordId', this.recordId);
                console.log('Data',data);
                this.openCreateRecordForm();
            }
        })
    }

    openCreateRecordForm(){
        debugger;
        getRecordTypeId({recordTypeName: 'Application'}).then(result=>{
            console.log("RecordTypeRECEIVED-----",result);
            let recordTypeId = result;
            let defaultValues = encodeDefaultFieldValues({
                Opportunity__c : this.recordId,
                Customer_Name__c : this.oppRecord.Account.Name,
                Application_Name__c	: `${this.oppRecord.Account.Name}-Application`,
                Customers_Contact__c : this.oppRecord.Account.Customer_Contact__c,
                CurrencyIsoCode : this.oppRecord.CurrencyIsoCode,

                City__c : this.oppRecord.Shipping_City__c,
                Country__c : this.oppRecord.Shipping_Country__c,
                Postal_Code__c : this.oppRecord.Shipping_Postal_Code__c,
                State__c : this.oppRecord.Shipping_State__c,
                Street__c : this.oppRecord.Shipping_Street__c,

                Billing_City__c : this.oppRecord.Billing_City__c,
                Billing_Country__c : this.oppRecord.Billing_Country__c,
                Billing_Postal_Code__c : this.oppRecord.Billing_Postal_Code__c,
                Billing_State__c : this.oppRecord.Billing_State__c,
                Billing_Street__c : this.oppRecord.Billing_Street__c,
            });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Project__c',
                actionName: 'new'
            },state: {
               defaultFieldValues: defaultValues,
               recordTypeId: recordTypeId
            }
        });
    }).catch(error=>{
        console.log("Error-----",error);
    })
    }
}