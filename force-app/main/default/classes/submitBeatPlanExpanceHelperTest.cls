@isTest
public class submitBeatPlanExpanceHelperTest {
    
    @isTest
    public static void getTest1(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        submitBeatPlanExpanceHelper.submitApproval(acc.ID);
        
    }

}