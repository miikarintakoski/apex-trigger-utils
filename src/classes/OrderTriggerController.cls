/**
 * Process automation around Order__c object DML operations
 * @author	Miika Rintakoski
 */
public class OrderTriggerController extends TriggerController {
	
    protected override void afterInsert() {
        confirmOrderItems(Trigger.New);
    }
    
    protected override void afterUpdate() {
		confirmOrderItems(Trigger.New);
    }
	
    /**
     * Confirms order items when order is confirmed
     * @param	newVersions	The orders that have been created or updated
     */
    private void confirmOrderItems(List<Order__c> newVersions) {
        Set<Id> confirmedOrderIDs = new Set<Id>();
        for(Order__c order : newVersions) {
            if(order.Status__c == 'Confirmed' && isChanged(order, Schema.Order__c.Status__c)) {
                confirmedOrderIDs.add(order.Id);
            }
        }
        if(!confirmedOrderIDs.isEmpty()) {
            List<Order_Item__c> toBeConfirmedItems = new List<Order_Item__c>();
            for(Order_Item__c orderItem : [SELECT Id FROM Order_Item__c WHERE Order__c IN :confirmedOrderIDs]) {
                orderItem.Item_Status__c = 'Confirmed';
                toBeConfirmedItems.add(orderItem);
            }
            update toBeConfirmedItems;
        }
    }
    
}