class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_usuario, :logged_in?, :administrador?

  private

  def current_usuario
    @current_usuario ||= Usuario.find_by(id: session[:usuario_id]) if session[:usuario_id]
  end
  
  def logged_in?
    current_usuario.present?
  end
  
  def administrador?
    current_usuario&.administrador?
  end
  
  def require_login
    unless logged_in?
      redirect_to login_path, alert: 'Você precisa fazer login para continuar'
    end
  end
  
  def require_admin
    require_login
    unless current_usuario&.administrador?
      redirect_to root_path, alert: 'Acesso negado'
    end
  end

end
