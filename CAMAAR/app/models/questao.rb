class Questao < ApplicationRecord
  belongs_to :modelo

  has_many :questao_opcoes, dependent: :destroy
  has_many :respostas, dependent: :restrict_with_error
  
  accepts_nested_attributes_for :questao_opcoes,
    allow_destroy: true,
    reject_if: :all_blank
  
  validates :enunciado, presence: true, length: { minimum: 5 }
  validates :tipo, presence: true,
            inclusion: { in: %w[dissertativa multipla_escolha] }
  validates :ordem, presence: true, numericality: { greater_than: 0 }
  validates :versao, presence: true, numericality: { greater_than: 0 }
  validates :versao, uniqueness: { scope: :agrupamento }, if: :agrupamento?
  validates :status, presence: true, inclusion: { in: %w[ativo inativo] }
  validates :questao_opcoes, length: { minimum: 2 }, 
            if: -> { tipo == 'multipla_escolha' }
  
  after_create :set_agrupamento_inicial, if: -> { agrupamento.nil? }
  
  default_scope { where(status: 'ativo').order(:ordem) }
  scope :todas_versoes, -> { unscoped }
  scope :dissertativas, -> { where(tipo: 'dissertativa') }
  scope :multipla_escolha, -> { where(tipo: 'multipla_escolha') }
  
  private
  
  def set_agrupamento_inicial
    update_column(:agrupamento, id)
  end

end
