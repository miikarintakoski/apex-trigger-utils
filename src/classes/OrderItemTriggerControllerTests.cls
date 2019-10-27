/**
 * Test methods for OrderTriggerController class
 */
@isTest
private class OrderItemTriggerControllerTests {
    
    /**
     * Tests quick delivery automation
     */
    @isTest
    static void testQuickDelivery() {
        Order__c order = new Order__c();
        order.Status__c = 'Offer';
        order.Priority__c = 'High';
        insert order;
        
        List<Order_Item__c> orderItems = new List<Order_Item__c>();
        orderItems.add(new Order_Item__c(Order__c = order.Id));
        orderItems.add(new Order_Item__c(Order__c = order.Id));
        insert orderItems;
        
        for(Order_Item__c orderItem : [SELECT Id, Quick_delivery__c FROM Order_Item__c WHERE Order__c = :order.Id]) {
            System.assertEquals(true, orderItem.Quick_delivery__c, 'Order item was not prioritized for quick delivery correctly.');
        }
    }
    
}