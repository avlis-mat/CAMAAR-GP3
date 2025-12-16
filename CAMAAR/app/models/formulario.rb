# Modelo que representa um formulário de avaliação no sistema CAMAAR.
#
# Um formulário é criado a partir de um modelo (template) e pode estar
# associado a uma matéria específica. Possui período de vigência definido
# por data_inicio e data_fim, e pode ter diferentes destinatários:
# todos, discentes, docentes ou matéria específica.
#
# @example Criar um novo formulário
#   formulario = Formulario.new(
#     titulo: "Avaliação Semestral",
#     modelo_id: 1,
#     materia_id: 1,
#     data_inicio: Date.today,
#     data_fim: Date.today + 30.days,
#     destinatario: "discentes",
#     status: "rascunho",
#     versao: 1
#   )
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
  
  # Verifica se o formulário está em rascunho.
  #
  # @return [Boolean] true se o status for 'rascunho', false caso contrário
  def rascunho?
    status == 'rascunho'
  end
  
  # Verifica se o formulário está ativo.
  #
  # @return [Boolean] true se o status for 'ativo', false caso contrário
  def ativo?
    status == 'ativo'
  end
  
  # Verifica se o formulário está inativo.
  #
  # @return [Boolean] true se o status for 'inativo', false caso contrário
  def inativo?
    status == 'inativo'
  end
  
  # Verifica se o formulário está encerrado.
  #
  # @return [Boolean] true se o status for 'encerrado', false caso contrário
  def encerrado?
    status == 'encerrado'
  end
  
  # Verifica se o formulário está vigente (ativo e dentro do período).
  #
  # @return [Boolean] true se estiver ativo e dentro do período, false caso contrário
  def vigente?
    ativo? && dentro_do_periodo?
  end
  
  # Alias para vigente?.
  #
  # @return [Boolean] true se estiver disponível para resposta, false caso contrário
  def disponivel?
    vigente?
  end
  
  # Verifica se a data atual está dentro do período do formulário.
  #
  # @return [Boolean] true se a data atual estiver entre data_inicio e data_fim, false caso contrário
  def dentro_do_periodo?
    Date.current >= data_inicio && Date.current <= data_fim
  end
  
  # Verifica se o formulário expirou (data atual é posterior a data_fim).
  #
  # @return [Boolean] true se expirado, false caso contrário
  def expirado?
    Date.current > data_fim
  end
  
  # Verifica se o formulário ainda não iniciou (data atual é anterior a data_inicio).
  #
  # @return [Boolean] true se ainda não iniciou, false caso contrário
  def futuro?
    Date.current < data_inicio
  end
  
  # Retorna o status do formulário de forma humanizada.
  # Inclui informações adicionais sobre o período quando aplicável.
  #
  # @return [String] status formatado:
  #   - 'Rascunho' para rascunhos
  #   - 'Ativo' para formulários ativos e vigentes
  #   - 'Ativo (Aguardando início)' para formulários ativos mas ainda não iniciados
  #   - 'Ativo (Expirado)' para formulários ativos mas já expirados
  #   - 'Inativo' para formulários inativos
  #   - 'Encerrado' para formulários encerrados
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
  
  # Retorna o destinatário do formulário de forma humanizada.
  #
  # @return [String] destinatário formatado:
  #   - 'Todos os usuários' para 'todos'
  #   - 'Apenas alunos' para 'alunos'
  #   - 'Apenas professores' para 'professores'
  #   - 'Alunos da matéria: [nome]' para 'materia'
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
  
  # Alias para compatibilidade com views.
  #
  # @return [String] mesmo valor de destinatario_humanizado
  def destinatarios_humanizado
    destinatario_humanizado
  end
  
  # Retorna a classe CSS para badge de status do formulário.
  #
  # @return [String] classe CSS correspondente ao status:
  #   - 'badge-secondary' para rascunho
  #   - 'badge-success' para ativo e vigente
  #   - 'badge-warning' para ativo mas não vigente
  #   - 'badge-danger' para inativo
  #   - 'badge-dark' para encerrado
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
  
  # Cria uma cópia do formulário como rascunho.
  #
  # @return [Formulario] novo formulário duplicado (não salvo no banco)
  # @note O objeto retornado não está salvo, é necessário chamar save após a duplicação
  def duplicar
    novo_formulario = self.dup
    novo_formulario.titulo = "#{titulo} (Cópia)"
    novo_formulario.status = 'rascunho'
    novo_formulario.versao = 1
    novo_formulario.agrupamento = nil
    novo_formulario
  end
  
  # Calcula a taxa de resposta do formulário em percentual.
  #
  # @return [Float] percentual de resposta arredondado para 1 casa decimal
  # @return [Integer] 0 se não houver destinatários
  def taxa_resposta
    total_destinatarios = calcular_total_destinatarios
    return 0 if total_destinatarios == 0
    
    (total_respostas_usuarios.to_f / total_destinatarios * 100).round(1)
  end
  
  # Retorna o total de respostas do formulário.
  #
  # @return [Integer] número total de respostas (usuários únicos)
  def total_respostas
    total_respostas_usuarios
  end
  
  # Calcula o total de destinatários baseado no tipo de destinatário.
  #
  # @return [Integer] número total de destinatários:
  #   - Total de usuários se destinatario for 'todos'
  #   - Total de alunos se destinatario for 'alunos'
  #   - Total de professores se destinatario for 'professores'
  #   - Total de alunos da matéria se destinatario for 'materia'
  #   - 0 para outros casos
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

  # Retorna o total de usuários únicos que responderam o formulário.
  #
  # @return [Integer] número de usuários distintos que responderam
  def total_respostas_usuarios
    respostas.select(:usuario_id).distinct.count
  end
  
  # Verifica se um usuário pode responder o formulário.
  #
  # @param usuario [Usuario] usuário a verificar
  # @return [Boolean] true se o usuário pode responder, false caso contrário
  # @note Retorna false se o formulário não estiver ativo e vigente
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
  
  # Alias para compatibilidade.
  #
  # @param usuario [Usuario] usuário a verificar
  # @return [Boolean] mesmo valor de pode_responder?
  def disponivel_para?(usuario)
    pode_responder?(usuario)
  end
  
  # Verifica se um usuário já respondeu o formulário.
  #
  # @param usuario [Usuario] usuário a verificar
  # @return [Boolean] true se o usuário já respondeu, false caso contrário
  def ja_respondeu?(usuario)
    respostas.exists?(usuario: usuario)
  end
  
  # Alias para compatibilidade.
  #
  # @param usuario [Usuario] usuário a verificar
  # @return [Boolean] mesmo valor de ja_respondeu?
  def ja_respondido_por?(usuario)
    ja_respondeu?(usuario)
  end

  # Retorna a classe CSS para badge de destinatário.
  #
  # @return [String] classe CSS correspondente ao destinatário:
  #   - 'badge badge-blue' para 'dicentes'
  #   - 'badge badge-purple' para 'docentes'
  #   - 'badge badge-green' para 'todos'
  #   - 'badge badge-gray' para outros casos
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

  # Retorna o ícone correspondente ao tipo de destinatário.
  #
  # @return [String] emoji correspondente:
  #   - '👨‍🎓' para 'dicentes'
  #   - '👨‍🏫' para 'docentes'
  #   - '👥' para 'todos'
  #   - '❓' para outros casos
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

  # Retorna o texto correspondente ao tipo de destinatário.
  #
  # @return [String] texto formatado:
  #   - 'Alunos' para 'dicentes'
  #   - 'Professores' para 'docentes'
  #   - 'Todos' para 'todos'
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

  # Retorna o destinatário formatado com ícone e texto.
  #
  # @return [String] destinatário formatado com ícone e texto
  def destinatario_humanizado
    "#{destinatario_icone} #{destinatario_texto}"
  end

  # Retorna uma descrição do destinatário do formulário.
  #
  # @return [String] descrição explicativa do destinatário
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
  
  # Validação customizada: verifica se data_fim é posterior a data_inicio.
  # Adiciona erro de validação se a data de fim for anterior à data de início.
  #
  # @return [void]
  # @note Efeito colateral: adiciona erro de validação se a condição não for atendida
  def data_fim_deve_ser_maior_que_data_inicio
    return if data_inicio.blank? || data_fim.blank?
    
    if data_fim < data_inicio
      errors.add(:data_fim, 'deve ser posterior à data de início')
    end
  end
end
