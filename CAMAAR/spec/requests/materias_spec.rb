require 'rails_helper'

RSpec.describe "Materias", type: :request do
  let(:admin) { create(:usuario, :administrador, password: 'senha123', password_confirmation: 'senha123') }
  let(:aluno) { create(:usuario, password: 'senha123', password_confirmation: 'senha123') }

  describe "GET /materias" do
    context "quando usuário está logado" do
      before { sign_in_direct admin }

      it "retorna sucesso e lista matérias (Happy Path)" do
        create_list(:materia, 3)
        get materias_path
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário não está logado" do
      it "redireciona para login (Sad Path)" do
        get materias_path
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /materias/:id" do
    let(:materia) { create(:materia) }

    context "quando usuário está logado" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe a matéria (Happy Path)" do
        get materia_path(materia)
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário não está logado" do
      it "redireciona para login (Sad Path)" do
        get materia_path(materia)
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
