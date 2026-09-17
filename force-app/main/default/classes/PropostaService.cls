public with sharing class PropostaService {

    public static void calcularValorTotal(List<Proposta__c> propostas) {
        Set<Id> planoIds = new Set<Id>();

        for (Proposta__c proposta : propostas) {
            if (proposta.Plano_Comercial__c != null) {
                planoIds.add(proposta.Plano_Comercial__c);
            }
        }

        Map<Id, Plano_Comercial__c> planosPorId = new Map<Id, Plano_Comercial__c>(
            [SELECT Id, Valor_Por_Vida__c FROM Plano_Comercial__c WHERE Id IN :planoIds]
        );

        for (Proposta__c proposta : propostas) {
            Plano_Comercial__c plano = planosPorId.get(proposta.Plano_Comercial__c);
            Decimal valorPorVida = (plano != null && plano.Valor_Por_Vida__c != null) ? plano.Valor_Por_Vida__c : 0;
            Decimal numeroColaboradores = (proposta.Numero_Colaboradores__c != null) ? proposta.Numero_Colaboradores__c : 0;

            proposta.Valor_Total_Calculado__c = numeroColaboradores * valorPorVida;
        }
    }
}