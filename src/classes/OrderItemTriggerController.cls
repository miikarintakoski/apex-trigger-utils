/**
 * Process automation around Order_Item__c object DML operations
 * @author	Miika Rintakoski
 */
public class OrderItemTriggerController extends TriggerController {

    protected override void beforeInsert() {
        setQuickDelivery();
    }
    
    /**
     * If order priority is high, default quick delivery to true
     */
    private void setQuickDelivery() {
        Set<Id> orderIds = new Set<Id>();
        for(Order_Item__c orderItem : (List<Order_Item__c>)Trigger.New) {
            orderIds.add(orderItem.Order__c);
        }
        Map<Id, Order__c> orders = new Map<Id, Order__c>([SELECT Id, Priority__c FROM Order__c WHERE Id IN :orderIds]);
        for(Order_Item__c orderItem : (List<Order_Item__c>)Trigger.New) {
            System.debug(orders.get(orderItem.Order__c));
            if(orders.get(orderItem.Order__c).Priority__c == 'High') {
                orderItem.Quick_delivery__c = true;
            }
        }
    }
    
}