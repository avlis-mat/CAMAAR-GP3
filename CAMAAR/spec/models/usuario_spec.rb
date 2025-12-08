require 'rails_helper'

RSpec.describe Usuario, type: :model do
  describe 'validations' do
    it 'é válido com atributos padrão da fábrica' do
      expect(build(:usuario)).to be_valid
    end

    it 'exige matrícula com 9 dígitos' do
      usuario = build(:usuario, matricula: '12345')
      expect(usuario).not_to be_valid
      expect(usuario.errors[:matricula]).to include('deve ter 9 dígitos')
    end

    it 'exige tipo permitido' do
      usuario = build(:usuario, tipo: 'guest')
      expect(usuario).not_to be_valid
      expect(usuario.errors[:tipo]).to be_present
    end

    it 'exige email único' do
      create(:usuario, email: 'duplicado@example.com')
      usuario = build(:usuario, email: 'duplicado@example.com')
      expect(usuario).not_to be_valid
    end
  end

  describe 'scopes' do
    it 'retorna apenas usuários ativos em .ativos' do
      ativo = create(:usuario, status: 'ativo')
      create(:usuario, status: 'pendente')
      expect(Usuario.ativos).to contain_exactly(ativo)
    end

    it 'filtra administradores' do
      admin = create(:usuario, :administrador)
      create(:usuario)
      expect(Usuario.administradores).to contain_exactly(admin)
    end

    it 'filtra por departamento' do
      cs = create(:usuario, departamento: 'CIC')
      create(:usuario, departamento: 'ENE')
      expect(Usuario.do_departamento('CIC')).to contain_exactly(cs)
    end
  end

  describe '#administrador?' do
    it 'retorna true para administradores' do
      expect(build(:usuario, :administrador).administrador?).to be true
    end

    it 'retorna false para outros tipos' do
      expect(build(:usuario).administrador?).to be false
    end
  end

  describe '#ativo?' do
    it 'retorna true para status ativo' do
      expect(build(:usuario, status: 'ativo').ativo?).to be true
    end

    it 'retorna false para status diferente de ativo' do
      expect(build(:usuario, status: 'pendente').ativo?).to be false
    end
  end
end
