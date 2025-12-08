class Materia < ApplicationRecord
    # Associações
  has_many :usuario_materias, dependent: :destroy
  has_many :usuarios, through: :usuario_materias
  has_many :formularios, dependent: :restrict_with_error
  
  # Validações
  validates :codigo, presence: true,
            format: { with: /\A[A-Z]{3}\d{4}\z/, message: "formato: AAA0000" }
  validates :codigo_turma, presence: true,
            format: { with: /\AT[A-Z]\z/, message: "formato: TA, TB" }
  validates :nome, presence: true, length: { minimum: 3 }
  validates :departamento, presence: true
  validates :semestre, presence: true,
            format: { with: /\A\d{4}\.\d\z/, message: "formato: 2025.1" }
  validates :codigo_turma, uniqueness: { 
    scope: [:codigo, :semestre],
    message: "já existe neste semestre"
  }
  
  # Scopes
  scope :do_semestre, ->(sem) { where(semestre: sem) }
  scope :do_departamento, ->(dept) { where(departamento: dept) }
  scope :da_disciplina, ->(cod) { where(codigo: cod) }
  
  # Métodos
  def codigo_completo
    "#{codigo}-#{codigo_turma}-#{semestre}"
  end
  
  def nome_completo
    "#{nome} - Turma #{codigo_turma}"
  end
end
