# app/models/formulario.rb
# VERSÃO SIMPLIFICADA - Apenas campos do ER inicial

class Formulario < ApplicationRecord
  # Associações
  belongs_to :usuario
  belongs_to :modelo
  belongs_to :materia, optional: true
  has_many :respostas, dependent: :destroy
  
  # Validações
  validates :titulo, presence: true, length: { minimum: 3, maximum: 200 }
  validates :modelo_id, presence: true
  validates :data_inicio, presence: true
  validates :data_fim, presence: true
  validates :destinatario, presence: true, 
            inclusion: { in: %w[todos discentes docentes materia] }
  validates :status, presence: true,
            inclusion: { in: %w[rascunho ativo inativo encerrado] }
  validates :versao, presence: true, numericality: { greater_than: 0 }
  
  # Validação customizada: data_fim deve ser maior que data_inicio
  validate :data_fim_deve_ser_maior_que_data_inicio
  
  # Validação: se destinatario for 'materia', materia_id é obrigatório
  validates :materia_id, presence: true, if: -> { destinatario == 'materia' }
  
  # Scopes
  scope :rascunho, -> { where(status: 'rascunho') }
  scope :ativo, -> { where(status: 'ativo') }
  scope :inativo, -> { where(status: 'inativo') }
  scope :encerrado, -> { where(status: 'encerrado') }
  scope :vigente, -> { 
    where(status: 'ativo')
      .where('data_inicio <= ?', Date.current)
      .where('data_fim >= ?', Date.current)
  }
  
  # Aliases para compatibilidade
  scope :ativos, -> { ativo }
  scope :disponiveis, -> { vigente }
  
  # Métodos de status
  def rascunho?
    status == 'rascunho'
  end
  
  def ativo?
    status == 'ativo'
  end
  
  def inativo?
    status == 'inativo'
  end
  
  def encerrado?
    status == 'encerrado'
  end
  
  def vigente?
    ativo? && dentro_do_periodo?
  end
  
  def disponivel?
    vigente?
  end
  
  def dentro_do_periodo?
    Date.current >= data_inicio && Date.current <= data_fim
  end
  
  def expirado?
    Date.current > data_fim
  end
  
  def futuro?
    Date.current < data_inicio
  end
  
  # Métodos auxiliares
  def status_humanizado
    case status
    when 'rascunho'
      'Rascunho'
    when 'ativo'
      if vigente?
        'Ativo'
      elsif futuro?
        'Ativo (Aguardando início)'
      elsif expirado?
        'Ativo (Expirado)'
      else
        'Ativo'
      end
    when 'inativo'
      'Inativo'
    when 'encerrado'
      'Encerrado'
    else
      status.humanize
    end
  end
  
  def destinatario_humanizado
    case destinatario
    when 'todos'
      'Todos os usuários'
    when 'alunos'
      'Apenas alunos'
    when 'professores'
      'Apenas professores'
    when 'materia'
      "Alunos da matéria: #{materia&.nome || 'N/A'}"
    else
      destinatario.humanize
    end
  end
  
  # Alias para compatibilidade com views
  def destinatarios_humanizado
    destinatario_humanizado
  end
  
  def status_badge_class
    case status
    when 'rascunho'
      'badge-secondary'
    when 'ativo'
      vigente? ? 'badge-success' : 'badge-warning'
    when 'inativo'
      'badge-danger'
    when 'encerrado'
      'badge-dark'
    else
      'badge-secondary'
    end
  end
  
  # Método para duplicar formulário
  def duplicar
    novo_formulario = self.dup
    novo_formulario.titulo = "#{titulo} (Cópia)"
    novo_formulario.status = 'rascunho'
    novo_formulario.versao = 1
    novo_formulario.agrupamento = nil
    novo_formulario
  end
  
  # Calcular estatísticas
  def taxa_resposta
    total_destinatarios = calcular_total_destinatarios
    return 0 if total_destinatarios == 0
    
    (total_respostas_usuarios.to_f / total_destinatarios * 100).round(1)
  end
  
  def total_respostas
    total_respostas_usuarios
  end
  
  def calcular_total_destinatarios
    case destinatario
    when 'todos'
      Usuario.count
    when 'alunos'
      Usuario.where(tipo: 'aluno').count
    when 'professores'
      Usuario.where(tipo: 'professor').count
    when 'materia'
      materia.present? ? materia.usuarios.where(tipo: 'aluno').count : 0
    else
      0
    end
  end

  def total_respostas_usuarios
    respostas.select(:usuario_id).distinct.count
  end
  
  # Verificar se usuário pode responder
  def pode_responder?(usuario)
    return false unless ativo? && vigente?
    
    case destinatario
    when 'todos'
      usuario.materias.include?(materia)
    when 'discentes'
      usuario.aluno? && usuario.materias.include?(materia)
    when 'docentes'
      usuario.professor? && usuario.materias.include?(materia)
    end
  end
  
  # Alias para compatibilidade
  def disponivel_para?(usuario)
    pode_responder?(usuario)
  end
  
  # Verificar se usuário já respondeu
  def ja_respondeu?(usuario)
    respostas.exists?(usuario: usuario)
  end
  
  # Alias para compatibilidade
  def ja_respondido_por?(usuario)
    ja_respondeu?(usuario)
  end

  # metodos de destinatarios

  def destinatario_badge_class
  case destinatario
  when 'dicentes'
    'badge badge-blue'
  when 'docentes'
    'badge badge-purple'
  when 'todos'
    'badge badge-green'
  else
    'badge badge-gray'
  end
end

def destinatario_icone
  case destinatario
  when 'dicentes'
    '👨‍🎓'
  when 'docentes'
    '👨‍🏫'
  when 'todos'
    '👥'
  else
    '❓'
  end
end

def destinatario_texto
  case destinatario
  when 'dicentes'
    'Alunos'
  when 'docentes'
    'Professores'
  when 'todos'
    'Todos'
  else
    destinatario.humanize
  end
end

def destinatario_humanizado
  "#{destinatario_icone} #{destinatario_texto}"
end

def destinatario_descricao
  case destinatario
  when 'dicentes'
    'Este formulário será respondido pelos alunos da turma'
  when 'docentes'
    'Este formulário será respondido pelos professores da turma'
  when 'todos'
    'Este formulário será respondido por todos os participantes da turma'
  else
    'Destinatário não especificado'
  end
end
  
  private
  
  def data_fim_deve_ser_maior_que_data_inicio
    return if data_inicio.blank? || data_fim.blank?
    
    if data_fim < data_inicio
      errors.add(:data_fim, 'deve ser posterior à data de início')
    end
  end
end
