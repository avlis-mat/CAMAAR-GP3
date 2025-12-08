require 'rails_helper'

RSpec.describe Questao, type: :model do
  describe 'validations' do
    it 'é válida como dissertativa da fábrica' do
      expect(build(:questao)).to be_valid
    end

    it 'exige tipo permitido' do
      questao = build(:questao, tipo: 'verdadeiro_falso')
      expect(questao).not_to be_valid
    end

    it 'exige pelo menos duas opções para múltipla escolha' do
      questao = build(:questao, tipo: 'multipla_escolha')
      questao.questao_opcoes = [build(:questao_opcao, questao: questao)]
      expect(questao).not_to be_valid
    end

    it 'exige unicidade de versão dentro do agrupamento' do
      existente = create(:questao, agrupamento: 10, versao: 1)
      nova = build(:questao, agrupamento: existente.agrupamento, versao: 1, modelo: existente.modelo)
      expect(nova).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'define agrupamento quando não informado' do
      questao = create(:questao, agrupamento: nil)
      expect(questao.agrupamento).to eq(questao.id)
    end
  end

  describe 'scopes' do
    it 'aplica ordenação e filtro do default_scope' do
      questao1 = create(:questao, ordem: 2)
      questao2 = create(:questao, ordem: 1)
      create(:questao, :inativo, ordem: 3)
      expect(Questao.all).to eq([questao2, questao1])
    end

    it 'retorna todas as versões ignorando status' do
      ativo = create(:questao)
      inativo = create(:questao, :inativo)
      expect(Questao.todas_versoes).to match_array([ativo, inativo])
    end

    it 'filtra por tipo' do
      dissertativa = create(:questao)
      multipla = create(:questao, :multipla_escolha)
      expect(Questao.dissertativas).to contain_exactly(dissertativa)
      expect(Questao.multipla_escolha).to include(multipla)
    end
  end
end
