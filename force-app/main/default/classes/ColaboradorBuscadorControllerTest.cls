@isTest
private class ColaboradorBuscadorControllerTest {

    @TestSetup
    static void setup() {
        Account conta = TestDataFactory.createAccount();
        Account outraConta = TestDataFactory.createAccount();

        TestDataFactory.createColaborador(conta);
        TestDataFactory.createColaborador(conta);
        TestDataFactory.createColaborador(outraConta);

        Colaborador__c maria = TestDataFactory.createColaborador(conta);
        update new Colaborador__c(Id = maria.Id, Nome_Completo__c = 'Maria Buscavel');
    }

    private static Account contaComColaboradores() {
        return [SELECT Id FROM Account WHERE Name LIKE 'Conta Teste%' ORDER BY CreatedDate ASC LIMIT 1];
    }

    @isTest
    static void testBuscaPorNomeRetornaApenasCorrespondentes() {
        Account conta = contaComColaboradores();

        Test.startTest();
        List<Colaborador__c> resultado = ColaboradorBuscadorController.buscarColaboradores(conta.Id, 'maria');
        Test.stopTest();

        System.assertEquals(1, resultado.size(), 'Deve retornar apenas o colaborador que contém o termo');
        System.assertEquals('Maria Buscavel', resultado[0].Nome_Completo__c);
    }

    @isTest
    static void testBuscaPeloCampoNameQuandoNomeCompletoVazio() {
        Account conta = contaComColaboradores();
        insert new Colaborador__c(
            Name = 'Gilberto',
            Account__c = conta.Id,
            CPF__c = '88888888888',
            Status_Elegibilidade__c = 'Pendente'
        );

        List<Colaborador__c> resultado = ColaboradorBuscadorController.buscarColaboradores(conta.Id, 'Gil');

        System.assertEquals(1, resultado.size(), 'Deve encontrar pelo Name mesmo sem Nome_Completo__c');
        System.assertEquals('Gilberto', resultado[0].Name);
    }

    @isTest
    static void testBuscaSemTermoRetornaTodosDaConta() {
        Account conta = contaComColaboradores();

        List<Colaborador__c> resultado = ColaboradorBuscadorController.buscarColaboradores(conta.Id, '');

        System.assertEquals(3, resultado.size(), 'Deve retornar somente colaboradores da conta informada');
    }

    @isTest
    static void testBuscaSemCorrespondenciaRetornaVazio() {
        Account conta = contaComColaboradores();

        List<Colaborador__c> resultado = ColaboradorBuscadorController.buscarColaboradores(conta.Id, 'zzz-inexistente');

        System.assert(resultado.isEmpty(), 'Não deve retornar colaboradores');
    }

    @isTest
    static void testContaNulaLancaExcecao() {
        try {
            ColaboradorBuscadorController.buscarColaboradores(null, 'maria');
            System.assert(false, 'Deveria ter lançado AuraHandledException');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }

    @isTest
    static void testUsuarioSemAcessoAoObjetoLancaExcecaoAmigavel() {
        Account conta = contaComColaboradores();
        Profile semAcesso = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1];
        User usuario = new User(
            Alias = 'semacess',
            Email = 'semacesso@teste.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Sem Acesso',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Sao_Paulo',
            ProfileId = semAcesso.Id,
            Username = 'semacesso' + System.currentTimeMillis() + '@teste.com'
        );
        insert usuario;

        System.runAs(usuario) {
            try {
                ColaboradorBuscadorController.buscarColaboradores(conta.Id, 'maria');
                System.assert(false, 'Deveria ter lançado AuraHandledException por falta de acesso');
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e.getMessage());
            }
        }
    }

    @isTest
    static void testLimiteDe50Resultados() {
        Account conta = TestDataFactory.createAccount();
        List<Colaborador__c> lote = new List<Colaborador__c>();
        for (Integer i = 0; i < 60; i++) {
            lote.add(new Colaborador__c(
                Account__c = conta.Id,
                Nome_Completo__c = 'Lote ' + i,
                CPF__c = String.valueOf(90000000000L + i),
                Email_Corporativo__c = 'lote' + i + '@teste.com',
                Status_Elegibilidade__c = 'Pendente'
            ));
        }
        insert lote;

        List<Colaborador__c> resultado = ColaboradorBuscadorController.buscarColaboradores(conta.Id, 'Lote');

        System.assertEquals(50, resultado.size(), 'A busca deve respeitar LIMIT 50');
    }
}
