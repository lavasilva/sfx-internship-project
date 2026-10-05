import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import buscarColaboradores from '@salesforce/apex/ColaboradorBuscadorController.buscarColaboradores';

export default class ColaboradorBuscador extends LightningElement {
    @api recordId;

    termo = '';
    colaboradores = [];
    selecionado;
    isLoading = false;
    buscou = false;
    errorMessage;

    get semResultados() {
        return this.buscou && !this.isLoading && !this.errorMessage && this.colaboradores.length === 0;
    }

    get temResultados() {
        return this.colaboradores.length > 0;
    }

    get quantidadeLabel() {
        const total = this.colaboradores.length;
        return total === 1 ? '1 colaborador encontrado' : `${total} colaboradores encontrados`;
    }

    get itens() {
        return this.colaboradores.map((colaborador) => ({
            colaborador,
            selected: this.selecionado?.Id === colaborador.Id
        }));
    }

    handleTermoChange(event) {
        this.termo = event.target.value;
    }

    handleKeyUp(event) {
        if (event.key === 'Enter') {
            this.handlePesquisar();
        }
    }

    // Chamada imperativa: só dispara no clique do botão, com controle total sobre quando executar.
    async handlePesquisar() {
        this.isLoading = true;
        this.errorMessage = undefined;
        this.selecionado = undefined;

        try {
            this.colaboradores = await buscarColaboradores({
                accountId: this.recordId,
                termo: this.termo
            });
        } catch (error) {
            this.colaboradores = [];
            this.errorMessage = error?.body?.message || 'Erro ao buscar colaboradores.';
        } finally {
            this.buscou = true;
            this.isLoading = false;
        }
    }

    handleSelecionarColaborador(event) {
        this.selecionado = event.detail.colaborador;
    }

    handleFechar() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
