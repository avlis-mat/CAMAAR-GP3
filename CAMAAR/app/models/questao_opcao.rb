class QuestaoOpcao < ApplicationRecord
  belongs_to :questao

  has_many :respostas, dependent: :restrict_with_error
  
  validates :texto, presence: true, length: { minimum: 1, maximum: 500 }
  validates :ordem, presence: true, numericality: { greater_than: 0 }
  validates :ordem, uniqueness: { scope: :questao_id }
  validates :versao, presence: true, numericality: { greater_than: 0 }
  validates :versao, uniqueness: { scope: :agrupamento }, if: :agrupamento?
  validates :status, presence: true, inclusion: { in: %w[ativo inativo] }
  
  after_create :set_agrupamento_inicial, if: -> { agrupamento.nil? }
  
  default_scope { where(status: 'ativo').order(:ordem) }
  scope :todas_versoes, -> { unscoped }
  scope :corretas, -> { where(is_correta: true) }
  
  private
  
  def set_agrupamento_inicial
    update_column(:agrupamento, id)
  end
end
