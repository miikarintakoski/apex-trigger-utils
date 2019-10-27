trigger orderTrigger on Order__c (after insert, after update) {
    new OrderTriggerController().run();
}