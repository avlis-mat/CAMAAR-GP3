require 'rails_helper'

RSpec.describe Modelo, type: :model do
  describe 'validations' do
    it 'é válido com atributos da fábrica' do
      expect(build(:modelo)).to be_valid
    end

    it 'exige nome com tamanho mínimo' do
      modelo = build(:modelo, nome: 'AB')
      expect(modelo).not_to be_valid
    end

    it 'exige versão positiva' do
      modelo = build(:modelo, versao: 0)
      expect(modelo).not_to be_valid
    end

    it 'exige unicidade de versão dentro do agrupamento' do
      existente = create(:modelo, versao: 1, agrupamento: 10)
      novo = build(:modelo, versao: 1, agrupamento: existente.agrupamento, usuario: existente.usuario)
      expect(novo).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'define agrupamento com o id após criar quando não informado' do
      modelo = create(:modelo, agrupamento: nil)
      expect(modelo.agrupamento).to eq(modelo.id)
    end
  end

  describe 'scopes' do
    it 'aplica default_scope para status ativo' do
      ativo = create(:modelo)
      create(:modelo, :inativo)
      expect(Modelo.all).to contain_exactly(ativo)
    end

    it 'retorna todas as versões ignorando o default_scope' do
      ativo = create(:modelo)
      inativo = create(:modelo, :inativo)
      expect(Modelo.todas_versoes).to match_array([ativo, inativo])
    end

    it 'ordena versões de um agrupamento' do
      primeiro = create(:modelo, versao: 1, agrupamento: 50)
      segundo = create(:modelo, versao: 2, agrupamento: 50)
      expect(Modelo.versoes_de(50)).to eq([primeiro, segundo])
    end
  end
end
