public with sharing class PropostaTriggerHandler {

    private static final String STATUS_RASCUNHO = 'Rascunho';

    public void run() {
        if (Trigger.isInsert) {
            beforeInsert((List<Proposta__c>) Trigger.new);
        } else if (Trigger.isUpdate) {
            beforeUpdate((List<Proposta__c>) Trigger.new, (Map<Id, Proposta__c>) Trigger.oldMap);
        }
    }

    public void beforeInsert(List<Proposta__c> novasPropostas) {
        validarUnicidadeRascunho(novasPropostas, null);
        PropostaService.calcularValorTotal(novasPropostas);
    }

    public void beforeUpdate(List<Proposta__c> propostasNovas, Map<Id, Proposta__c> propostasAntigas) {
        validarUnicidadeRascunho(propostasNovas, propostasAntigas);
        PropostaService.calcularValorTotal(propostasNovas);
    }

    private void validarUnicidadeRascunho(List<Proposta__c> propostas, Map<Id, Proposta__c> propostasAntigas) {
        Set<Id> opportunityIdsParaChecar = new Set<Id>();

        for (Proposta__c proposta : propostas) {
            if (proposta.Status__c != STATUS_RASCUNHO || proposta.Opportunity__c == null) {
                continue;
            }

            Proposta__c versaoAnterior = (propostasAntigas != null) ? propostasAntigas.get(proposta.Id) : null;
            Boolean estaEntrandoEmRascunho = versaoAnterior == null
                || versaoAnterior.Status__c != STATUS_RASCUNHO
                || versaoAnterior.Opportunity__c != proposta.Opportunity__c;

            if (estaEntrandoEmRascunho) {
                opportunityIdsParaChecar.add(proposta.Opportunity__c);
            }
        }

        if (opportunityIdsParaChecar.isEmpty()) {
            return;
        }

        Set<Id> opportunityIdsComRascunhoExistente = new Set<Id>();
        for (Proposta__c propostaExistente : [
            SELECT Id, Opportunity__c
            FROM Proposta__c
            WHERE Opportunity__c IN :opportunityIdsParaChecar AND Status__c = :STATUS_RASCUNHO
        ]) {
            opportunityIdsComRascunhoExistente.add(propostaExistente.Opportunity__c);
        }

        Set<Id> opportunityIdsJaTratadosNesteLote = new Set<Id>();

        for (Proposta__c proposta : propostas) {
            if (proposta.Status__c != STATUS_RASCUNHO || proposta.Opportunity__c == null
                || !opportunityIdsParaChecar.contains(proposta.Opportunity__c)) {
                continue;
            }

            Boolean jaExisteRascunho = opportunityIdsComRascunhoExistente.contains(proposta.Opportunity__c)
                || opportunityIdsJaTratadosNesteLote.contains(proposta.Opportunity__c);

            if (jaExisteRascunho) {
                proposta.addError(new PropostaException('Já existe uma Proposta em Rascunho para esta Oportunidade').getMessage());
            } else {
                opportunityIdsJaTratadosNesteLote.add(proposta.Opportunity__c);
            }
        }
    }
}