class ModelosController < ApplicationController
    before_action :require_login
    before_action :require_admin, except: [:index, :show]
    before_action :set_modelo, only: [:show, :edit, :update, :destroy]
  
  def index
    @modelos = Modelo.includes(:usuario, :questoes)
                     .order(created_at: :desc)
                     .page(params[:page])
                     .per(10)
    
    # Filtro de busca
    if params[:busca].present?
      @modelos = @modelos.where('nome ILIKE ?', "%#{params[:busca]}%")
    end
  end
  
  def show
    @questoes = @modelo.questoes.order(:ordem)
  end
  
  def new
    @modelo = Modelo.new
    # Começar com 3 questões vazias
    3.times { @modelo.questoes.build }
  end
  
  def edit
    # Adicionar uma questão vazia se não houver nenhuma
    @modelo.questoes.build if @modelo.questoes.empty?
  end
  
  def create
    @modelo = current_usuario.modelos.build(modelo_params)
    @modelo.versao = 1

    @modelo.questoes.each_with_index do |questao, index|
      questao.ordem = index + 1
      questao.versao ||= 1
      questao.status ||= 'ativo'
    end
    
    if @modelo.save
      # Definir agrupamento como o próprio ID se não foi especificado
      @modelo.update(agrupamento: @modelo.id) if @modelo.agrupamento.nil?
      
      redirect_to @modelo, notice: 'Template criado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @modelo.update(modelo_params)
      redirect_to @modelo, notice: 'Template atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @modelo.destroy
    redirect_to modelos_path, notice: 'Template excluído com sucesso!'
  end
  
  private
  
  def set_modelo
    @modelo = Modelo.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to modelos_path, alert: 'Template não encontrado'
  end
  
  def modelo_params
    params.require(:modelo).permit(
      :nome, :descricao, :status,
      questoes_attributes: [
        :id, :enunciado, :tipo, :ordem, :versao, :status, :agrupamento, :_destroy,
        questao_opcoes_attributes: [
          :id,
          :texto,
          :ordem,
          :_destroy
        ]
      ]
    )
  end
end
