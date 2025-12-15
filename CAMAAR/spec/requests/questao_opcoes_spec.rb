require 'rails_helper'

RSpec.describe "QuestaoOpcoes", type: :request do
  # Questão opções são gerenciadas através de nested attributes nas questões
  # Então não há rotas diretas para elas, mas podemos testar através das questões
  
  let(:admin) { create(:usuario, :administrador, password: 'senha123', password_confirmation: 'senha123') }
  let(:modelo) { create(:modelo, usuario: admin) }
  let(:questao) { create(:questao, :multipla_escolha, modelo: modelo) }

  describe "Criação através de nested attributes" do
    context "quando usuário é admin" do
      before { sign_in_direct admin }

      it "cria opções junto com questão múltipla escolha (Happy Path)" do
        valid_params = {
          questao: {
            enunciado: 'Questão com opções',
            tipo: 'multipla_escolha',
            ordem: 1,
            versao: 1,
            status: 'ativo',
            questao_opcoes_attributes: [
              { texto: 'Opção 1', ordem: 1 },
              { texto: 'Opção 2', ordem: 2 }
            ]
          }
        }
        
        expect {
          post modelo_questoes_path(modelo), params: valid_params
        }.to change(QuestaoOpcao, :count).by(2)
      end

      it "não cria questão múltipla escolha sem opções suficientes (Sad Path)" do
        invalid_params = {
          questao: {
            enunciado: 'Questão sem opções',
            tipo: 'multipla_escolha',
            ordem: 1,
            versao: 1,
            status: 'ativo',
            questao_opcoes_attributes: [
              { texto: 'Opção única', ordem: 1 }
            ]
          }
        }
        
        expect {
          post modelo_questoes_path(modelo), params: invalid_params
        }.not_to change(Questao, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
