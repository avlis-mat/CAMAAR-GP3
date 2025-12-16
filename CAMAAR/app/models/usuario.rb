# Modelo que representa um usuário do sistema CAMAAR.
# 
# Um usuário pode ser administrador, aluno ou professor, e possui
# diferentes status: pendente, ativo ou inativo. O sistema utiliza
# autenticação por senha segura através do has_secure_password.
#
# @example Criar um novo usuário
#   usuario = Usuario.new(
#     matricula: "123456789",
#     nome: "João Silva",
#     email: "joao@example.com",
#     tipo: "aluno",
#     status: "pendente"
#   )
class Usuario < ApplicationRecord
  # Autenticação
  has_secure_password
  
  # Associações
  has_many :usuario_materias, dependent: :destroy
  has_many :materias, through: :usuario_materias
  has_many :modelos, foreign_key: 'usuario_id', dependent: :restrict_with_error
  has_many :formularios, foreign_key: 'usuario_id', dependent: :restrict_with_error
  has_many :respostas, dependent: :destroy
  has_many :token_senhas, dependent: :destroy
  
  # Validações
  validates :matricula, presence: true, uniqueness: true,
            format: { with: /\A\d{9,11}\z/, message: "deve ter 9 a 11 dígitos" }
  validates :nome, presence: true, length: { minimum: 3, maximum: 100 }
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :tipo, presence: true, 
            inclusion: { in: %w[administrador aluno professor] }
  validates :status, presence: true,
            inclusion: { in: %w[pendente ativo inativo] }
  
  # Validação de senha apenas quando necessário
  validates :password, length: { minimum: 6 }, allow_nil: true, if: :password_digest_changed?
  
  # Scopes
  scope :ativos, -> { where(status: 'ativo') }
  scope :pendentes, -> { where(status: 'pendente') }
  scope :inativos, -> { where(status: 'inativo') }
  scope :administradores, -> { where(tipo: 'administrador') }
  scope :alunos, -> { where(tipo: 'aluno') }
  scope :professores, -> { where(tipo: 'professor') }
  scope :do_departamento, ->(dept) { where(departamento: dept) }
  
  # Verifica se o usuário é administrador.
  #
  # @return [Boolean] true se o tipo do usuário for 'administrador', false caso contrário
  def administrador?
    tipo == 'administrador'
  end
  
  # Verifica se o usuário é aluno.
  #
  # @return [Boolean] true se o tipo do usuário for 'aluno', false caso contrário
  def aluno?
    tipo == 'aluno'
  end
  
  # Verifica se o usuário é professor.
  #
  # @return [Boolean] true se o tipo do usuário for 'professor', false caso contrário
  def professor?
    tipo == 'professor'
  end
  
  # Verifica se o usuário está ativo.
  #
  # @return [Boolean] true se o status for 'ativo', false caso contrário
  def ativo?
    status == 'ativo'
  end
  
  # Verifica se o usuário está pendente.
  #
  # @return [Boolean] true se o status for 'pendente', false caso contrário
  def pendente?
    status == 'pendente'
  end
  
  # Verifica se o usuário está inativo.
  #
  # @return [Boolean] true se o status for 'inativo', false caso contrário
  def inativo?
    status == 'inativo'
  end
  
  # Retorna o nome completo do usuário com seu tipo entre parênteses.
  #
  # @return [String] nome completo formatado com tipo, ex: "João Silva (Aluno)"
  def nome_completo_com_tipo
    "#{nome} (#{tipo.capitalize})"
  end
  
  # Verifica se o usuário possui senha cadastrada.
  #
  # @return [Boolean] true se password_digest estiver presente, false caso contrário
  def possui_senha?
    password_digest.present?
  end
  
  # Verifica se o usuário pode fazer login no sistema.
  #
  # @return [Boolean] true se o usuário estiver ativo e possuir senha, false caso contrário
  def pode_fazer_login?
    ativo? && possui_senha?
  end
  
  # Retorna todas as matérias onde o usuário atua como aluno.
  #
  # @return [ActiveRecord::Relation] relação de matérias ordenadas por código
  def turmas_como_aluno
    materias.joins(:usuario_materias)
            .where(usuario_materias: { papel: 'aluno' })
            .order(:codigo)
  end
  
  # Retorna todas as matérias onde o usuário atua como professor.
  #
  # @return [ActiveRecord::Relation] relação de matérias ordenadas por código
  def turmas_como_professor
    materias.joins(:usuario_materias)
            .where(usuario_materias: { papel: 'professor' })
            .order(:codigo)
  end
  
  # Retorna formulários disponíveis para o usuário responder.
  # Considera apenas formulários vigentes, relacionados às matérias do usuário
  # e que ainda não foram respondidos por ele.
  #
  # @return [ActiveRecord::Relation] relação de formulários disponíveis
  def formularios_disponiveis
    # Formulários que o usuário pode responder e ainda não respondeu
    formulario_ids_respondidos = respostas.pluck(:formulario_id).uniq
    
    Formulario.disponiveis
              .where.not(id: formulario_ids_respondidos)
              .where(materia_id: materias.pluck(:id))
  end
  
  # Retorna todos os formulários que o usuário já respondeu.
  #
  # @return [ActiveRecord::Relation] relação de formulários respondidos
  def formularios_respondidos
    Formulario.joins(:respostas)
              .where(respostas: { usuario_id: id })
              .distinct
  end
  
  # Retorna a classe CSS para badge de status do usuário.
  #
  # @return [String] classe CSS correspondente ao status:
  #   - 'badge-success' para ativo
  #   - 'badge-warning' para pendente
  #   - 'badge-danger' para inativo
  #   - 'badge-secondary' para outros casos
  def status_badge_class
    case status
    when 'ativo'
      'badge-success'
    when 'pendente'
      'badge-warning'
    when 'inativo'
      'badge-danger'
    else
      'badge-secondary'
    end
  end
  
  # Retorna a classe CSS para badge de tipo do usuário.
  #
  # @return [String] classe CSS correspondente ao tipo:
  #   - 'badge-danger' para administrador
  #   - 'badge-purple' para professor
  #   - 'badge-blue' para aluno
  #   - 'badge-secondary' para outros casos
  def tipo_badge_class
    case tipo
    when 'administrador'
      'badge-danger'
    when 'professor'
      'badge-purple'
    when 'aluno'
      'badge-blue'
    else
      'badge-secondary'
    end
  end
end
