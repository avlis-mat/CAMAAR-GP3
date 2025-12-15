require 'rails_helper'

RSpec.describe "Respostas", type: :request do
  let(:admin) { create(:usuario, :administrador, password: 'senha123', password_confirmation: 'senha123') }
  let(:aluno) { create(:usuario, password: 'senha123', password_confirmation: 'senha123') }
  let(:professor) { create(:usuario, :professor, password: 'senha123', password_confirmation: 'senha123') }
  let(:modelo) { create(:modelo, usuario: admin) }
  let(:materia) { create(:materia) }
  let(:formulario) { create(:formulario, usuario: admin, modelo: modelo, materia: materia, status: 'ativo', data_inicio: Date.today - 1, data_fim: Date.today + 7) }

  describe "GET /formularios/:id/responder" do
    context "quando usuário é aluno e formulário está disponível" do
      before { sign_in_direct aluno }

      it "retorna sucesso e exibe formulário para responder (Happy Path)" do
        questao = create(:questao, modelo: modelo)
        get responder_formulario_path(formulario)
        expect(response).to have_http_status(:success)
      end

      it "não permite responder formulário já respondido (Sad Path)" do
        questao = create(:questao, modelo: modelo)
        create(:resposta, formulario: formulario, questao: questao, usuario: aluno)
        get responder_formulario_path(formulario)
        expect(response).to redirect_to(formularios_path)
        expect(flash[:alert]).to be_present
      end

      it "não permite responder formulário não disponível (Sad Path)" do
        formulario.update(status: 'rascunho')
        get responder_formulario_path(formulario)
        expect(response).to redirect_to(formularios_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "quando usuário não está logado" do
      it "redireciona para login (Sad Path)" do
        get responder_formulario_path(formulario)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "POST /formularios/:formulario_id/respostas" do
    let(:questao1) { create(:questao, modelo: modelo, tipo: 'dissertativa') }
    let(:questao2) { create(:questao, :multipla_escolha, modelo: modelo) }
    let(:opcao) { questao2.questao_opcoes.first }

    let(:valid_params) do
      {
        respostas: {
          questao1.id.to_s => { conteudo: 'Resposta dissertativa' },
          questao2.id.to_s => { questao_opcao_id: opcao.id }
        }
      }
    end

    context "quando usuário é aluno e formulário está disponível" do
      before { sign_in_direct aluno }

      it "cria respostas com sucesso (Happy Path)" do
        expect {
          post formulario_respostas_path(formulario), params: valid_params
        }.to change(Resposta, :count).by(2)
        expect(response).to redirect_to(formularios_path)
        expect(flash[:notice]).to be_present
      end

      it "não cria respostas com dados inválidos (Sad Path)" do
        invalid_params = {
          respostas: {
            questao1.id.to_s => { conteudo: '' }
          }
        }
        expect {
          post formulario_respostas_path(formulario), params: invalid_params
        }.not_to change(Resposta, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "não permite responder duas vezes (Sad Path)" do
        create(:resposta, formulario: formulario, questao: questao1, usuario: aluno)
        expect {
          post formulario_respostas_path(formulario), params: valid_params
        }.not_to change(Resposta, :count)
        expect(response).to redirect_to(formularios_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "GET /formularios/:id/resultados" do
    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "retorna sucesso e exibe resultados (Happy Path)" do
        questao = create(:questao, modelo: modelo)
        create(:resposta, formulario: formulario, questao: questao, usuario: aluno)
        get resultados_formulario_path(formulario)
        expect(response).to have_http_status(:success)
      end
    end

    context "quando usuário não é admin" do
      before { sign_in_direct aluno }

      it "redireciona com alerta (Sad Path)" do
        get resultados_formulario_path(formulario)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
