import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CURRENCY from '@salesforce/i18n/currency';
import STATUS_FIELD from '@salesforce/schema/Proposta__c.Status__c';
import VALOR_TOTAL_FIELD from '@salesforce/schema/Proposta__c.Valor_Total__c';
import PLANO_NOME_FIELD from '@salesforce/schema/Proposta__c.Plano_Comercial__r.Nome__c';

const BADGE_POR_STATUS = {
    Rascunho: 'slds-badge',
    Enviada: 'slds-badge slds-badge_inverse',
    Aprovada: 'slds-badge slds-theme_success',
    Recusada: 'slds-badge slds-theme_error',
    'Sem Resposta': 'slds-badge slds-theme_warning'
};

export default class PropostaResumo extends LightningElement {
    @api recordId;

    currencyCode = CURRENCY;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [STATUS_FIELD, VALOR_TOTAL_FIELD, PLANO_NOME_FIELD]
    })
    proposta;

    get isLoading() {
        return !this.proposta.data && !this.proposta.error;
    }

    get hasError() {
        return Boolean(this.proposta.error);
    }

    get errorMessage() {
        const error = this.proposta.error;
        if (!error) {
            return '';
        }
        if (Array.isArray(error.body)) {
            return error.body.map((e) => e.message).join(', ');
        }
        return error.body?.message || 'Erro desconhecido ao carregar a proposta.';
    }

    get hasData() {
        return Boolean(this.proposta.data);
    }

    get status() {
        return getFieldValue(this.proposta.data, STATUS_FIELD);
    }

    get valorTotal() {
        return getFieldValue(this.proposta.data, VALOR_TOTAL_FIELD);
    }

    get planoNome() {
        return getFieldValue(this.proposta.data, PLANO_NOME_FIELD);
    }

    get statusBadgeClass() {
        return BADGE_POR_STATUS[this.status] || 'slds-badge';
    }
}
