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
  
  #callbacks
  after_create :set_agrupamento_inicial, if: -> { agrupamento.nil? }
  
  #escopos
  default_scope { where(status: 'ativo').order(:ordem) }
  scope :todas_versoes, -> { unscoped }
  scope :dissertativas, -> { where(tipo: 'dissertativa') }
  scope :multipla_escolha, -> { where(tipo: 'multipla_escolha') }
  scope :ativas, -> { where(status: 'ativo') }
  scope :inativas, -> { where(status: 'inativo') }
  
# Métodos públicos
  
  # Verifica se é múltipla escolha
  def multipla_escolha?
    tipo == 'multipla_escolha'
  end
  
  # Verifica se é dissertativa
  def dissertativa?
    tipo == 'dissertativa'
  end
  
  # Verifica se está ativa
  def ativa?
    status == 'ativo'
  end
  
  # Verifica se está inativa
  def inativa?
    status == 'inativo'
  end
  
  # Verifica se é obrigatória
  #def obrigatoria?
   # obrigatoria == true
  # end
  
  # Alias para manter compatibilidade (enunciado = texto)
  # Útil se alguma view usar "texto" em vez de "enunciado"
  def texto
    enunciado
  end
  
  def texto=(value)
    self.enunciado = value
  end
  
  # Retorna o tipo humanizado
  def tipo_humanizado
    case tipo
    when 'dissertativa'
      'Dissertativa'
    when 'multipla_escolha'
      'Múltipla Escolha'
    else
      tipo.humanize
    end
  end
  
  # Retorna número de opções (0 se dissertativa)
  def numero_opcoes
    questao_opcoes.count
  end
  
  # Duplicar questão (útil para criar novas versões)
  def duplicar
    nova_questao = self.dup
    nova_questao.versao = (versao || 0) + 1
    nova_questao.agrupamento = agrupamento || id
    
    # Duplicar opções
    questao_opcoes.each do |opcao|
      nova_questao.questao_opcoes.build(
        texto: opcao.texto,
        ordem: opcao.ordem
      )
    end
    
    nova_questao
  end

  private
  
  def set_agrupamento_inicial
    update_column(:agrupamento, id)
  end

end
