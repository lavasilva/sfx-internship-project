@isTest
public class TestDataFactory {

    private static Integer counter = 0;

    public static Account createAccount() {
        counter++;
        Account acc = new Account(Name = 'Conta Teste ' + counter);
        insert acc;
        return acc;
    }

    public static Opportunity createOpportunity(Account acc) {
        counter++;
        Opportunity opp = new Opportunity(
            Name = 'Oportunidade Teste ' + counter,
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        return opp;
    }

    public static Plano_Comercial__c createPlanoCom() {
        counter++;
        Plano_Comercial__c plano = new Plano_Comercial__c(
            Nome__c = 'Plano Teste ' + counter,
            Tipo_Plano__c = 'Standard',
            Valor_Por_Vida__c = 100,
            Ativo__c = true,
            Cobertura_Academias__c = false
        );
        insert plano;
        return plano;
    }

    public static Proposta__c createProposta(Opportunity opp, Plano_Comercial__c plano) {
        counter++;
        Proposta__c proposta = new Proposta__c(
            Opportunity__c = opp.Id,
            Plano_Comercial__c = (plano != null) ? plano.Id : null,
            Status__c = 'Rascunho',
            Numero_Colaboradores__c = 10,
            Data_Envio__c = Date.today()
        );
        insert proposta;
        return proposta;
    }

    public static Colaborador__c createColaborador(Account acc) {
        counter++;
        Colaborador__c colaborador = new Colaborador__c(
            Account__c = acc.Id,
            Nome_Completo__c = 'Colaborador Teste ' + counter,
            CPF__c = String.valueOf(counter).leftPad(11, '0'),
            Email_Corporativo__c = 'colaborador' + counter + '@teste.com',
            Status_Elegibilidade__c = 'Pendente',
            Data_Inclusao__c = Date.today()
        );
        insert colaborador;
        return colaborador;
    }
}
