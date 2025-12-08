require 'rails_helper'

RSpec.describe Materia, type: :model do
  describe 'validations' do
    it 'é válida com atributos da fábrica' do
      expect(build(:materia)).to be_valid
    end

    it 'exige código no formato AAA0000' do
      materia = build(:materia, codigo: '1234')
      expect(materia).not_to be_valid
      expect(materia.errors[:codigo]).to be_present
    end

    it 'exige código da turma no formato T?' do
      materia = build(:materia, codigo_turma: '123')
      expect(materia).not_to be_valid
      expect(materia.errors[:codigo_turma]).to be_present
    end

    it 'exige semestre no formato 2025.1' do
      materia = build(:materia, semestre: '2025-1')
      expect(materia).not_to be_valid
      expect(materia.errors[:semestre]).to be_present
    end

    it 'garante unicidade de turma por código e semestre' do
      create(:materia, codigo: 'MAT1234', codigo_turma: 'TA', semestre: '2025.1')
      materia = build(:materia, codigo: 'MAT1234', codigo_turma: 'TA', semestre: '2025.1')
      expect(materia).not_to be_valid
    end
  end

  describe 'scopes' do
    it 'filtra por semestre' do
      alvo = create(:materia, semestre: '2025.2')
      create(:materia, semestre: '2024.1')
      expect(Materia.do_semestre('2025.2')).to contain_exactly(alvo)
    end

    it 'filtra por departamento' do
      ene = create(:materia, departamento: 'ENE')
      create(:materia, departamento: 'CIC')
      expect(Materia.do_departamento('ENE')).to contain_exactly(ene)
    end

    it 'filtra por código de disciplina' do
      alvo = create(:materia, codigo: 'MAT9999')
      create(:materia, codigo: 'MAT0001')
      expect(Materia.da_disciplina('MAT9999')).to contain_exactly(alvo)
    end
  end

  describe 'helpers' do
    it 'monta código completo' do
      materia = build(:materia, codigo: 'MAT1234', codigo_turma: 'TA', semestre: '2025.1')
      expect(materia.codigo_completo).to eq('MAT1234-TA-2025.1')
    end

    it 'monta nome completo' do
      materia = build(:materia, nome: 'Redes', codigo_turma: 'TB')
      expect(materia.nome_completo).to eq('Redes - Turma TB')
    end
  end
end
