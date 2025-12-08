require 'rails_helper'

RSpec.describe TokenSenha, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe 'callbacks' do
    it 'gera token e data de expiração ao criar' do
      token = create(:token_senha)
      expect(token.token).to be_present
      expect(token.expiracao).to be > Time.current
    end
  end

  describe '#valido?' do
    it 'retorna true para tokens não usados e não expirados' do
      token = create(:token_senha)
      expect(token.valido?).to be true
    end

    it 'retorna false para tokens expirados' do
      token = create(:token_senha)
      token.update!(expiracao: 1.hour.ago)
      expect(token.valido?).to be false
    end
  end

  describe '.validos' do
    it 'inclui apenas tokens não usados e dentro da validade' do
      valido = create(:token_senha)
      create(:token_senha, usado: true)
      expirado = create(:token_senha)
      expirado.update!(expiracao: 1.hour.ago)

      expect(TokenSenha.validos).to contain_exactly(valido)
    end
  end

  describe '.do_tipo' do
    it 'filtra por tipo' do
      redefinicao = create(:token_senha, :redefinicao)
      create(:token_senha, tipo: 'ativacao')
      expect(TokenSenha.do_tipo('redefinicao')).to contain_exactly(redefinicao)
    end
  end

  describe '#usar!' do
    it 'marca token como usado' do
      token = create(:token_senha)
      token.usar!
      expect(token.reload.usado).to be true
    end
  end
end
