# Modelo de associação entre usuário e matéria (tabela de junção).
#
# Representa a relação many-to-many entre usuários e matérias,
# indicando o papel do usuário na matéria (aluno ou professor).
#
# @example Criar associação de aluno
#   usuario_materia = UsuarioMateria.new(
#     usuario: usuario,
#     materia: materia,
#     papel: "aluno"
#   )
class UsuarioMateria < ApplicationRecord
  belongs_to :usuario
  belongs_to :materia

  validates :papel, presence: true,
            inclusion: { in: %w[aluno professor] }
  validates :usuario_id, uniqueness: { 
    scope: :materia_id,
    message: "já matriculado nesta turma"
  }
  
  scope :alunos, -> { where(papel: 'aluno') }
  scope :professores, -> { where(papel: 'professor') }
end
