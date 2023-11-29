@isTest
public class submitBeaytPlanApprovalHelperTest {
    
     @isTest
    public static void getTest1(){
        
         Account acc = new Account();
         acc.Name = 'Test Account';
         insert acc;
         submitBeaytPlanApprovalHelper.submitApproval(acc.Id);
    }
}