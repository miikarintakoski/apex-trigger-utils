trigger orderItemTrigger on Order_Item__c (before insert) {
    new OrderItemTriggerController().run();
}