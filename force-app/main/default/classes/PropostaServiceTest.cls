@isTest
private class PropostaServiceTest {

    @isTest
    static void testCalcularValorTotalComPlano() {
        Account acc = TestDataFactory.createAccount();
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        Plano_Comercial__c plano = TestDataFactory.createPlanoCom();

        Test.startTest();
        Proposta__c proposta = new Proposta__c(
            Opportunity__c = opp.Id,
            Plano_Comercial__c = plano.Id,
            Status__c = 'Enviada',
            Numero_Colaboradores__c = 50,
            Data_Envio__c = Date.today()
        );
        insert proposta;
        Test.stopTest();

        proposta = [SELECT Valor_Total_Calculado__c FROM Proposta__c WHERE Id = :proposta.Id];
        System.assertEquals(5000, proposta.Valor_Total_Calculado__c);
    }

    @isTest
    static void testCalcularValorTotalSemPlano() {
        Account acc = TestDataFactory.createAccount();
        Opportunity opp = TestDataFactory.createOpportunity(acc);

        Test.startTest();
        Proposta__c proposta = new Proposta__c(
            Opportunity__c = opp.Id,
            Status__c = 'Enviada',
            Numero_Colaboradores__c = 50,
            Data_Envio__c = Date.today()
        );
        insert proposta;
        Test.stopTest();

        proposta = [SELECT Valor_Total_Calculado__c FROM Proposta__c WHERE Id = :proposta.Id];
        System.assertEquals(0, proposta.Valor_Total_Calculado__c);
    }
}
