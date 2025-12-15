# Controller responsável pelo gerenciamento de sessões de usuário.
# Lida com login, logout e autenticação de usuários.
class SessionsController < ApplicationController
 # skip_before_action :require_login, only: [:new, :create], if: :require_login_defined?

  # Exibe a página de login.
  # Redireciona para a página inicial se o usuário já estiver logado.
  #
  # @return [void]
  # @note Efeito colateral: pode redirecionar para root_path se já houver usuário logado
  def new
    if logged_in?
      redirect_to root_path, notice: 'Você já está logado'
    end
  end

  # Processa o login do usuário.
  # Autentica o usuário por email ou matrícula e senha.
  # Cria a sessão se a autenticação for bem-sucedida e o usuário estiver ativo.
  #
  # @return [void]
  # @note Efeito colateral:
  #   - Cria sessão (session[:usuario_id]) se autenticação bem-sucedida
  #   - Redireciona para root_path em caso de sucesso
  #   - Renderiza :new em caso de erro
  def create
    usuario = Usuario.find_by(email: params[:login]) || Usuario.find_by(matricula: params[:login])
    
    if usuario&.authenticate(params[:password])
      if usuario.ativo?
        session[:usuario_id] = usuario.id
        redirect_to root_path, notice: 'Login realizado com sucesso'
      else
        flash.now[:alert] = 'Sua conta ainda não está ativa'
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = 'Email ou senha inválidos'
      render :new, status: :unprocessable_entity
    end
  end

  # Processa o logout do usuário.
  # Remove a sessão atual e redireciona para a página de login.
  #
  # @return [void]
  # @note Efeito colateral:
  #   - Remove sessão (session[:usuario_id] = nil)
  #   - Redireciona para login_path
  def destroy
    session[:usuario_id] = nil
    redirect_to login_path, notice: 'Logout realizado com sucesso'
  end

  private

  # Verifica se o método require_login está definido.
  #
  # @return [Boolean] true se o método require_login existir, false caso contrário
  def require_login_defined?
    respond_to?(:require_login)
  end
end
