@isTest
private class PropostaTriggerTest {

    @TestSetup
    static void setup() {
        Account acc = TestDataFactory.createAccount();
        TestDataFactory.createOpportunity(acc);
        TestDataFactory.createPlanoCom();
    }

    @isTest
    static void testCriarPropostaValida() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Plano_Comercial__c plano = [SELECT Id FROM Plano_Comercial__c LIMIT 1];

        Test.startTest();
        Proposta__c proposta = TestDataFactory.createProposta(opp, plano);
        Test.stopTest();

        proposta = [SELECT Status__c FROM Proposta__c WHERE Id = :proposta.Id];
        System.assertEquals('Rascunho', proposta.Status__c);
    }

    @isTest
    static void testAtualizarPropostaValidaRecalculaValor() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Plano_Comercial__c plano = [SELECT Id FROM Plano_Comercial__c LIMIT 1];
        Proposta__c proposta = TestDataFactory.createProposta(opp, plano);

        Test.startTest();
        proposta.Status__c = 'Enviada';
        proposta.Numero_Colaboradores__c = 20;
        update proposta;
        Test.stopTest();

        proposta = [SELECT Status__c, Valor_Total_Calculado__c FROM Proposta__c WHERE Id = :proposta.Id];
        System.assertEquals('Enviada', proposta.Status__c);
        System.assertEquals(2000, proposta.Valor_Total_Calculado__c);
    }

    @isTest
    static void testBloqueiaSegundaPropostaRascunhoNaMesmaOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Plano_Comercial__c plano = [SELECT Id FROM Plano_Comercial__c LIMIT 1];
        TestDataFactory.createProposta(opp, plano);

        Proposta__c segunda = new Proposta__c(
            Opportunity__c = opp.Id,
            Plano_Comercial__c = plano.Id,
            Status__c = 'Rascunho',
            Numero_Colaboradores__c = 5
        );

        Test.startTest();
        DmlException erro;
        try {
            insert segunda;
        } catch (DmlException e) {
            erro = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, erro);
        System.assert(erro.getMessage().contains('Já existe uma Proposta em Rascunho'));
    }

    @isTest
    static void testBulkPropostas200Registros() {
        Plano_Comercial__c plano = [SELECT Id FROM Plano_Comercial__c LIMIT 1];
        Account acc = TestDataFactory.createAccount();

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            opps.add(new Opportunity(
                Name = 'Opp Bulk ' + i,
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            ));
        }
        insert opps;

        List<Proposta__c> propostas = new List<Proposta__c>();
        for (Opportunity opp : opps) {
            propostas.add(new Proposta__c(
                Opportunity__c = opp.Id,
                Plano_Comercial__c = plano.Id,
                Status__c = 'Rascunho',
                Numero_Colaboradores__c = 10,
                Data_Envio__c = Date.today()
            ));
        }

        Test.startTest();
        insert propostas;
        Test.stopTest();

        System.assertEquals(200, [SELECT COUNT() FROM Proposta__c WHERE Status__c = 'Rascunho']);
    }
}
