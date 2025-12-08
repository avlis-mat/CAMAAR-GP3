require 'rails_helper'

RSpec.describe UsuarioMateria, type: :model do
  describe 'validations' do
    it 'é válida com atributos da fábrica' do
      expect(build(:usuario_materia)).to be_valid
    end

    it 'exige papel permitido' do
      vinculo = build(:usuario_materia, papel: 'monitor')
      expect(vinculo).not_to be_valid
    end

    it 'garante unicidade de usuário por matéria' do
      usuario = create(:usuario)
      materia = create(:materia)
      create(:usuario_materia, usuario: usuario, materia: materia)

      duplicado = build(:usuario_materia, usuario: usuario, materia: materia)
      expect(duplicado).not_to be_valid
    end
  end

  describe 'scopes' do
    it 'retorna apenas alunos em .alunos' do
      aluno = create(:usuario_materia, papel: 'aluno')
      create(:usuario_materia, papel: 'professor')
      expect(UsuarioMateria.alunos).to contain_exactly(aluno)
    end

    it 'retorna apenas professores em .professores' do
      professor = create(:usuario_materia, papel: 'professor')
      create(:usuario_materia, papel: 'aluno')
      expect(UsuarioMateria.professores).to contain_exactly(professor)
    end
  end
end
