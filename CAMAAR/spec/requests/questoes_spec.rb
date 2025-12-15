require 'rails_helper'

RSpec.describe "Questoes", type: :request do
  let(:admin) { create(:usuario, :administrador, password: 'senha123', password_confirmation: 'senha123') }
  let(:aluno) { create(:usuario, password: 'senha123', password_confirmation: 'senha123') }
  let(:modelo) { create(:modelo, usuario: admin) }

  describe "GET /modelos/:modelo_id/questoes/new" do
    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe formulário de criação (Happy Path)" do
        get new_modelo_questao_path(modelo)
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário não é admin" do
      before { sign_in_direct aluno }

      it "redireciona com alerta (Sad Path)" do
        get new_modelo_questao_path(modelo)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST /modelos/:modelo_id/questoes" do
    let(:valid_params) do
      {
        questao: {
          enunciado: 'Nova questão',
          tipo: 'dissertativa',
          ordem: 1,
          versao: 1,
          status: 'ativo'
        }
      }
    end

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "cria questão com sucesso (Happy Path)" do
        expect {
          post modelo_questoes_path(modelo), params: valid_params
        }.to change(Questao, :count).by(1)
        expect(response).to redirect_to(modelo_path(modelo))
      end

      it "não cria questão com dados inválidos (Sad Path)" do
        invalid_params = valid_params.deep_dup
        invalid_params[:questao][:enunciado] = ''
        expect {
          post modelo_questoes_path(modelo), params: invalid_params
        }.not_to change(Questao, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /modelos/:modelo_id/questoes/:id/edit" do
    let(:questao) { create(:questao, modelo: modelo) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe formulário de edição (Happy Path)" do
        get edit_modelo_questao_path(modelo, questao)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /modelos/:modelo_id/questoes/:id" do
    let(:questao) { create(:questao, modelo: modelo) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "atualiza questão com sucesso (Happy Path)" do
        patch modelo_questao_path(modelo, questao), params: {
          questao: { enunciado: 'Enunciado Atualizado' }
        }
        expect(questao.reload.enunciado).to eq('Enunciado Atualizado')
        expect(response).to redirect_to(modelo_path(modelo))
      end

      it "não atualiza com dados inválidos (Sad Path)" do
        patch modelo_questao_path(modelo, questao), params: {
          questao: { enunciado: '' }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /modelos/:modelo_id/questoes/:id" do
    let(:questao) { create(:questao, modelo: modelo) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "exclui questão com sucesso (Happy Path)" do
        delete modelo_questao_path(modelo, questao)
        expect(Questao.find_by(id: questao.id)).to be_nil
        expect(response).to redirect_to(modelo_path(modelo))
      end
    end
  end
end
