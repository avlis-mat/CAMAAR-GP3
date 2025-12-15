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
  scope :ativo, -> { where(status: 'ativo') }
  scope :inativos, -> { where(status: 'inativo') }
  scope :recentes, -> { order(created_at: :desc) }
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
  
=begin  def duplicar
    novo_modelo = self.dup
    novo_modelo.nome = self.nome
    novo_modelo.versao = self.versao + 1
    novo_modelo.agrupamento = self.agrupamento || self.id
    novo_modelo.status = 'ativo'
    
    # Duplicar questões
    questoes.each do |questao|
      nova_questao = novo_modelo.questoes.build(
        enunciado: questao.enunciado,
        tipo: questao.tipo,
        ordem: questao.ordem,
        versao: questao.versao,
        status: questao.status
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
=end    

  def duplicar
  novo_modelo = self.dup
  novo_modelo.nome = self.nome
  novo_modelo.versao = self.versao + 1
  novo_modelo.agrupamento = self.agrupamento || self.id
  novo_modelo.status = 'ativo'
  
  # Duplicar questões mantendo tracking de versões
  questoes.each do |questao|
    nova_questao = novo_modelo.questoes.build(
      enunciado: questao.enunciado,
      tipo: questao.tipo,
      ordem: questao.ordem,
      versao: questao.versao + 1,  # ✅ Incrementa versão
      agrupamento: questao.agrupamento || questao.id,  # ✅ Mantém agrupamento
      status: 'ativo'
    )
    
    # Duplicar opções
    questao.questao_opcoes.each do |opcao|
      nova_questao.questao_opcoes.build(
        texto: opcao.texto,
        ordem: opcao.ordem,
        versao: opcao.versao + 1,  # ✅ Incrementa versão
        agrupamento: opcao.agrupamento || opcao.id,  # ✅ Mantém agrupamento
        status: 'ativo'
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
