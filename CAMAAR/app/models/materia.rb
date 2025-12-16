# Modelo que representa uma matéria (disciplina/turma) no sistema CAMAAR.
#
# Uma matéria é identificada por código, código da turma e semestre.
# Pode ter múltiplos usuários associados (alunos e professores) e
# pode ter formulários de avaliação associados.
#
# @example Criar uma nova matéria
#   materia = Materia.new(
#     codigo: "CIC0101",
#     codigo_turma: "TA",
#     nome: "Introdução à Computação",
#     departamento: "CIC",
#     semestre: "2025.1"
#   )
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
  
  # Retorna o código completo da matéria no formato CODIGO-TURMA-SEMESTRE.
  #
  # @return [String] código completo, ex: "CIC0101-TA-2025.1"
  def codigo_completo
    "#{codigo}-#{codigo_turma}-#{semestre}"
  end
  
  # Retorna o nome completo da matéria incluindo a turma.
  #
  # @return [String] nome completo formatado, ex: "Introdução à Computação - Turma TA"
  def nome_completo
    "#{nome} - Turma #{codigo_turma}"
  end
end
