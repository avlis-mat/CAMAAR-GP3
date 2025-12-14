class FormulariosController < ApplicationController

    before_action :require_login
  before_action :require_admin, except: [:index, :show]
  before_action :set_formulario, only: [:show, :edit, :update, :destroy, :ativar, :desativar, :encerrar]
  
  def index
    @formularios = Formulario.includes(:modelo, :materia, :usuario)
                              .order(created_at: :desc)
                              .page(params[:page]).per(10)
    
    # Filtros
    if params[:status].present?
      @formularios = @formularios.where(status: params[:status])
    end
    
    if params[:materia_id].present?
      @formularios = @formularios.where(materia_id: params[:materia_id])
    end
    
    if params[:busca].present?
      @formularios = @formularios.where('titulo ILIKE ?', "%#{params[:busca]}%")
    end
    
    # Se não for admin, mostrar apenas formulários ativos
    unless administrador?
      @formularios = @formularios.where(status: 'ativo')
    end
  end
  
  def show
    @questoes = @formulario.modelo.questoes.order(:ordem)
    
    # Verificar se já respondeu
    if aluno?
      @ja_respondeu = @formulario.respostas.exists?(usuario: current_usuario)
      @minha_resposta = @formulario.respostas.find_by(usuario: current_usuario)
    end
    
    # Calcular estatísticas
    @total_respostas = @formulario.respostas.count
    @total_destinatarios = calcular_total_destinatarios(@formulario)
    @taxa_resposta = (@total_destinatarios > 0) ? (@total_respostas.to_f / @total_destinatarios * 100).round(1) : 0
  end
  
  def new
    @formulario = Formulario.new
    
    # Se veio de um template, pré-selecionar
    if params[:modelo_id].present?
      @formulario.modelo_id = params[:modelo_id]
      @modelo = Modelo.find(params[:modelo_id])
    end
    
    @modelos = Modelo.ativo.order(:nome)
    @materias = Materia.order(:nome)
  end
  
  def create
    @formulario = current_usuario.formularios.build(formulario_params)
    @formulario.versao = 1
    
    Rails.logger.info "=== CRIAR FORMULÁRIO ==="
    Rails.logger.info "Params: #{formulario_params.inspect}"
    Rails.logger.info "Formulário válido? #{@formulario.valid?}"
    
    if @formulario.save
      @formulario.update(agrupamento: @formulario.id) if @formulario.agrupamento.nil?
      redirect_to @formulario, notice: 'Formulário criado com sucesso!'
    else
      Rails.logger.error "=== ERROS ==="
      Rails.logger.error "Formulário: #{@formulario.errors.full_messages}"
      
      @modelos = Modelo.ativo.order(:nome)
      @materias = Materia.order(:nome)
      flash.now[:alert] = "Não foi possível criar o formulário. Verifique os erros abaixo."
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @modelos = Modelo.ativo.order(:nome)
    @materias = Materia.order(:nome)
    
    # Não permitir editar formulários já ativos com respostas
    if @formulario.ativo? && @formulario.respostas.any?
      redirect_to @formulario, alert: 'Não é possível editar um formulário ativo que já possui respostas.'
    end
  end
  
  def update
    # Não permitir editar formulários já ativos com respostas
    if @formulario.ativo? && @formulario.respostas.any?
      redirect_to @formulario, alert: 'Não é possível editar um formulário ativo que já possui respostas.'
      return
    end
    
    if @formulario.update(formulario_params)
      redirect_to @formulario, notice: 'Formulário atualizado com sucesso!'
    else
      @modelos = Modelo.ativo.order(:nome)
      @materias = Materia.order(:nome)
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    if @formulario.respostas.any?
      redirect_to @formulario, alert: 'Não é possível excluir um formulário que já possui respostas.'
    else
      @formulario.destroy
      redirect_to formularios_path, notice: 'Formulário excluído com sucesso!'
    end
  end
  
  # Ações de mudança de status
  def ativar
    if @formulario.rascunho?
      @formulario.update(status: 'ativo')
      redirect_to @formulario, notice: 'Formulário ativado com sucesso!'
    else
      redirect_to @formulario, alert: 'Apenas formulários em rascunho podem ser ativados.'
    end
  end
  
  def desativar
    if @formulario.ativo?
      @formulario.update(status: 'inativo')
      redirect_to @formulario, notice: 'Formulário desativado com sucesso!'
    else
      redirect_to @formulario, alert: 'Apenas formulários ativos podem ser desativados.'
    end
  end
  
  def encerrar
    if @formulario.ativo?
      @formulario.update(status: 'encerrado')
      redirect_to @formulario, notice: 'Formulário encerrado com sucesso!'
    else
      redirect_to @formulario, alert: 'Apenas formulários ativos podem ser encerrados.'
    end
  end
  
  private
  
  def set_formulario
    @formulario = Formulario.find(params[:id])
  end
  
  def formulario_params
    params.require(:formulario).permit(
      :modelo_id,
      :materia_id,
      :titulo,
      :instrucoes,
      :data_inicio,
      :data_fim,
      :destinatario,
      :status
    )
  end
  
  def calcular_total_destinatarios(formulario)
    case formulario.destinatario
    when 'todos'
      Usuario.count
    when 'discentes'
      if formulario.materia.present?
        formulario.materia.usuario_materias.alunos.count
      else
        Usuario.where(tipo: 'aluno').count
      end
    when 'docentes'
      if formulario.materia.present?
        formulario.materia.usuario_materias.professores.count
      else
        Usuario.where(tipo: 'professor').count
      end
    else
      0
    end
  end

end
