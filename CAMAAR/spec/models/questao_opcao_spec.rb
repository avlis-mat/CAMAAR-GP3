require 'rails_helper'

RSpec.describe QuestaoOpcao, type: :model do
  describe 'validations' do
    it 'é válida com atributos da fábrica' do
      expect(build(:questao_opcao)).to be_valid
    end

    it 'exige ordem única dentro da questão' do
      questao = create(:questao)
      create(:questao_opcao, questao: questao, ordem: 1)
      duplicada = build(:questao_opcao, questao: questao, ordem: 1)
      expect(duplicada).not_to be_valid
    end

    it 'exige unicidade de versão dentro do agrupamento' do
      existente = create(:questao_opcao, agrupamento: 20, versao: 1)
      duplicada = build(:questao_opcao, agrupamento: existente.agrupamento, versao: 1, questao: existente.questao)
      expect(duplicada).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'define agrupamento quando não informado' do
      opcao = create(:questao_opcao, agrupamento: nil)
      expect(opcao.agrupamento).to eq(opcao.id)
    end
  end

  describe 'scopes' do
    it 'usa default_scope para status ativo e ordenação' do
      opcao2 = create(:questao_opcao, ordem: 2)
      opcao1 = create(:questao_opcao, ordem: 1)
      create(:questao_opcao, :inativa, ordem: 3)
      expect(QuestaoOpcao.all).to eq([opcao1, opcao2])
    end

    it 'retorna apenas opções corretas' do
      correta = create(:questao_opcao, :correta)
      create(:questao_opcao, is_correta: false)
      expect(QuestaoOpcao.corretas).to contain_exactly(correta)
    end
  end
end
