trigger PropostaTrigger on Proposta__c (before insert, before update) {
    new PropostaTriggerHandler().run();
}