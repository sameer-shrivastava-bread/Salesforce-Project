trigger BookTrigger on Book__c (before insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        BookTriggerHandler.beforeInsert(Trigger.new);
    }
}