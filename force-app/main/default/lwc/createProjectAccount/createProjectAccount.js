import { LightningElement,api,wire,track} from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PROJECT_OBJECT from '@salesforce/schema/Project__c';
import getRecordDetails from '@salesforce/apex/ProjectHanlder.getAccRecord';
import getRecordTypeId from '@salesforce/apex/ProjectHanlder.getProjectRecordTypeId';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class CreateProjectAccount extends NavigationMixin(LightningElement) {
    @api recordId;
    @track recordTypeSelected;

    @track wiredResult;

    connectedCallback(){
        setTimeout(() => {
            this.getRecordDetails();
        }, 300);
    }
    //@wire(getRecordDetails,{ accId : '$recordId'})

    getRecordDetails(){
        getRecordDetails({ accId : this.recordId}).then(data=>{
            debugger;
           // refreshApex(this.wiredResult);
            this.wiredResult = data;
            if(data){
                this.accRecord = data;
                console.log('RecordId', this.recordId);
                console.log('Data',data);
                this.openCreateRecordForm();
            }
            // if(error){
            //     console.log("Errorsss",error);
            // }
        })
    }
    

    /*@wire(getObjectInfo, { objectApiName: PROJECT_OBJECT })
    accObjectInfo({data, error}) {
        if(data) {
            let optionsValues = [];
            const rtInfos = data.recordTypeInfos;

            let rtValues = Object.values(rtInfos);

            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].name !== 'Master') {
                    optionsValues.push({
                        label: rtValues[i].name,
                        value: rtValues[i].recordTypeId
                    })
                }
            }

            this.recordTypeSelected = optionsValues[2].value;
            this.options = optionsValues;
        }
        else if(error) {
            window.console.log('Error ===> '+JSON.stringify(error));
        }
    }*/

    openCreateRecordForm(){
        debugger;
        getRecordTypeId({recordTypeName: 'Project'}).then(result=>{
            console.log("RecordTypeRECEIVED-----",result);
            let recordTypeId = result;        
            let defaultValues = encodeDefaultFieldValues({
            Account__c:this.recordId,
            Customer_Name__c :this.accRecord.Name,
            Project_Name__c	:`${this.accRecord.Name}-Project`,
            Customers_Contact__c:this.accRecord.Customer_Contact__c,
            City__c:this.accRecord.ShippingCity?this.accRecord.ShippingCity:"",
            Country__c:this.accRecord.ShippingCountry?this.accRecord.ShippingCountry:"",
            Postal_Code__c	:this.accRecord.ShippingPostalCode?this.accRecord.ShippingPostalCode:"",
            State__c:this.accRecord.ShippingState?this.accRecord.ShippingState:"",
            Street__c:this.accRecord.ShippingStreet?this.accRecord.ShippingStreet:"",
            CurrencyIsoCode : this.accRecord.CurrencyIsoCode
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