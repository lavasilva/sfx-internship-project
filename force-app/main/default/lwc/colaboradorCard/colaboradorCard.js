import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const BADGE_POR_STATUS = {
    Pendente: 'slds-badge slds-theme_warning',
    Elegível: 'slds-badge slds-theme_success',
    Inelegível: 'slds-badge slds-theme_error'
};

export default class ColaboradorCard extends NavigationMixin(LightningElement) {
    @api colaborador;
    @api selected = false;

    get nome() {
        return this.colaborador?.Nome_Completo__c;
    }

    get email() {
        return this.colaborador?.Email_Corporativo__c;
    }

    get status() {
        return this.colaborador?.Status_Elegibilidade__c;
    }

    get statusBadgeClass() {
        return BADGE_POR_STATUS[this.status] || 'slds-badge';
    }

    get containerClass() {
        return (
            'slds-box slds-box_x-small slds-grid slds-grid_vertical-align-center slds-grid_align-spread card' +
            (this.selected ? ' slds-theme_shade card-selected' : '')
        );
    }

    handleSelecionar() {
        this.dispatchEvent(
            new CustomEvent('selecionarcolaborador', {
                detail: { colaboradorId: this.colaborador.Id, colaborador: this.colaborador }
            })
        );
    }

    handleKeyDown(event) {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            this.handleSelecionar();
        }
    }

    handleVerRegistro(event) {
        // Evita que o clique no botão também selecione o card.
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.colaborador.Id,
                objectApiName: 'Colaborador__c',
                actionName: 'view'
            }
        });
    }
}
