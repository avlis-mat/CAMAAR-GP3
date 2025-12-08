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
