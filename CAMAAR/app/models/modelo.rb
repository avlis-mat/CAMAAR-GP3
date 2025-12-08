class Modelo < ApplicationRecord
  belongs_to :usuario
  has_many :questoes, dependent: :destroy
  has_many :formularios, dependent: :restrict_with_error
  
  accepts_nested_attributes_for :questoes, 
    allow_destroy: true,
    reject_if: :all_blank
  
  validates :nome, presence: true, length: { minimum: 3, maximum: 100 }
  validates :versao, presence: true, numericality: { greater_than: 0 }
  validates :versao, uniqueness: { scope: :agrupamento }, if: :agrupamento?
  validates :status, presence: true, inclusion: { in: %w[ativo inativo] }
  
  after_create :set_agrupamento_inicial, if: -> { agrupamento.nil? }
  
  default_scope { where(status: 'ativo') }
  scope :todas_versoes, -> { unscoped }
  scope :versoes_de, ->(agrup) { unscoped.where(agrupamento: agrup).order(:versao) }
  
  private
  
  def set_agrupamento_inicial
    update_column(:agrupamento, id)
  end
end
