public with sharing class ColaboradorElegibilidadeBatch implements Database.Batchable<SObject> {

    private static final String STATUS_PENDENTE = 'Pendente';
    private static final String STATUS_ELEGIVEL = 'Elegível';
    private static final String STATUS_INELEGIVEL = 'Inelegível';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Account__c, CPF__c, Email_Corporativo__c, Status_Elegibilidade__c
            FROM Colaborador__c
            WHERE Status_Elegibilidade__c = :STATUS_PENDENTE
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Colaborador__c> scope) {
        Set<Id> accountIds = new Set<Id>();
        Set<String> cpfs = new Set<String>();

        for (Colaborador__c colaborador : scope) {
            if (colaborador.Account__c != null) {
                accountIds.add(colaborador.Account__c);
            }
            if (String.isNotBlank(colaborador.CPF__c)) {
                cpfs.add(colaborador.CPF__c);
            }
        }

        Map<String, Set<Id>> idsPorContaECpf = new Map<String, Set<Id>>();
        for (Colaborador__c existente : [
            SELECT Id, Account__c, CPF__c
            FROM Colaborador__c
            WHERE Account__c IN :accountIds AND CPF__c IN :cpfs
        ]) {
            String chave = existente.Account__c + '|' + existente.CPF__c;
            if (!idsPorContaECpf.containsKey(chave)) {
                idsPorContaECpf.put(chave, new Set<Id>());
            }
            idsPorContaECpf.get(chave).add(existente.Id);
        }

        List<Colaborador__c> paraAtualizar = new List<Colaborador__c>();

        for (Colaborador__c colaborador : scope) {
            Boolean emailPreenchido = String.isNotBlank(colaborador.Email_Corporativo__c);
            String chave = colaborador.Account__c + '|' + colaborador.CPF__c;
            Boolean cpfDuplicadoNaConta = idsPorContaECpf.containsKey(chave)
                && idsPorContaECpf.get(chave).size() > 1;

            String novoStatus = (emailPreenchido && !cpfDuplicadoNaConta)
                ? STATUS_ELEGIVEL
                : STATUS_INELEGIVEL;

            paraAtualizar.add(new Colaborador__c(Id = colaborador.Id, Status_Elegibilidade__c = novoStatus));
        }

        update paraAtualizar;
    }

    public void finish(Database.BatchableContext bc) {
    }
}
