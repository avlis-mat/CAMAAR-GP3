require 'rails_helper'

RSpec.describe Formulario, type: :model do
  describe 'validations' do
    it 'é válido com atributos da fábrica' do
      expect(build(:formulario)).to be_valid
    end

    it 'exige data_fim após data_inicio' do
      formulario = build(:formulario, data_inicio: Date.today, data_fim: Date.yesterday)
      expect(formulario).not_to be_valid
      expect(formulario.errors[:data_fim]).to include('deve ser posterior à data de início')
    end

    it 'exige destinatário permitido' do
      formulario = build(:formulario, destinatario: 'outsiders')
      expect(formulario).not_to be_valid
    end
  end

  describe 'scopes e disponibilidade' do
    include ActiveSupport::Testing::TimeHelpers

    around do |example|
      travel_to Date.new(2025, 1, 10) { example.run }
    end

    it 'retorna apenas formulários ativos' do
      ativo = create(:formulario, status: 'ativo')
      create(:formulario, status: 'rascunho')
      expect(Formulario.ativos).to contain_exactly(ativo)
    end

    it 'retorna formulários disponíveis no período' do
      disponivel = create(:formulario, data_inicio: Date.today - 1, data_fim: Date.today + 1, status: 'ativo')
      create(:formulario, :encerrado, data_inicio: Date.today - 5, data_fim: Date.today - 1)
      expect(Formulario.disponiveis).to contain_exactly(disponivel)
    end

    it '#disponivel? considera status e janela de datas' do
      formulario = build(:formulario, status: 'ativo', data_inicio: Date.today - 1, data_fim: Date.today + 1)
      expect(formulario.disponivel?).to be true

      formulario.status = 'rascunho'
      expect(formulario.disponivel?).to be false
    end
  end

  describe '#disponivel_para?' do
    include ActiveSupport::Testing::TimeHelpers

    around do |example|
      travel_to Date.new(2025, 1, 10) { example.run }
    end

    let(:materia) { create(:materia) }
    let(:modelo) { create(:modelo) }

    it 'permite docentes da matéria quando destinatário é docentes' do
      professor = create(:usuario, :professor)
      create(:usuario_materia, usuario: professor, materia: materia, papel: 'professor')
      formulario = create(:formulario, modelo: modelo, materia: materia, destinatario: 'docentes')

      expect(formulario.disponivel_para?(professor)).to be true
    end

    it 'permite discentes da matéria quando destinatário é dicentes' do
      aluno = create(:usuario)
      create(:usuario_materia, usuario: aluno, materia: materia, papel: 'aluno')
      formulario = create(:formulario, modelo: modelo, materia: materia, destinatario: 'dicentes')

      expect(formulario.disponivel_para?(aluno)).to be true
    end

    it 'permite qualquer vinculado à matéria quando destinatário é todos' do
      usuario = create(:usuario)
      create(:usuario_materia, usuario: usuario, materia: materia, papel: 'aluno')
      formulario = create(:formulario, modelo: modelo, materia: materia, destinatario: 'todos')

      expect(formulario.disponivel_para?(usuario)).to be true
    end

    it 'nega quando usuário não está vinculado à matéria' do
      usuario = create(:usuario)
      formulario = create(:formulario, modelo: modelo, materia: materia, destinatario: 'todos')

      expect(formulario.disponivel_para?(usuario)).to be false
    end
  end

  describe '#ja_respondido_por?' do
    it 'retorna true quando já existe resposta do usuário' do
      formulario = create(:formulario)
      questao = create(:questao, modelo: formulario.modelo)
      usuario = create(:usuario)
      create(:resposta, formulario: formulario, questao: questao, usuario: usuario)

      expect(formulario.ja_respondido_por?(usuario)).to be true
    end

    it 'retorna false quando não existe resposta' do
      formulario = create(:formulario)
      usuario = create(:usuario)
      expect(formulario.ja_respondido_por?(usuario)).to be false
    end
  end
end
