@isTest
private class ColaboradorTriggerTest {

    @isTest
    static void testCriarColaboradorCpfValido() {
        Account acc = TestDataFactory.createAccount();

        Test.startTest();
        Colaborador__c colaborador = TestDataFactory.createColaborador(acc);
        Test.stopTest();

        colaborador = [SELECT CPF__c FROM Colaborador__c WHERE Id = :colaborador.Id];
        System.assertNotEquals(null, colaborador.CPF__c);
    }

    @isTest
    static void testCriarColaboradorCpfComMascaraValido() {
        Account acc = TestDataFactory.createAccount();
        Colaborador__c colaborador = new Colaborador__c(
            Account__c = acc.Id,
            Nome_Completo__c = 'Colaborador Mascarado',
            CPF__c = '123.456.789-01',
            Email_Corporativo__c = 'mascarado@teste.com',
            Status_Elegibilidade__c = 'Pendente'
        );

        Test.startTest();
        insert colaborador;
        Test.stopTest();

        System.assertNotEquals(null, colaborador.Id);
    }

    @isTest
    static void testBloqueiaColaboradorCpfInvalido() {
        Account acc = TestDataFactory.createAccount();
        Colaborador__c colaborador = new Colaborador__c(
            Account__c = acc.Id,
            Nome_Completo__c = 'Colaborador Invalido',
            CPF__c = '123',
            Email_Corporativo__c = 'invalido@teste.com',
            Status_Elegibilidade__c = 'Pendente'
        );

        Test.startTest();
        DmlException erro;
        try {
            insert colaborador;
        } catch (DmlException e) {
            erro = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, erro);
        System.assert(erro.getMessage().contains('CPF inválido'));
    }

    @isTest
    static void testBulkColaboradores200Registros() {
        Account acc = TestDataFactory.createAccount();
        List<Colaborador__c> colaboradores = new List<Colaborador__c>();
        for (Integer i = 0; i < 200; i++) {
            colaboradores.add(new Colaborador__c(
                Account__c = acc.Id,
                Nome_Completo__c = 'Colaborador Bulk ' + i,
                CPF__c = String.valueOf(i).leftPad(11, '0'),
                Email_Corporativo__c = 'bulk' + i + '@teste.com',
                Status_Elegibilidade__c = 'Pendente'
            ));
        }

        Test.startTest();
        insert colaboradores;
        Test.stopTest();

        System.assertEquals(200, [SELECT COUNT() FROM Colaborador__c WHERE Account__c = :acc.Id]);
    }
}
