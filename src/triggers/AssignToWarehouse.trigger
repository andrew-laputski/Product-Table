trigger AssignToWarehouse on Product_Table__c (before insert, before update) {
    AssignProductToWarehouseTriggerHandler.productAssignment(Trigger.new);

}