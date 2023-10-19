({
	doInit : function(component, event, helper) {
        debugger;
        let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        let date=new Date();
        let year=date.getFullYear();
        let month=date.getMonth();
        let MonthName=monthNames[date.getMonth()]+' '+year;
        
		component.set("v.MonthList",['January'+' '+year, 'February'+' '+year, 'March'+' '+year, 'April'+' '+year, 'May'+' '+year, 'June'+' '+year, 'July'+' '+year, 'August'+' '+year, 'September'+' '+year, 'October'+' '+year, 'November'+' '+year, 'December'+' '+year]);
        var FirstMonthList=[{month:'January'+' '+year,colormatch:null},{month:'February'+' '+year,colormatch:null},{month:'March'+' '+year,colormatch:null},{month:'April'+' '+year,colormatch:null},{month:'May'+' '+year,colormatch:null} ,{month:'June'+' '+year,colormatch:null}];
        var SecondMonthList=[{month:'July'+' '+year,colormatch:null},{month:'August'+' '+year,colormatch:null},{month:'September'+' '+year,colormatch:null},{month:'October'+' '+year,colormatch:null},{month:'November'+' '+year,colormatch:null},{month:'December'+' '+year,colormatch:null}];
        var FirstMonthListMobile = [{month:'January'+' '+year,colormatch:null},{month:'February'+' '+year,colormatch:null},{month:'March'+' '+year,colormatch:null}];
        var SecondMonthListMobile = [{month:'April'+' '+year,colormatch:null},{month:'May'+' '+year,colormatch:null} ,{month:'June'+' '+year,colormatch:null}];
        var ThirdMonthListMobile = [{month:'July'+' '+year,colormatch:null},{month:'August'+' '+year,colormatch:null},{month:'September'+' '+year,colormatch:null}];
        var FourthMonthListMobile = [{month:'October'+' '+year,colormatch:null},{month:'November'+' '+year,colormatch:null},{month:'December'+' '+year,colormatch:null}];
        var allMonthListMobile = [{month:'January'+' '+year,colormatch:null},{month:'February'+' '+year,colormatch:null},{month:'March'+' '+year,colormatch:null},{month:'April'+' '+year,colormatch:null},{month:'May'+' '+year,colormatch:null} ,{month:'June'+' '+year,colormatch:null},{month:'July'+' '+year,colormatch:null},{month:'August'+' '+year,colormatch:null},{month:'September'+' '+year,colormatch:null},{month:'October'+' '+year,colormatch:null},{month:'November'+' '+year,colormatch:null},{month:'December'+' '+year,colormatch:null}];
        for(let i=0;i<FirstMonthList.length;i++){
            if(FirstMonthList[i]==MonthName){
                console.log('FirstMonthList');
                component.set("v.MonthListToShow",FirstMonthList); 
            }
        }
        for(let i=0;i<SecondMonthList.length;i++){
            if(SecondMonthList[i].month==MonthName){
                SecondMonthList[i].colormatch=true;
                console.log('SecondMonthList');
                component.set("v.MonthListToShow",SecondMonthList); 
            }else{
                SecondMonthList[i].colormatch=false;
            }
        }
        
        for(let i=0;i<FirstMonthListMobile.length;i++){
            if(FirstMonthListMobile[i]==MonthName){
                console.log('FirstMonthListMobile');
                component.set("v.MonthListToShowMobile",FirstMonthListMobile); 
            }
        }
        for(let i=0;i<SecondMonthListMobile.length;i++){
            if(SecondMonthListMobile[i].month==MonthName){
                SecondMonthListMobile[i].colormatch=true;
                console.log('SecondMonthListMobile');
                component.set("v.MonthListToShowMobile",SecondMonthListMobile); 
            }else{
                SecondMonthListMobile[i].colormatch=false;
            }
        }
        for(let i=0;i<ThirdMonthListMobile.length;i++){
            if(ThirdMonthListMobile[i].month==MonthName){
                ThirdMonthListMobile[i].colormatch=true;
                console.log('ThirdMonthListMobile');
                component.set("v.MonthListToShowMobile",ThirdMonthListMobile); 
            }else{
                ThirdMonthListMobile[i].colormatch=false;
            }
        }
        for(let i=0;i<FourthMonthListMobile.length;i++){
            if(FourthMonthListMobile[i].month==MonthName){
                FourthMonthListMobile[i].colormatch=true;
                console.log('FourthMonthListMobile');
                component.set("v.MonthListToShowMobile",FourthMonthListMobile); 
            }else{
                FourthMonthListMobile[i].colormatch=false;
            }
        }
        
        var cmpEvent = component.getEvent("sampleCmpEvent"); 
        //Set event attribute value
        cmpEvent.setParams({
            "Month" : monthNames[date.getMonth()],
             "Year":year
        }); 
        cmpEvent.fire(); 
	},
    
    handlePrevClicked:function(component, event, helper) {
       debugger;
        let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        let date=new Date();
        let year=date.getFullYear();
        let month=date.getMonth();
        let MonthName=monthNames[date.getMonth()]+' '+year;
        let NumbersofMonthToShow=5;
        let TempMonthlist=[];
        var MonthList=component.get("v.MonthList");
        let FirstIndexMonth;
        var MonthListOnUI=component.get("v.MonthListToShow");
        let selectedmonthstoshow;
        for(let i=0;i<MonthListOnUI.length;i++){
            if(i==0)
               FirstIndexMonth=MonthListOnUI[i].month;
               break; 
        }
        let index=MonthList.findIndex((x) => x === FirstIndexMonth);
        index=index-1;
        NumbersofMonthToShow=NumbersofMonthToShow+index;
        for(let i=index;i<=NumbersofMonthToShow;i++){
             if(MonthName==MonthList[i]){
                selectedmonthstoshow={month:MonthList[i],colormatch:true};
            }else{
                selectedmonthstoshow={month:MonthList[i],colormatch:false};
            }
            TempMonthlist.push(selectedmonthstoshow);
        }
        component.set("v.MonthListToShow",TempMonthlist);
        let FirstMonth='January'+' '+year;
        if(FirstIndexMonth==MonthList[0]){
            component.set("v.disablePrev",false);
        }
    },
     handleNextClicked:function(component, event, helper) {
       debugger;
        let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        let date=new Date();
        let year=date.getFullYear();
        let month=date.getMonth();
        let MonthName=monthNames[date.getMonth()]+' '+year;
        let NumbersofMonthToShow=5;
        let selectedmonthstoshow;
        let TempMonthlist=[];
        var MonthList=component.get("v.MonthList");
        let FirstIndexMonth;
        var MonthListOnUI=component.get("v.MonthListToShow");
        for(let i=0;i<MonthListOnUI.length;i++){
            if(i==0){
                FirstIndexMonth=MonthListOnUI[i].month;
                break; 
            }    
        }
        let index=MonthList.findIndex((x) => x === FirstIndexMonth);
        index=index+1;
        NumbersofMonthToShow=NumbersofMonthToShow+index;
        for(let i=index;i<=NumbersofMonthToShow;i++){
            if(MonthName==MonthList[i]){
                selectedmonthstoshow={month:MonthList[i],colormatch:true};
            }else{
                selectedmonthstoshow={month:MonthList[i],colormatch:false};
            }
            TempMonthlist.push(selectedmonthstoshow);
        }
        component.set("v.MonthListToShow",TempMonthlist); 
    },
    handleClick:function(component, event, helper) {
        debugger;
        var MonthlyList= component.get("v.MonthListToShow");
        var selectedMonth = event.getSource().get('v.value');
        for(let i=0;i<MonthlyList.length;i++){
            if(MonthlyList[i].month==selectedMonth){
                MonthlyList[i].colormatch=true;
            }else{
                MonthlyList[i].colormatch=false;
            }
        }
        component.set("v.MonthListToShow",MonthlyList); 
        const str = selectedMonth;
        let Array=str.split(' ');
        let Month=Array[0];
        let Year=Array[1];
        var cmpEvent = component.getEvent("sampleCmpEvent"); 
        //Set event attribute value
        cmpEvent.setParams({
            "Month" : Month,
             "Year":Year
        }); 
        cmpEvent.fire(); 


    }
})