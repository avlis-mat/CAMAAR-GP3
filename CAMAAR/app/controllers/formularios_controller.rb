class FormulariosController < ApplicationController
  before_action :require_login
  before_action :require_admin, only: [:new, :create, :resultados]
  before_action :set_formulario, only: [:show, :resultados, :destroy]

  def index
    if administrador?
      @formularios = Formulario.includes(:modelo, :materia).order(created_at: :desc)
    else
      # Alunos veem formulários disponíveis para suas turmas
      @formularios = Formulario.includes(:modelo, :materia)
                               .ativos
                               .select { |f| f.disponivel_para?(current_usuario) }
    end
  end

  def show
    unless administrador? || @formulario.disponivel_para?(current_usuario)
      redirect_to formularios_path, alert: "Você não tem permissão para acessar este formulário."
    end
  end

  def new
    @formulario = Formulario.new
    @modelos = Modelo.where(status: 'ativo')
    @materias = Materia.order(:codigo)
  end

  def create
    @formulario = Formulario.new(formulario_params)
    @formulario.usuario = current_usuario
    @formulario.status = 'ativo' # Por padrão já cria ativo por enquanto

    if @formulario.save
      redirect_to formularios_path, notice: 'Formulário de avaliação criado com sucesso!'
    else
      @modelos = Modelo.where(status: 'ativo')
      @materias = Materia.order(:codigo)
      render :new, status: :unprocessable_entity
    end
  end

  def resultados
    @respostas = @formulario.respostas.includes(:usuario, :questao, :questao_opcao)
  end

  def destroy
    if @formulario.destroy
      redirect_to formularios_path, notice: 'Formulário excluído com sucesso.'
    else
      redirect_to formularios_path, alert: 'Erro ao excluir formulário.'
    end
  end

  private

  def set_formulario
    @formulario = Formulario.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to formularios_path, alert: 'Formulário não encontrado.'
  end

  def formulario_params
    params.require(:formulario).permit(:titulo, :instrucoes, :data_inicio, :data_fim, :modelo_id, :materia_id, :destinatario)
  end
end
