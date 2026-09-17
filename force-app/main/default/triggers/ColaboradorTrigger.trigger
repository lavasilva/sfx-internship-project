trigger ColaboradorTrigger on Colaborador__c (before insert, before update) {
    new ColaboradorTriggerHandler().run();
}