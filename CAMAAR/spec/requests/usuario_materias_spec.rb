require 'rails_helper'

RSpec.describe "UsuarioMaterias", type: :request do
  # UsuarioMaterias são gerenciadas através de outras rotas
  # Não há rotas diretas para este recurso, mas podemos testar através de associações
  
  let(:admin) { create(:usuario, :administrador, password: 'senha123', password_confirmation: 'senha123') }
  let(:aluno) { create(:usuario, password: 'senha123', password_confirmation: 'senha123') }
  let(:materia) { create(:materia) }

  describe "Associações através de modelos" do
    it "cria associação usuário-matéria corretamente" do
      usuario_materia = create(:usuario_materia, usuario: aluno, materia: materia, papel: 'aluno')
      expect(usuario_materia).to be_valid
      expect(aluno.materias).to include(materia)
    end

    it "valida papel permitido" do
      usuario_materia = build(:usuario_materia, papel: 'inválido')
      expect(usuario_materia).not_to be_valid
    end
  end
end
