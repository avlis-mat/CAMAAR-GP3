# Controller responsável pelo gerenciamento de respostas aos formulários.
# Permite que usuários respondam formulários e que administradores visualizem resultados.
class RespostasController < ApplicationController
  
  before_action :require_login
  before_action :set_formulario
  before_action :verificar_disponibilidade, only: [:new, :create]
  before_action :verificar_ja_respondido, only: [:new, :create]
  before_action :require_admin, only: [:index]
  
  # GET /formularios/:id/responder
  # Aluno ou professor acessa para responder o formulário
  def new
    @questoes = @formulario.modelo.questoes.includes(:questao_opcoes).order(:ordem)
    
    # Hash para repopular form em caso de erro
    @respostas_hash = {}
  end
  
  # POST /formularios/:formulario_id/respostas
  # Salvar todas as respostas do usuário
  def create
    erros = []
    
    # Transaction: ou salva tudo ou nada
    ActiveRecord::Base.transaction do
      params[:respostas].each do |questao_id, resposta_params|
        questao = Questao.find(questao_id)
        
        resposta = Resposta.new(
          formulario: @formulario,
          usuario: current_usuario,
          questao: questao
        )
        
        # Preencher baseado no tipo
        if questao.tipo == 'dissertativa'
          resposta.conteudo = resposta_params[:conteudo]
        elsif questao.tipo == 'multipla_escolha'
          resposta.questao_opcao_id = resposta_params[:questao_opcao_id]
        end
        
        unless resposta.save
          erros << "Questão #{questao.ordem}: #{resposta.errors.full_messages.join(', ')}"
          raise ActiveRecord::Rollback
        end
      end
    end
    
    # Resultado
    if erros.empty?
      redirect_to formularios_path, 
                  notice: '✅ Respostas enviadas com sucesso! Obrigado por participar.'
    else
      @questoes = @formulario.modelo.questoes.includes(:questao_opcoes).order(:ordem)
      @respostas_hash = params[:respostas]
      flash.now[:alert] = "Erro ao salvar: #{erros.join('; ')}"
      render :new, status: :unprocessable_entity
    end
  end
  
  # GET /formularios/:id/resultados
  # Admin visualiza resultados e estatísticas
  def index
    @questoes = @formulario.modelo.questoes.includes(:questao_opcoes).order(:ordem)
    @respostas = @formulario.respostas.includes(:usuario, :questao, :questao_opcao)
    
    # Calcular estatísticas
    calcular_estatisticas
    
    # Agrupar por questão
    @respostas_por_questao = @respostas.group_by(&:questao_id)
    
    # Estatísticas de múltipla escolha
    calcular_estatisticas_multipla
  end
  
  private
  
  def set_formulario
    # Aceita :id (member) ou :formulario_id (nested)
    formulario_id = params[:formulario_id] || params[:id]
    @formulario = Formulario.find(formulario_id)
  end
  
  def verificar_disponibilidade
    # Verificar se está disponível
    unless @formulario.disponivel?
      redirect_to formularios_path, 
                  alert: '⚠️ Este formulário não está mais disponível.'
      return
    end
    
    # Verificar permissão baseada no destinatário
    pode_responder = case @formulario.destinatario
    when 'discentes'
      aluno?
    when 'docentes'
      professor?
    when 'todos'
      aluno? || professor?
    else
      false
    end
    
    unless pode_responder
      redirect_to formularios_path, 
                  alert: '⚠️ Você não tem permissão para responder este formulário.'
    end
  end
  
  def verificar_ja_respondido
    if @formulario.ja_respondido_por?(current_usuario)
      redirect_to formularios_path, 
                  alert: 'ℹ️ Você já respondeu este formulário.'
    end
  end
  
  def calcular_estatisticas
    # Total de usuários únicos que responderam
    @total_respostas = @respostas.select(:usuario_id).distinct.count
    
    # Total esperado (baseado no destinatário)
    @total_esperado = case @formulario.destinatario
    when 'dicentes'
      if @formulario.materia.present?
        @formulario.materia.usuario_materias.alunos.count
      else
        Usuario.where(tipo: 'aluno').count
      end
    when 'docentes'
      if @formulario.materia.present?
        @formulario.materia.usuario_materias.professores.count
      else
        Usuario.where(tipo: 'professor').count
      end
    when 'todos'
      if @formulario.materia.present?
        @formulario.materia.usuario_materias.count
      else
        Usuario.count
      end
    else
      0
    end
    
    # Taxa de resposta
    @taxa_resposta = @total_esperado > 0 ? 
                     (@total_respostas.to_f / @total_esperado * 100).round(1) : 
                     0
  end
  
  def calcular_estatisticas_multipla
    @estatisticas_multipla = {}
    
    @questoes.where(tipo: 'multipla_escolha').each do |questao|
      respostas_questao = @respostas_por_questao[questao.id] || []
      total = respostas_questao.count
      
      @estatisticas_multipla[questao.id] = questao.questao_opcoes.map do |opcao|
        count = respostas_questao.count { |r| r.questao_opcao_id == opcao.id }
        percentual = total > 0 ? (count.to_f / total * 100).round(1) : 0
        
        {
          opcao: opcao,
          count: count,
          percentual: percentual
        }
      end
    end
  end
end
