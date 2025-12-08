require 'rails_helper'

RSpec.describe Resposta, type: :model do
  describe 'validações de conteúdo' do
    it 'é válida para questão dissertativa com conteúdo' do
      questao = create(:questao, tipo: 'dissertativa')
      resposta = build(:resposta, questao: questao, conteudo: 'Texto', questao_opcao: nil)
      expect(resposta).to be_valid
    end

    it 'exige conteúdo para questão dissertativa' do
      questao = create(:questao, tipo: 'dissertativa')
      resposta = build(:resposta, questao: questao, conteudo: nil)
      expect(resposta).not_to be_valid
      expect(resposta.errors[:conteudo]).to include('não pode ficar em branco')
    end

    it 'exige opção para questão de múltipla escolha' do
      questao = create(:questao, :multipla_escolha)
      resposta = build(:resposta, :multipla_escolha, questao: questao, questao_opcao: nil)
      expect(resposta).not_to be_valid
      expect(resposta.errors[:questao_opcao_id]).to include('deve selecionar uma opção')
    end

    it 'valida se a opção pertence à questão' do
      questao = create(:questao, :multipla_escolha)
      outra_questao = create(:questao, :multipla_escolha)
      opcao_de_outra = outra_questao.questao_opcoes.first
      resposta = build(:resposta, :multipla_escolha, questao: questao, questao_opcao: opcao_de_outra)
      expect(resposta).not_to be_valid
      expect(resposta.errors[:questao_opcao_id]).to include('não pertence à questão')
    end
  end

  describe 'unicidade de resposta por usuário' do
    it 'não permite responder a mesma questão mais de uma vez no mesmo formulário' do
      formulario = create(:formulario)
      questao = create(:questao, modelo: formulario.modelo)
      usuario = create(:usuario)
      create(:resposta, formulario: formulario, questao: questao, usuario: usuario)

      resposta_duplicada = build(:resposta, formulario: formulario, questao: questao, usuario: usuario)
      expect(resposta_duplicada).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'preenche respondido_em ao criar' do
      resposta = create(:resposta)
      expect(resposta.respondido_em).to be_present
    end
  end
end
