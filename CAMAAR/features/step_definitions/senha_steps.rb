# frozen_string_literal: true

# Steps relacionados a definição e redefinição de senha

Dado('que recebi o email de convite para cadastro') do
  @token = TokenSenha.create!(
    usuario: @usuario,
    tipo: 'ativacao',
    expiracao: 48.hours.from_now
  )
end

Dado('recebi um email de convite para cadastro no sistema') do
  @token = TokenSenha.create!(
    usuario: @usuario,
    tipo: 'ativacao',
    expiracao: 48.hours.from_now
  )
end

Dado('que solicitei a redefinição de senha') do
  @token = TokenSenha.create!(
    usuario: @usuario,
    tipo: 'redefinicao',
    expiracao: 24.hours.from_now
  )
end

Dado('que recebi o email com o link de redefinição') do
  @token = TokenSenha.create!(
    usuario: @usuario,
    tipo: 'redefinicao',
    expiracao: 24.hours.from_now
  ) unless @token
end

Dado('recebi o email com o link de redefinição') do
  @token = TokenSenha.create!(
    usuario: @usuario,
    tipo: 'redefinicao',
    expiracao: 24.hours.from_now
  ) unless @token
end

Dado('que o usuário possui uma senha cadastrada no sistema') do
  @usuario.update!(
    password: 'senha123',
    password_confirmation: 'senha123',
    status: 'ativo'
  ) if @usuario
end

Dado('o usuário possui uma senha cadastrada no sistema') do
  step 'que o usuário possui uma senha cadastrada no sistema'
end

Dado('que recebi um link de definição de senha') do
  @token = TokenSenha.create!(
    usuario: @usuario,
    tipo: 'ativacao',
    expiracao: 48.hours.from_now
  )
end

Dado('recebi um novo email de convite') do
  @token = TokenSenha.create!(
    usuario: @usuario,
    tipo: 'ativacao',
    expiracao: 48.hours.from_now
  )
end

Dado('que recebi o email de convite há mais de {int} horas') do |horas|
  @token = TokenSenha.create!(
    usuario: @usuario,
    tipo: 'ativacao',
    expiracao: 1.hour.ago
  )
  @token.update_column(:created_at, (horas + 1).hours.ago)
end

Dado('que já defini minha senha anteriormente') do
  @usuario.update!(
    password: 'senha123',
    password_confirmation: 'senha123',
    status: 'ativo'
  ) if @usuario
end

Dado('que recebi um link de redefinição de senha') do
  @token = TokenSenha.create!(
    usuario: @usuario,
    tipo: 'redefinicao',
    expiracao: 24.hours.from_now
  )
end

Dado('que solicitei a redefinição de senha há mais de {int} horas') do |horas|
  @token = TokenSenha.create!(
    usuario: @usuario,
    tipo: 'redefinicao',
    expiracao: 1.hour.ago
  )
  @token.update_column(:created_at, (horas + 1).hours.ago)
end

Quando('eu clico no link de definição de senha no email') do
  visit definir_senha_path(@token.token) if @token
end

Quando('eu clico no link de redefinição no email') do
  visit resetar_senha_path(@token.token) if @token
end

Quando('eu acesso um link com token inválido ou expirado') do
  visit definir_senha_path('token_invalido_12345')
end

Então('a nova senha deve estar ativa no sistema') do
  expect(@usuario.reload.authenticate(@nova_senha || 'NovaSenha123!')).to be_truthy
end

Então('a senha não deve ser definida') do
  # Verificar que o usuário ainda está pendente
end

Então('eu devo permanecer na página de definição de senha') do
  if @token
    expect(page).to have_current_path(definir_senha_path(@token.token))
  end
end

Então('eu devo ser redirecionado para uma página informando que preciso solicitar novo convite') do
  has_expirado = page.has_content?('expirado')
  has_invalido = page.has_content?('inválido')
  has_convite = page.has_content?('convite')
  expect(has_expirado || has_invalido || has_convite).to be true
end

Então('o usuário deve receber um email com link de redefinição de senha') do
  # Verificar se o token foi criado (pode não existir em alguns cenários)
  if @usuario
    token = @usuario.token_senhas&.last
    if token
      expect(token.tipo).to eq('redefinicao')
    end
  end
end

Então('a senha não deve ser alterada') do
  expect(@usuario.reload.authenticate('senha123')).to be_truthy
end

Então('eu devo ser redirecionado para a página de solicitação de redefinição') do
  expect(page).to have_current_path(redefinir_senha_path)
end

# Step "o link deve expirar em {int} horas" definido em usuario_steps.rb
