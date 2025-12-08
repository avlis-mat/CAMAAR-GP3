class Formulario < ApplicationRecord
  belongs_to :modelo
  belongs_to :materia
  belongs_to :usuario

  has_many :respostas, dependent: :destroy
  
  validates :titulo, presence: true, length: { minimum: 3 }
  validates :data_inicio, presence: true
  validates :data_fim, presence: true
  validates :destinatario, presence: true,
            inclusion: { in: %w[docentes dicentes todos] }
  validates :status, presence: true,
            inclusion: { in: %w[rascunho ativo encerrado] }
  validate :data_fim_depois_de_inicio
  
  scope :ativos, -> { where(status: 'ativo') }
  scope :disponiveis, -> {
    where(status: 'ativo')
      .where('data_inicio <= ?', Date.today)
      .where('data_fim >= ?', Date.today)
  }
  
  def disponivel?
    status == 'ativo' &&
      Date.today >= data_inicio &&
      Date.today <= data_fim
  end
  
  def disponivel_para?(usuario)
    return false unless disponivel?
    
    case destinatario
    when 'docentes'
      usuario.usuario_materias.professores.exists?(materia: materia)
    when 'dicentes'
      usuario.usuario_materias.alunos.exists?(materia: materia)
    when 'todos'
      usuario.usuario_materias.exists?(materia: materia)
    end
  end
  
  def ja_respondido_por?(usuario)
    respostas.exists?(usuario: usuario)
  end
  
  private
  
  def data_fim_depois_de_inicio
    return if data_fim.blank? || data_inicio.blank?
    
    if data_fim < data_inicio
      errors.add(:data_fim, "deve ser posterior à data de início")
    end
  end
end
