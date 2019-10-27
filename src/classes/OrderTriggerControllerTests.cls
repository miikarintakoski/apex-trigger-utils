/**
 * Test methods for OrderTriggerController class
 */
@isTest
private class OrderTriggerControllerTests {
    
    /**
     * Verify that the order confirmation also confirms the items
     */
    @isTest
    static void testOrderConfirmation() {
        Order__c order = new Order__c();
        order.Status__c = 'Offer';
        insert order;
        
        List<Order_Item__c> orderItems = new List<Order_Item__c>();
        orderItems.add(new Order_Item__c(Order__c = order.Id));
        orderItems.add(new Order_Item__c(Order__c = order.Id));
        insert orderItems;
        
        order.Status__c = 'Confirmed';
        update order;
        
        for(Order_Item__c orderItem : [SELECT Id, Item_Status__c FROM Order_Item__c WHERE Order__c = :order.Id]) {
            System.assertEquals('Confirmed', orderItem.Item_Status__c, 'Order item was not confirmed correctly.');
        }
    }
    
    /**
     * Verify releasing the order will remove delivery hold from order items
     */
    @isTest
    static void testDeliveryBlockRemoval() {
        Order__c order = new Order__c();
        order.Status__c = 'Offer';
        insert order;
        
        List<Order_Item__c> orderItems = new List<Order_Item__c>();
        orderItems.add(new Order_Item__c(Order__c = order.Id, Delivery_on_hold__c = true));
        orderItems.add(new Order_Item__c(Order__c = order.Id, Delivery_on_hold__c = true));
        insert orderItems;
        
        order.Status__c = 'Confirmed';
        order.Delivery_Status__c = 'In transit';
        update order;
        
        for(Order_Item__c orderItem : [SELECT Id, Delivery_on_hold__c FROM Order_Item__c WHERE Order__c = :order.Id]) {
            System.assertEquals(false, orderItem.Delivery_on_hold__c, 'Order item was not released correctly.');
        }
    }
    
}