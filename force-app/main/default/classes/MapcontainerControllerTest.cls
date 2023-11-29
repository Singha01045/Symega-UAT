@isTest
public class MapcontainerControllerTest {

    @isTest
    public static void getAccountDetailsTest() {
        
        Account accRec = new Account();
        accRec.Name = 'Test FSL';
        insert accRec;
        MapcontainerController.getAccountDetails(accRec.id);
       // MapcontainerController.GoogleMapReverseGeocodeCallout('12.890992','77.570802');
    }
    
      static testMethod void shouldBeAbleToGetData(){
       // Case myCase = getTestCase();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMockTset());
        String res =  MapcontainerController.GoogleMapReverseGeocodeCallout('12.891530','77.594078');
        Test.stopTest();
      }
}