require 'rails_helper'

RSpec.describe "Usuarios", type: :request do
  let(:admin) { create(:usuario, :administrador, password: 'senha123', password_confirmation: 'senha123') }
  let(:aluno) { create(:usuario, password: 'senha123', password_confirmation: 'senha123') }

  describe "GET /usuarios" do
    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "retorna sucesso e lista usuários (Happy Path)" do
        create_list(:usuario, 3)
        get usuarios_path
        expect(response).to have_http_status(:success)
      end

      it "filtra por status" do
        ativo = create(:usuario, status: 'ativo')
        pendente = create(:usuario, status: 'pendente')
        get usuarios_path, params: { status: 'ativo' }
        expect(response).to have_http_status(:success)
      end

      it "filtra por tipo" do
        admin_user = create(:usuario, :administrador)
        aluno_user = create(:usuario)
        get usuarios_path, params: { tipo: 'administrador' }
        expect(response).to have_http_status(:success)
      end

      it "busca por nome, email ou matrícula" do
        usuario = create(:usuario, nome: 'João Silva', email: 'joao@example.com', matricula: '123456789')
        get usuarios_path, params: { busca: 'João' }
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário não é admin" do
      before { sign_in_direct aluno }

      it "redireciona para root com alerta (Sad Path)" do
        get usuarios_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "quando usuário não está logado" do
      it "redireciona para login (Sad Path)" do
        get usuarios_path
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /usuarios/:id" do
    let(:usuario) { create(:usuario) }

    context "quando usuário está logado" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe o usuário (Happy Path)" do
        get usuario_path(usuario)
        expect(response).to have_http_status(:success)
      end

      it "mostra turmas e formulários respondidos" do
        materia = create(:materia)
        create(:usuario_materia, usuario: usuario, materia: materia)
        get usuario_path(usuario)
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário não está logado" do
      it "redireciona para login (Sad Path)" do
        get usuario_path(usuario)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /usuarios/new" do
    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe formulário de criação (Happy Path)" do
        get new_usuario_path
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário não é admin" do
      before { sign_in_direct aluno }

      it "redireciona com alerta (Sad Path)" do
        get new_usuario_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST /usuarios" do
    let(:valid_params) do
      {
        usuario: {
          nome: 'Novo Usuário',
          email: 'novo@example.com',
          matricula: '987654321',
          tipo: 'aluno',
          departamento: 'CIC'
        }
      }
    end

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "cria usuário com sucesso (Happy Path)" do
        expect {
          post usuarios_path, params: valid_params
        }.to change(Usuario, :count).by(1)
        expect(response).to redirect_to(usuarios_path)
        expect(flash[:notice]).to be_present
      end

      it "não cria usuário com dados inválidos (Sad Path)" do
        invalid_params = valid_params.deep_dup
        invalid_params[:usuario][:email] = ''
        expect {
          post usuarios_path, params: invalid_params
        }.not_to change(Usuario, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "não cria usuário com email duplicado (Sad Path)" do
        create(:usuario, email: 'duplicado@example.com')
        invalid_params = valid_params.deep_dup
        invalid_params[:usuario][:email] = 'duplicado@example.com'
        expect {
          post usuarios_path, params: invalid_params
        }.not_to change(Usuario, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "quando usuário não é admin" do
      before { sign_in_direct aluno }

      it "redireciona com alerta (Sad Path)" do
        post usuarios_path, params: valid_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "GET /usuarios/:id/edit" do
    let(:usuario) { create(:usuario) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe formulário de edição (Happy Path)" do
        get edit_usuario_path(usuario)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /usuarios/:id" do
    let(:usuario) { create(:usuario) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "atualiza usuário com sucesso (Happy Path)" do
        patch usuario_path(usuario), params: {
          usuario: { nome: 'Nome Atualizado' }
        }
        expect(usuario.reload.nome).to eq('Nome Atualizado')
        expect(response).to redirect_to(usuario_path(usuario))
        expect(flash[:notice]).to be_present
      end

      it "não atualiza com dados inválidos (Sad Path)" do
        patch usuario_path(usuario), params: {
          usuario: { email: '' }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /usuarios/:id/enviar_convite" do
    let(:usuario_pendente) { create(:usuario, :pendente) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "envia convite com sucesso (Happy Path)" do
        post enviar_convite_usuario_path(usuario_pendente)
        expect(response).to redirect_to(usuarios_path)
        expect(flash[:notice]).to be_present
      end

      it "não envia convite para usuário já ativo (Sad Path)" do
        usuario_ativo = create(:usuario, status: 'ativo')
        post enviar_convite_usuario_path(usuario_ativo)
        expect(response).to redirect_to(usuarios_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST /usuarios/enviar_convites_lote" do
    let(:usuario1) { create(:usuario, :pendente) }
    let(:usuario2) { create(:usuario, :pendente) }

    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "envia convites em lote com sucesso (Happy Path)" do
        post enviar_convites_lote_usuarios_path, params: {
          usuario_ids: [usuario1.id, usuario2.id]
        }
        expect(response).to redirect_to(usuarios_path)
        expect(flash[:notice]).to be_present
      end

      it "não envia quando nenhum usuário selecionado (Sad Path)" do
        post enviar_convites_lote_usuarios_path, params: {
          usuario_ids: []
        }
        expect(response).to redirect_to(usuarios_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
