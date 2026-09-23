@isTest
private class ColaboradorElegibilidadeSchedulerTest {

    @isTest
    static void testAgendamentoCriaCronTrigger() {
        String cronExp = '0 0 8 ? * MON';

        Test.startTest();
        String jobId = System.schedule(
            'Teste Elegibilidade Colaboradores', cronExp, new ColaboradorElegibilidadeScheduler()
        );
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression);
    }

    @isTest
    static void testExecuteDisparaBatch() {
        Account acc = TestDataFactory.createAccount();
        TestDataFactory.createColaborador(acc);

        Test.startTest();
        new ColaboradorElegibilidadeScheduler().execute(null);
        Test.stopTest();

        Colaborador__c colaborador = [
            SELECT Status_Elegibilidade__c FROM Colaborador__c WHERE Account__c = :acc.Id LIMIT 1
        ];
        System.assertEquals('Elegível', colaborador.Status_Elegibilidade__c);
    }
}
