class Usuario < ApplicationRecord
    # Autenticação
  has_secure_password
  
  # Associações (adicionar depois)
  has_many :usuario_materias, dependent: :destroy
  has_many :materias, through: :usuario_materias
  has_many :modelos_criados, class_name: 'Modelo', foreign_key: 'criador_id'
  has_many :formularios_criados, class_name: 'Formulario', foreign_key: 'criador_id'
  has_many :respostas, dependent: :destroy
  has_many :token_senhas, dependent: :destroy
  
  # Validações
  validates :matricula, presence: true, uniqueness: true,
            format: { with: /\A\d{9}\z/, message: "deve ter 9 dígitos" }
  validates :nome, presence: true, length: { minimum: 3, maximum: 100 }
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :tipo, presence: true, 
            inclusion: { in: %w[administrador aluno professor] }
  validates :status, presence: true,
            inclusion: { in: %w[pendente ativo inativo] }
  
  # Scopes
  scope :ativos, -> { where(status: 'ativo') }
  scope :administradores, -> { where(tipo: 'administrador') }
  scope :do_departamento, ->(dept) { where(departamento: dept) }
  
  # Métodos
  def administrador?
    tipo == 'administrador'
  end
  
  def ativo?
    status == 'ativo'
  end
end
