class RespostasController < ApplicationController
  before_action :require_login
  before_action :set_formulario
  before_action :verificar_disponibilidade

  def new
    if @formulario.ja_respondido_por?(current_usuario)
      redirect_to formularios_path, notice: "Você já respondeu este formulário."
      return
    end

    @respostas = @formulario.modelo.questoes.map do |questao|
      Resposta.new(questao: questao)
    end
  end

  def create
    @respostas_params = params.permit(respostas: {})[:respostas]
    
    ActiveRecord::Base.transaction do
      @salvas = []
      @erros = []

      @formulario.modelo.questoes.each do |questao|
        conteudo = params["questao_#{questao.id}"]
        
        # Para multipla escolha, o conteudo pode vir como ID da opcao
        opcao_id = nil
        if questao.tipo == 'multipla_escolha'
           opcao_id = conteudo
           conteudo = QuestaoOpcao.find(opcao_id).texto rescue nil
        end

        resposta = Resposta.new(
          formulario: @formulario,
          usuario: current_usuario,
          questao: questao,
          conteudo: conteudo,
          questao_opcao_id: opcao_id, # Se tiver
          respondido_em: Time.current
        )

        if resposta.save
          @salvas << resposta
        else
          @erros << resposta
        end
      end

      if @erros.empty?
        redirect_to formularios_path, notice: "Respostas enviadas com sucesso!"
      else
        flash.now[:alert] = "Por favor, responda todas as questões obrigatórias."
        # Recarrega a view de new com os erros
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  private

  def set_formulario
    @formulario = Formulario.find(params[:formulario_id])
  end

  def verificar_disponibilidade
    unless @formulario.disponivel_para?(current_usuario)
      redirect_to formularios_path, alert: "Este formulário não está disponível para você."
    end
  end
end
