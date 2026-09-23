@isTest
private class ColaboradorElegibilidadeBatchTest {

    @isTest
    static void testColaboradorValidoFicaElegivel() {
        Account acc = TestDataFactory.createAccount();
        TestDataFactory.createColaborador(acc);

        Test.startTest();
        Database.executeBatch(new ColaboradorElegibilidadeBatch());
        Test.stopTest();

        Colaborador__c colaborador = [
            SELECT Status_Elegibilidade__c FROM Colaborador__c WHERE Account__c = :acc.Id LIMIT 1
        ];
        System.assertEquals('Elegível', colaborador.Status_Elegibilidade__c);
    }

    @isTest
    static void testColaboradorSemEmailFicaInelegivel() {
        Account acc = TestDataFactory.createAccount();
        Colaborador__c colaborador = TestDataFactory.createColaborador(acc);
        // Reenviar o sObject completo falharia: Account__c é Master-Detail e não pode
        // ser reenviado em um update (mesmo com o mesmo valor) sem "Allow reparenting".
        update new Colaborador__c(Id = colaborador.Id, Email_Corporativo__c = null);

        Test.startTest();
        Database.executeBatch(new ColaboradorElegibilidadeBatch());
        Test.stopTest();

        colaborador = [SELECT Status_Elegibilidade__c FROM Colaborador__c WHERE Id = :colaborador.Id];
        System.assertEquals('Inelegível', colaborador.Status_Elegibilidade__c);
    }

    @isTest
    static void testCpfDuplicadoNaMesmaContaFicaInelegivel() {
        Account acc = TestDataFactory.createAccount();
        String cpfCompartilhado = '11122233344';

        insert new List<Colaborador__c>{
            new Colaborador__c(
                Account__c = acc.Id, Nome_Completo__c = 'Duplicado 1',
                CPF__c = cpfCompartilhado, Email_Corporativo__c = 'dup1@teste.com',
                Status_Elegibilidade__c = 'Pendente'
            ),
            new Colaborador__c(
                Account__c = acc.Id, Nome_Completo__c = 'Duplicado 2',
                CPF__c = cpfCompartilhado, Email_Corporativo__c = 'dup2@teste.com',
                Status_Elegibilidade__c = 'Pendente'
            )
        };

        Test.startTest();
        Database.executeBatch(new ColaboradorElegibilidadeBatch());
        Test.stopTest();

        for (Colaborador__c colaborador : [
            SELECT Status_Elegibilidade__c FROM Colaborador__c WHERE CPF__c = :cpfCompartilhado
        ]) {
            System.assertEquals('Inelegível', colaborador.Status_Elegibilidade__c);
        }
    }

    @isTest
    static void testBulk200ColaboradoresPendentes() {
        Account acc = TestDataFactory.createAccount();
        List<Colaborador__c> colaboradores = new List<Colaborador__c>();
        for (Integer i = 0; i < 200; i++) {
            colaboradores.add(new Colaborador__c(
                Account__c = acc.Id,
                Nome_Completo__c = 'Bulk ' + i,
                CPF__c = String.valueOf(i).leftPad(11, '0'),
                Email_Corporativo__c = 'bulk' + i + '@teste.com',
                Status_Elegibilidade__c = 'Pendente'
            ));
        }
        insert colaboradores;

        Test.startTest();
        Database.executeBatch(new ColaboradorElegibilidadeBatch(), 200);
        Test.stopTest();

        System.assertEquals(
            200,
            [SELECT COUNT() FROM Colaborador__c WHERE Status_Elegibilidade__c = 'Elegível']
        );
    }
}
