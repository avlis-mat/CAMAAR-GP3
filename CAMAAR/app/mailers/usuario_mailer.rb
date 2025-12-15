# app/mailers/usuario_mailer.rb
class UsuarioMailer < ApplicationMailer
  default from: 'noreply@camaar.unb.br'
  
  # Email de convite para cadastro (definir senha pela primeira vez)
  def convite_cadastro(usuario, token)
    @usuario = usuario
    @token = token
    Rails.application.routes.default_url_options = { host: 'localhost', port: 3000 }  # Temporário
    Rails.logger.info "Mailer: Token passado: #{token.inspect}"  # Log do objeto token
    Rails.logger.info "Mailer: Token.token: #{token.token}" 
    @url = definir_senha_url(token: token.token)
    
    mail(
      to: usuario.email,
      subject: '[CAMAAR] Convite para cadastro no sistema'
    )
  end
  
  # Email para redefinição de senha
  def redefinir_senha(usuario, token)
    @usuario = usuario
    @token = token
    @url = resetar_senha_url(token: token.token)
    
    mail(
      to: usuario.email,
      subject: '[CAMAAR] Redefinição de senha'
    )
  end
end
