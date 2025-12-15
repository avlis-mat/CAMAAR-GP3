# Controller responsável pela página inicial (dashboard) do sistema.
# Exibe diferentes informações dependendo do tipo de usuário logado.
class HomeController < ApplicationController
  # Exibe a página inicial do sistema.
  # Carrega informações diferentes para administradores e usuários comuns.
  #
  # @return [void]
  def index
    if logged_in?
      if current_usuario.administrador?
        load_admin_dashboard
      else
        load_user_dashboard
      end
    end
  end

  private
  
  # Carrega dados do dashboard para administradores.
  # Define variáveis de instância com contadores de usuários pendentes,
  # formulários ativos e modelos.
  #
  # @return [void]
  # @note Define variáveis de instância:
  #   - @usuarios_pendentes_count: número de usuários pendentes
  #   - @formularios_ativos_count: número de formulários ativos
  #   - @modelos_count: número total de modelos
  def load_admin_dashboard
    @usuarios_pendentes_count = Usuario.where(status: 'pendente').count
    @formularios_ativos_count = Formulario.where(status: 'ativo').count
    @modelos_count = Modelo.count
  end
  
  # Carrega dados do dashboard para usuários comuns (alunos/professores).
  # Define variável de instância com formulários disponíveis para resposta.
  #
  # @return [void]
  # @note Define variável de instância:
  #   - @formularios_disponiveis: lista de formulários ativos e vigentes
  #     relacionados às matérias do usuário e ainda não respondidos
  def load_user_dashboard
    @formularios_disponiveis = Formulario
      .where(status: 'ativo')
      .where('data_inicio <= ? AND data_fim >= ?', Date.today, Date.today)
      .joins(materia: :usuario_materias)
      .where(usuario_materias: { usuario: current_usuario })
      .where.not(id: current_usuario.respostas.select(:formulario_id).distinct)
      .distinct
  rescue
    @formularios_disponiveis = []
  end
end
