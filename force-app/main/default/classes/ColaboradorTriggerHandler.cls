public with sharing class ColaboradorTriggerHandler {

    // Aceita 11 dígitos crus ou o formato mascarado XXX.XXX.XXX-XX,
    // para ficar consistente com a Validation Rule CPF_Validation em Colaborador__c.
    private static final Pattern CPF_PATTERN = Pattern.compile('^(\\d{11}|\\d{3}\\.\\d{3}\\.\\d{3}-\\d{2})$');

    public void run() {
        if (Trigger.isInsert) {
            beforeInsert((List<Colaborador__c>) Trigger.new);
        } else if (Trigger.isUpdate) {
            beforeUpdate((List<Colaborador__c>) Trigger.new);
        }
    }

    public void beforeInsert(List<Colaborador__c> novosColaboradores) {
        validarCpf(novosColaboradores);
    }

    public void beforeUpdate(List<Colaborador__c> colaboradoresAtualizados) {
        validarCpf(colaboradoresAtualizados);
    }

    private void validarCpf(List<Colaborador__c> colaboradores) {
        for (Colaborador__c colaborador : colaboradores) {
            Boolean cpfValido = String.isNotBlank(colaborador.CPF__c)
                && CPF_PATTERN.matcher(colaborador.CPF__c).matches();

            if (!cpfValido) {
                colaborador.CPF__c.addError('CPF inválido. Use 11 dígitos ou o formato XXX.XXX.XXX-XX.');
            }
        }
    }
}