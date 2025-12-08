class Modelo < ApplicationRecord
  belongs_to :usuario
  has_many :questoes, dependent: :destroy
  has_many :formularios, dependent: :restrict_with_error
  
  accepts_nested_attributes_for :questoes, 
    allow_destroy: true,
    reject_if: :all_blank
  
  validates :nome, presence: true, length: { minimum: 3, maximum: 100 }
  validates :descricao, length: { maximum: 1000 }, allow_blank: true
  validates :versao, presence: true, numericality: { greater_than: 0 }
  validates :versao, uniqueness: { scope: :agrupamento }, if: :agrupamento?
  validates :status, presence: true, inclusion: { in: %w[ativo inativo] }
  
  # Scopes
  scope :ativos, -> { where(status: 'ativo') }
  scope :inativos, -> { where(status: 'inativo') }
  scope :recentes, -> { order(created_at: :desc) }
  default_scope { where(status: 'ativo') }
  scope :todas_versoes, -> { unscoped }
  scope :versoes_de, ->(agrup) { unscoped.where(agrupamento: agrup).order(:versao) }

  #callbacks
  after_create :set_agrupamento_inicial, if: -> { agrupamento.nil? }
  
  # Métodos públicos
  def ativo?
    status == 'ativo'
  end
  
  def inativo?
    status == 'inativo'
  end
  
  def total_questoes
    questoes.count
  end
  
  def duplicar
    novo_modelo = self.dup
    novo_modelo.nome = "#{nome} (Cópia)"
    novo_modelo.versao = 1
    novo_modelo.agrupamento = nil
    
    # Duplicar questões
    questoes.each do |questao|
      nova_questao = novo_modelo.questoes.build(
        texto: questao.texto,
        tipo: questao.tipo,
        obrigatoria: questao.obrigatoria,
        ordem: questao.ordem
      )
      
      # Duplicar opções
      questao.questao_opcoes.each do |opcao|
        nova_questao.questao_opcoes.build(
          texto: opcao.texto,
          ordem: opcao.ordem
        )
      end
    end
    
    novo_modelo
  end
  
  private
  
  def set_agrupamento
    update_column(:agrupamento, id)
  end
  
  private
  
  def set_agrupamento_inicial
    update_column(:agrupamento, id)
  end
end
