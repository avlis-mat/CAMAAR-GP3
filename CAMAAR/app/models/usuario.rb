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
  
  # Métodos de verificação de tipo
  def administrador?
    tipo == 'administrador'
  end
  
  def aluno?
    tipo == 'aluno'
  end
  
  def professor?
    tipo == 'professor'
  end
  
  # Métodos de verificação de status
  def ativo?
    status == 'ativo'
  end
  
  def pendente?
    status == 'pendente'
  end
  
  def inativo?
    status == 'inativo'
  end
  
  # Métodos auxiliares
  def nome_completo_com_tipo
    "#{nome} (#{tipo.capitalize})"
  end
  
  def possui_senha?
    password_digest.present?
  end
  
  def pode_fazer_login?
    ativo? && possui_senha?
  end
  
  def turmas_como_aluno
    materias.joins(:usuario_materias)
            .where(usuario_materias: { papel: 'aluno' })
            .order(:codigo)
  end
  
  def turmas_como_professor
    materias.joins(:usuario_materias)
            .where(usuario_materias: { papel: 'professor' })
            .order(:codigo)
  end
  
  def formularios_disponiveis
    # Formulários que o usuário pode responder e ainda não respondeu
    formulario_ids_respondidos = respostas.pluck(:formulario_id).uniq
    
    Formulario.disponiveis
              .where.not(id: formulario_ids_respondidos)
              .where(materia_id: materias.pluck(:id))
  end
  
  def formularios_respondidos
    Formulario.joins(:respostas)
              .where(respostas: { usuario_id: id })
              .distinct
  end
  
  # Métodos para views (badges de status e tipo)
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
