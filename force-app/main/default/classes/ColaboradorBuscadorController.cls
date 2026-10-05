public with sharing class ColaboradorBuscadorController {

    private static final Integer LIMITE_RESULTADOS = 50;

    @AuraEnabled
    public static List<Colaborador__c> buscarColaboradores(Id accountId, String termo) {
        if (accountId == null) {
            throw new AuraHandledException('Conta não informada para a busca de colaboradores.');
        }

        String filtro = '%' + (String.isBlank(termo) ? '' : String.escapeSingleQuotes(termo.trim())) + '%';

        try {
            return [
                SELECT Id, Name, Nome_Completo__c, Email_Corporativo__c,
                       Status_Elegibilidade__c, Data_Inclusao__c
                FROM Colaborador__c
                WHERE Account__c = :accountId
                AND (Name LIKE :filtro OR Nome_Completo__c LIKE :filtro)
                WITH USER_MODE
                ORDER BY Name
                LIMIT :LIMITE_RESULTADOS
            ];
        } catch (QueryException e) {
            throw new AuraHandledException('Não foi possível buscar os colaboradores: ' + e.getMessage());
        }
    }
}
