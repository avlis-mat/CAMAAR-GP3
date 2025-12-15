require 'rails_helper'

RSpec.describe "Modelos", type: :request do
  let(:admin) { create(:usuario, :administrador, password: 'senha123', password_confirmation: 'senha123') }
  let(:aluno) { create(:usuario, password: 'senha123', password_confirmation: 'senha123') }

  describe "GET /modelos" do
    context "quando usuário está logado" do
      before { sign_in_direct admin }

      it "retorna sucesso e lista modelos (Happy Path)" do
        create_list(:modelo, 3, usuario: admin)
        get modelos_path
        expect(response).to have_http_status(:success)
      end

      it "filtra por busca" do
        modelo = create(:modelo, nome: 'Modelo Teste', usuario: admin)
        get modelos_path, params: { busca: 'Teste' }
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário não está logado" do
      it "redireciona para login (Sad Path)" do
        get modelos_path
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /modelos/:id" do
    let(:modelo) { create(:modelo, usuario: admin) }

    context "quando usuário está logado" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe o modelo (Happy Path)" do
        get modelo_path(modelo)
        expect(response).to have_http_status(:success)
      end

      it "mostra questões do modelo" do
        create_list(:questao, 3, modelo: modelo)
        get modelo_path(modelo)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /modelos/new" do
    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe formulário de criação (Happy Path)" do
        get new_modelo_path
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário não é admin" do
      before { sign_in_direct aluno }

      it "redireciona com alerta (Sad Path)" do
        get new_modelo_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST /modelos" do
    let(:valid_params) do
      {
        modelo: {
          nome: 'Novo Modelo',
          descricao: 'Descrição do modelo',
          status: 'ativo',
          questoes_attributes: [
            {
              enunciado: 'Questão 1',
              tipo: 'dissertativa',
              ordem: 1,
              versao: 1,
              status: 'ativo'
            }
          ]
        }
      }
    end

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "cria modelo com sucesso (Happy Path)" do
        expect {
          post modelos_path, params: valid_params
        }.to change(Modelo, :count).by(1)
        expect(response).to redirect_to(Modelo.last)
        expect(flash[:notice]).to be_present
      end

      it "não cria modelo com dados inválidos (Sad Path)" do
        invalid_params = valid_params.deep_dup
        invalid_params[:modelo][:nome] = ''
        expect {
          post modelos_path, params: invalid_params
        }.not_to change(Modelo, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /modelos/:id/edit" do
    let(:modelo) { create(:modelo, usuario: admin) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe formulário de edição (Happy Path)" do
        get edit_modelo_path(modelo)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /modelos/:id" do
    let(:modelo) { create(:modelo, usuario: admin) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "atualiza modelo com sucesso (Happy Path)" do
        patch modelo_path(modelo), params: {
          modelo: { nome: 'Nome Atualizado' }
        }
        expect(modelo.reload.nome).to eq('Nome Atualizado')
        expect(response).to redirect_to(modelo_path(modelo))
        expect(flash[:notice]).to be_present
      end

      it "não atualiza com dados inválidos (Sad Path)" do
        patch modelo_path(modelo), params: {
          modelo: { nome: '' }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /modelos/:id" do
    let(:modelo) { create(:modelo, usuario: admin) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "exclui modelo com sucesso (Happy Path)" do
        delete modelo_path(modelo)
        expect(Modelo.find_by(id: modelo.id)).to be_nil
        expect(response).to redirect_to(modelos_path)
        expect(flash[:notice]).to be_present
      end
    end
  end
end
