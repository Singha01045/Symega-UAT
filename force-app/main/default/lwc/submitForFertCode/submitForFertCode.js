import { LightningElement,api,track,wire } from 'lwc';
import getOpportunityprods from '@salesforce/apex/SubmitForFertCodeController.getOpportunityprods'; 
import GetPicklistValues_Object from '@salesforce/apex/SubmitForFertCodeController.GetPicklistValues_Object';  
import updateOppProdList from '@salesforce/apex/SubmitForFertCodeController.updateOppProdList'; 
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SubmitForFertCode extends LightningElement {

 @api recordId='0061m00000AyM4bAAF';
 @track oppProdList = [];

 @track options =[];
 @track options1 =[];
 @track options2 =[];
  idValueMap = new Map();
  @track prodList =[];
  @track   jsonVar =[];
  accId;
  showAccountPage = false;
  showSpinner = true;

   wrapperObject = {
    opplId: '',
    bool: false
}
  wrapperArray = [];
  missingFieldsList;

  connectedCallback(){
      debugger;
        setTimeout(() => {
            this.getRecordDetails();
            this.GetPicklistValues_Object();
        }, 300);
    }



    getRecordDetails(){
        debugger;
        getOpportunityprods({OppId:this.recordId}).then(data=>{
            if(data){
                console.log('Data',data);
                this.oppProdList = data.oliList;

                if(data.missingFieldsList.length > 0) {
                    this.showAccountPage = true;
                    this.accId = data.accId;
                    this.missingFieldsList = data.missingFieldsList;
                }
                this.showSpinner = false;
                console.log('  this.oppProdList---->',  this.oppProdList);
                console.log('  this.missingFieldsList --->',  this.missingFieldsList);
            }
        })
    }

     GetPicklistValues_Object(){
        debugger;
        GetPicklistValues_Object().then(data=>{
            if(data){
                console.log('Data',data);
                let Arr=data.Label.Label__c;
                let Arr1 = data.Ingredients_List_Declared_With_Customer.Ingredients_List_Declared_With_Customer__c;
                let Arr2 = data.Packaging_Type.Packaging_Type__c;

                let option=[]
                for(var i=0; i < Arr.length; i++){
                  option.push({label:Arr[i],value:Arr[i]});
                }
                this.options=option;

                 let option1=[]
                for(var i=0; i < Arr1.length; i++){
                  option1.push({label:Arr1[i],value:Arr1[i]});
                }
                 this.options1=option1;

                  let option2=[]
                for(var i=0; i < Arr2.length; i++){
                  option2.push({label:Arr2[i],value:Arr2[i]});
                }
                 this.options2=option2;

                console.log('  this.options---->',JSON.stringify(this.options));
                console.log('  this.options1---->',JSON.stringify(this.options1));
            }
        })
    }

    changeHandler(event){
        debugger;
         let sectionName=event.currentTarget.dataset.name;
         let id=event.currentTarget.dataset.id;
         if(sectionName=='Address'){
              if(event.target.city){
                    this.oppProdList.forEach((element) => {
                         if(element.Id==id){
                             element.Opportunity.Billing_City__c=event.target.city;
                         }
                    })
              } 

              if(event.target.street){
                    this.oppProdList.forEach((element) => {
                         if(element.Id==id){
                             element.Opportunity.Billing_Street__c=event.target.street;
                         }
                    })
              } 

              if(event.target.country){
                    this.oppProdList.forEach((element) => {
                         if(element.Id==id){
                             element.Opportunity.Billing_Country__c=event.target.country;
                         }
                    })
              } 

              if(event.target.province){
                    this.oppProdList.forEach((element) => {
                         if(element.Id==id){
                             element.Opportunity.Billing_State__c=event.target.province;
                         }
                    })
              } 

              if(event.target.postalCode){
                    this.oppProdList.forEach((element) => {
                         if(element.Id==id){
                             element.Opportunity.Billing_Postal_Code__c=event.target.postalCode;
                         }
                    })
              } 

         }else{

              this.oppProdList.forEach((element) => {
                    if(element.Id==id){
                     //  element[sectionName]=event.target.value;

                    if(sectionName == 'Allergen_Status_Required__c'){
                         //   console.log('sectionName--->',sectionName);
                         //     this.idValueMap.set(element.Id, event.target.checked); 
                         //     console.log('this.idValueMap.---->',this.idValueMap);
                         //    let mapValue = JSON.stringify(this.idValueMap);
                         //    //  let mapValue = this.idValueMap;
                         //      console.log('mapValue--->',mapValue);
                         //  //   console.log('jsonVar--->',this.jsonVar);
                         //     //this.prodList = this.idValueMap;
                         //     Console.log('   this.prodList --->',   this.prodList );
                            
                              let instance1 = Object.assign({}, this.wrapperObject);
                                   instance1.prodId = element.Product2Id;
                                   instance1.bool = event.target.checked;
                                   this.wrapperArray.push(instance1);

                              console.log('wrapperArray---->',this.wrapperArray);

                         }else{
                              element[sectionName]=event.target.value;
                         } 
                    }
               })

         } 
       console.log('this.oppProdList--'+JSON.stringify(this.oppProdList));

       

       /* if(sectionName == 'Name'){
             
        }else if(sectionName == 'Address'){
             let city=event.target.city;

        }else if(sectionName == 'Fert_Description__c'){
               this.oppProdList.forEach((element) => {
                    if(element.Id==id){
                       element[sectionName]=event.target.value;
                    }
               })
             console.log('this.oppProdList--'+JSON.stringify(this.oppProdList));
        }else if(sectionName == 'uom'){
             let uom = event.target.value;


        }else if(sectionName == 'halbcode'){
                let halbcode = event.target.value;

        }else if(sectionName == 'baseQty'){
               let baseQty = event.target.value;

        }else if(sectionName == 'ShelfLifeQty'){
                 let ShelfLifeQty = event.target.value;

        }else if(sectionName == 'Allergen'){
            let Allergen = event.target.value;   

        }else if(sectionName == 'Veg'){
             let Veg = event.target.value;  
  
        }else if(sectionName == 'CustomerCustomisedlabel'){
             let CustomerCustomisedlabel = event.target.value;

        }else if(sectionName == 'IngredientsListdeclared'){
               let IngredientsListdeclared = event.target.value;

        }else if(sectionName == 'IngredientsList'){
                let IngredientsList = event.target.value;
   
        }else if(sectionName == 'RevealSymegaIdentity'){
              let RevealSymegaIdentity = event.target.value;

        }else if(sectionName == 'cusineryIdentity'){
               let cusineryIdentity = event.target.value;

        }else if(sectionName == 'Label'){
             let Label = event.target.value;

        }else if(sectionName == 'MaterialSector'){
             let MaterialSector = event.target.value;

        }else if(sectionName == 'SalesRemarks'){
             let SalesRemarks = event.target.value;

        }else if(sectionName == 'Plant'){
             let Plant = event.target.value;

        }else if(sectionName == 'controlcode'){
             let controlcode = event.target.value;

        }else if(sectionName == 'Primary'){
             let Primary = event.target.value;

        }else if(sectionName == 'secondary'){
             let secondary = event.target.value;

        }else if(sectionName == 'Teritary'){
             let Teritary = event.target.value;

        }*/
       
    }
    
    updateOppProdList(){
          debugger;
          updateOppProdList({oppLineList:this.oppProdList, prodList:JSON.stringify(this.wrapperArray)}).then(data=>{
               if(data == 'Success'){
                    console.log('Data',data);
                    this.showToast('Success', 'Notification to Sales Ops sent successfully!', 'success');
                    this.closeModal();
               }
               else if(data == 'create'){
                    console.log('Data',data);
                    this.showToast('Success', 'Customer Creation in Progress!', 'success');
                    this.closeModal();
               }
               else{
                    this.showToast('Error', data, 'error');
               }
          })
    }

     showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
     }

     closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
     }
    
     handleSave(){
         debugger;
         this.updateOppProdList();
     }

     handleSuccess(){
          debugger;
          this.showToast('Success', 'Account updated successfully', 'success');
          this.showAccountPage = false;
     }

}