require 'rails_helper'

RSpec.describe "TokenSenhas", type: :request do
  let(:usuario) { create(:usuario, password: 'senha123', password_confirmation: 'senha123') }

  describe "GET /definir_senha/:token" do
    context "com token válido" do
      let(:token) { create(:token_senha, usuario: usuario, tipo: 'ativacao', usado: false, expiracao: 7.days.from_now) }

      it "retorna sucesso e exibe formulário (Happy Path)" do
        get definir_senha_path(token.token)
        expect(response).to have_http_status(:success)
      end
    end

    context "com token inválido ou expirado" do
      it "redireciona para login com alerta (Sad Path)" do
        get definir_senha_path('token_invalido')
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
      end

      it "redireciona quando token já foi usado (Sad Path)" do
        token_usado = create(:token_senha, usuario: usuario, tipo: 'ativacao', usado: true)
        get definir_senha_path(token_usado.token)
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST /definir_senha/:token" do
    let(:token) { create(:token_senha, usuario: usuario, tipo: 'ativacao', usado: false, expiracao: 7.days.from_now) }

    context "com dados válidos" do
      it "define senha com sucesso (Happy Path)" do
        post "/definir_senha/#{token.token}", params: {
          senha: 'novasenha123',
          confirmacao_senha: 'novasenha123'
        }
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to be_present
        expect(token.reload.usado).to be true
        expect(usuario.reload.status).to eq('ativo')
      end
    end

    context "com dados inválidos" do
      it "não define senha quando senhas não coincidem (Sad Path)" do
        post "/definir_senha/#{token.token}", params: {
          senha: 'novasenha123',
          confirmacao_senha: 'senhadiferente'
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(token.reload.usado).to be false
      end

      it "não define senha quando senha é muito curta (Sad Path)" do
        post "/definir_senha/#{token.token}", params: {
          senha: '123',
          confirmacao_senha: '123'
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /redefinir_senha" do
    it "retorna sucesso e exibe formulário (Happy Path)" do
      get redefinir_senha_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /redefinir_senha" do
    context "com email válido" do
      it "envia email de redefinição com sucesso (Happy Path)" do
        post redefinir_senha_path, params: {
          identificacao: usuario.email
        }
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to be_present
      end
    end

    context "com email inválido" do
      it "não envia email quando usuário não existe (Sad Path)" do
        post redefinir_senha_path, params: {
          identificacao: 'naoexiste@example.com'
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "GET /resetar_senha/:token" do
    let(:token) { create(:token_senha, usuario: usuario, tipo: 'redefinicao', usado: false, expiracao: 7.days.from_now) }

    context "com token válido" do
      it "retorna sucesso e exibe formulário (Happy Path)" do
        get resetar_senha_path(token.token)
        expect(response).to have_http_status(:success)
      end
    end

    context "com token inválido" do
      it "redireciona para redefinir senha (Sad Path)" do
        get resetar_senha_path('token_invalido')
        expect(response).to redirect_to(redefinir_senha_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST /resetar_senha/:token" do
    let(:token) { create(:token_senha, usuario: usuario, tipo: 'redefinicao', usado: false, expiracao: 7.days.from_now) }

    context "com dados válidos" do
      it "redefine senha com sucesso (Happy Path)" do
        post "/resetar_senha/#{token.token}", params: {
          senha: 'novasenha123',
          confirmacao_senha: 'novasenha123'
        }
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to be_present
        expect(token.reload.usado).to be true
      end
    end

    context "com dados inválidos" do
      it "não redefine senha quando senhas não coincidem (Sad Path)" do
        post "/resetar_senha/#{token.token}", params: {
          senha: 'novasenha123',
          confirmacao_senha: 'senhadiferente'
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(token.reload.usado).to be false
      end
    end
  end
end
