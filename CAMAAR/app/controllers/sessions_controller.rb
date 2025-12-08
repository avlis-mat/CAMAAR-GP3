class SessionsController < ApplicationController
 # skip_before_action :require_login, only: [:new, :create], if: :require_login_defined?

  def new
    if logged_in?
      redirect_to root_path, notice: 'Você já está logado'
    end
  end

  def create
    usuario = Usuario.find_by(email: params[:email])
    
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

  def destroy
    session[:usuario_id] = nil
    redirect_to login_path, notice: 'Logout realizado com sucesso'
  end

  private

  def require_login_defined?
    respond_to?(:require_login)
  end
end
