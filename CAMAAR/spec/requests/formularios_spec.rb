require 'rails_helper'

RSpec.describe "Formularios", type: :request do
  let(:admin) { create(:usuario, :administrador, password: 'senha123', password_confirmation: 'senha123') }
  let(:aluno) { create(:usuario, password: 'senha123', password_confirmation: 'senha123') }
  let(:professor) { create(:usuario, :professor, password: 'senha123', password_confirmation: 'senha123') }
  let(:modelo) { create(:modelo, usuario: admin) }
  let(:materia) { create(:materia) }

  describe "GET /formularios" do
    context "quando usuário está logado como admin" do
      before { sign_in_direct admin }

      it "retorna sucesso e lista todos os formulários" do
        create_list(:formulario, 3, usuario: admin, modelo: modelo)
        get formularios_path
        expect(response).to have_http_status(:success)
      end

      it "filtra por status" do
        ativo = create(:formulario, status: 'ativo', usuario: admin, modelo: modelo)
        rascunho = create(:formulario, status: 'rascunho', usuario: admin, modelo: modelo)
        get formularios_path, params: { status: 'ativo' }
        expect(response).to have_http_status(:success)
      end

      it "filtra por matéria" do
        formulario = create(:formulario, materia: materia, usuario: admin, modelo: modelo)
        get formularios_path, params: { materia_id: materia.id }
        expect(response).to have_http_status(:success)
      end

      it "busca por título" do
        formulario = create(:formulario, titulo: 'Avaliação de Teste', usuario: admin, modelo: modelo)
        get formularios_path, params: { busca: 'Teste' }
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário está logado como aluno" do
      before { sign_in_direct aluno }

      it "retorna apenas formulários ativos" do
        ativo = create(:formulario, status: 'ativo', usuario: admin, modelo: modelo)
        rascunho = create(:formulario, status: 'rascunho', usuario: admin, modelo: modelo)
        get formularios_path
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário não está logado" do
      it "redireciona para login" do
        get formularios_path
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /formularios/:id" do
    let(:formulario) { create(:formulario, usuario: admin, modelo: modelo) }

    context "quando usuário está logado" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe o formulário" do
        get formulario_path(formulario)
        expect(response).to have_http_status(:success)
      end

      it "mostra estatísticas do formulário" do
        questao = create(:questao, modelo: modelo)
        create(:resposta, formulario: formulario, questao: questao, usuario: aluno)
        get formulario_path(formulario)
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário não está logado" do
      it "redireciona para login" do
        get formulario_path(formulario)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /formularios/new" do
    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe formulário de criação" do
        get new_formulario_path
        expect(response).to have_http_status(:success)
      end

      it "pré-seleciona modelo quando fornecido" do
        get new_formulario_path, params: { modelo_id: modelo.id }
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário não é admin" do
      before { sign_in_direct aluno }

      it "redireciona para root com alerta" do
        get new_formulario_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST /formularios" do
    let(:valid_params) do
      {
        formulario: {
          modelo_id: modelo.id,
          materia_id: materia.id,
          titulo: 'Novo Formulário',
          instrucoes: 'Instruções do formulário',
          data_inicio: Date.today,
          data_fim: Date.today + 7.days,
          destinatario: 'todos',
          status: 'rascunho'
        }
      }
    end

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "cria formulário com sucesso (Happy Path)" do
        expect {
          post formularios_path, params: valid_params
        }.to change(Formulario, :count).by(1)
        expect(response).to redirect_to(Formulario.last)
        expect(flash[:notice]).to be_present
      end

      it "não cria formulário com dados inválidos (Sad Path)" do
        invalid_params = valid_params.deep_dup
        invalid_params[:formulario][:titulo] = ''
        expect {
          post formularios_path, params: invalid_params
        }.not_to change(Formulario, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "não cria formulário com data_fim anterior a data_inicio" do
        invalid_params = valid_params.deep_dup
        invalid_params[:formulario][:data_fim] = Date.yesterday
        expect {
          post formularios_path, params: invalid_params
        }.not_to change(Formulario, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "quando usuário não é admin" do
      before { sign_in_direct aluno }

      it "redireciona com alerta" do
        post formularios_path, params: valid_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "GET /formularios/:id/edit" do
    let(:formulario) { create(:formulario, usuario: admin, modelo: modelo) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe formulário de edição" do
        get edit_formulario_path(formulario)
        expect(response).to have_http_status(:success)
      end

      it "não permite editar formulário ativo com respostas" do
        formulario.update(status: 'ativo')
        questao = create(:questao, modelo: modelo)
        create(:resposta, formulario: formulario, questao: questao, usuario: aluno)
        get edit_formulario_path(formulario)
        expect(response).to redirect_to(formulario_path(formulario))
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PATCH /formularios/:id" do
    let(:formulario) { create(:formulario, usuario: admin, modelo: modelo) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "atualiza formulário com sucesso (Happy Path)" do
        patch formulario_path(formulario), params: {
          formulario: { titulo: 'Título Atualizado' }
        }
        expect(formulario.reload.titulo).to eq('Título Atualizado')
        expect(response).to redirect_to(formulario_path(formulario))
        expect(flash[:notice]).to be_present
      end

      it "não atualiza com dados inválidos (Sad Path)" do
        patch formulario_path(formulario), params: {
          formulario: { titulo: '' }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /formularios/:id" do
    let(:formulario) { create(:formulario, usuario: admin, modelo: modelo) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "exclui formulário sem respostas (Happy Path)" do
        delete formulario_path(formulario)
        expect(Formulario.find_by(id: formulario.id)).to be_nil
        expect(response).to redirect_to(formularios_path)
        expect(flash[:notice]).to be_present
      end

      it "não exclui formulário com respostas (Sad Path)" do
        questao = create(:questao, modelo: modelo)
        create(:resposta, formulario: formulario, questao: questao, usuario: aluno)
        expect {
          delete formulario_path(formulario)
        }.not_to change(Formulario, :count)
        expect(response).to redirect_to(formulario_path(formulario))
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PATCH /formularios/:id/ativar" do
    let(:formulario) { create(:formulario, status: 'rascunho', usuario: admin, modelo: modelo) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "ativa formulário em rascunho (Happy Path)" do
        patch ativar_formulario_path(formulario)
        expect(formulario.reload.status).to eq('ativo')
        expect(response).to redirect_to(formulario_path(formulario))
        expect(flash[:notice]).to be_present
      end

      it "não ativa formulário que não está em rascunho (Sad Path)" do
        formulario.update(status: 'ativo')
        patch ativar_formulario_path(formulario)
        expect(response).to redirect_to(formulario_path(formulario))
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PATCH /formularios/:id/desativar" do
    let(:formulario) { create(:formulario, status: 'ativo', usuario: admin, modelo: modelo) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "desativa formulário ativo (Happy Path)" do
        patch desativar_formulario_path(formulario)
        expect(formulario.reload.status).to eq('inativo')
        expect(response).to redirect_to(formulario_path(formulario))
        expect(flash[:notice]).to be_present
      end

      it "não desativa formulário que não está ativo (Sad Path)" do
        formulario.update(status: 'rascunho')
        patch desativar_formulario_path(formulario)
        expect(response).to redirect_to(formulario_path(formulario))
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PATCH /formularios/:id/encerrar" do
    let(:formulario) { create(:formulario, status: 'ativo', usuario: admin, modelo: modelo) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "encerra formulário ativo (Happy Path)" do
        patch encerrar_formulario_path(formulario)
        expect(formulario.reload.status).to eq('encerrado')
        expect(response).to redirect_to(formulario_path(formulario))
        expect(flash[:notice]).to be_present
      end

      it "não encerra formulário que não está ativo (Sad Path)" do
        formulario.update(status: 'rascunho')
        patch encerrar_formulario_path(formulario)
        expect(response).to redirect_to(formulario_path(formulario))
        expect(flash[:alert]).to be_present
      end
    end
  end
end
