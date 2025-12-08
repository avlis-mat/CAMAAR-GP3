class HomeController < ApplicationController
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
  
  def load_admin_dashboard
    @usuarios_pendentes_count = Usuario.where(status: 'pendente').count
    @formularios_ativos_count = Formulario.where(status: 'ativo').count
    @modelos_count = Modelo.count
  end
  
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
