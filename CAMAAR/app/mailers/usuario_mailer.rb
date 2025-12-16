# Mailer responsável pelo envio de emails relacionados a usuários.
# Envia convites de cadastro e emails de redefinição de senha.
class UsuarioMailer < ApplicationMailer
  default from: 'noreply@camaar.unb.br'
  
  # Envia email de convite para cadastro (definir senha pela primeira vez).
  #
  # @param usuario [Usuario] usuário que receberá o convite
  # @param token [TokenSenha] token de ativação para definir senha
  # @return [Mail::Message] mensagem de email preparada
  # @note Efeito colateral: envia email para o usuário com link de ativação
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
  
  # Envia email para redefinição de senha.
  #
  # @param usuario [Usuario] usuário que solicitou redefinição
  # @param token [TokenSenha] token de redefinição
  # @return [Mail::Message] mensagem de email preparada
  # @note Efeito colateral: envia email para o usuário com link de redefinição
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
