/**
 * Process automation around Order__c object DML operations
 * @author	Miika Rintakoski
 */
public class OrderTriggerController extends TriggerController {
	
    private static UpdateCache orderItemUpdateCache = new UpdateCache();

    protected override void afterInsert() {
        confirmOrderItems(Trigger.New);
        /* All the other logic which is run on order triggers */
        removeDeliveryBlock(Trigger.New);
        orderItemUpdateCache.updateRecords(true);
    }
    
    protected override void afterUpdate() {
		confirmOrderItems(Trigger.New);
        /* All the other logic which is run on order triggers */
        removeDeliveryBlock(Trigger.New);
        orderItemUpdateCache.updateRecords(true);
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
            for(Order_Item__c orderItem : [SELECT Id FROM Order_Item__c WHERE Order__c IN :confirmedOrderIDs AND Item_Status__c != 'Confirmed']) {
                orderItem.Item_Status__c = 'Confirmed';
                toBeConfirmedItems.add(orderItem);
            }
            orderItemUpdateCache.setRecordsForUpdate(toBeConfirmedItems);
        }
    }
    
    /**
     * Remove delivery block when order is sent out
     * @param   newVersions The orders that have been created or updated
     */
    private void removeDeliveryBlock(List<Order__c> newVersions) {
        Set<Id> inTransitOrderIDs = new Set<Id>();
        for(Order__c order : newVersions) {
            if(order.Delivery_Status__c == 'In transit' && isChanged(order, Schema.Order__c.Delivery_Status__c)) {
                inTransitOrderIDs.add(order.Id);
            }
        }
        if(!inTransitOrderIDs.isEmpty()) {
            List<Order_Item__c> toBeReleasedItems = new List<Order_Item__c>();
            for(Order_Item__c orderItem : [SELECT Id FROM Order_Item__c WHERE Order__c IN :inTransitOrderIDs AND Delivery_on_hold__c = true]) {
                orderItem.Delivery_on_hold__c = false;
                toBeReleasedItems.add(orderItem);
            }
            orderItemUpdateCache.setRecordsForUpdate(toBeReleasedItems);
        }
    }
    
}