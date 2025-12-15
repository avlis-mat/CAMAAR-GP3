# Controller base da aplicação.
# Contém métodos auxiliares de autenticação e autorização
# compartilhados por todos os controllers.
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Métodos auxiliares para autenticação
  helper_method :current_usuario, :logged_in?, :administrador?, :aluno?, :professor?
  
  private
  
  # Retorna o usuário atualmente logado na sessão.
  #
  # @return [Usuario, nil] usuário logado ou nil se não houver sessão
  def current_usuario
    @current_usuario ||= Usuario.find_by(id: session[:usuario_id]) if session[:usuario_id]
  end
  
  # Verifica se há um usuário logado no sistema.
  #
  # @return [Boolean] true se houver usuário logado, false caso contrário
  def logged_in?
    current_usuario.present?
  end
  
  # Verifica se o usuário logado é administrador.
  #
  # @return [Boolean] true se o usuário estiver logado e for administrador, false caso contrário
  def administrador?
    logged_in? && current_usuario.administrador?
  end
  
  # Verifica se o usuário logado é aluno.
  #
  # @return [Boolean] true se o usuário estiver logado e for aluno, false caso contrário
  def aluno?
    logged_in? && current_usuario.aluno?
  end
  
  # Verifica se o usuário logado é professor.
  #
  # @return [Boolean] true se o usuário estiver logado e for professor, false caso contrário
  def professor?
    logged_in? && current_usuario.professor?
  end
  
  # Require: usuário deve estar logado.
  # Redireciona para a página de login se não houver usuário logado.
  #
  # @return [void]
  # @note Efeito colateral: redireciona para login_path se não houver usuário logado
  def require_login
    unless logged_in?
      flash[:alert] = 'Você precisa estar logado para acessar esta página.'
      redirect_to login_path # ← AJUSTE para sua rota de login
    end
  end
  
  # Require: usuário deve ser administrador.
  # Redireciona para a página inicial se o usuário não for administrador.
  #
  # @return [void]
  # @note Efeito colateral: redireciona para root_path se não for administrador
  def require_admin
    unless administrador?
      flash[:alert] = 'Acesso negado. Apenas administradores podem acessar esta página.'
      redirect_to root_path # ← AJUSTE para sua rota raiz
    end
  end
  
  # Require: usuário deve ser aluno.
  # Redireciona para a página inicial se o usuário não for aluno.
  #
  # @return [void]
  # @note Efeito colateral: redireciona para root_path se não for aluno
  def require_aluno
    unless aluno?
      flash[:alert] = 'Acesso negado. Apenas alunos podem acessar esta página.'
      redirect_to root_path
    end
  end
  
  # Require: usuário deve ser professor.
  # Redireciona para a página inicial se o usuário não for professor.
  #
  # @return [void]
  # @note Efeito colateral: redireciona para root_path se não for professor
  def require_professor
    unless professor?
      flash[:alert] = 'Acesso negado. Apenas professores podem acessar esta página.'
      redirect_to root_path
    end
  end

end
