# Modelo que representa uma questão dentro de um modelo de formulário.
#
# Uma questão pode ser do tipo dissertativa ou múltipla escolha.
# Questões de múltipla escolha devem ter pelo menos 2 opções associadas.
# Suporta controle de versões através do campo agrupamento.
#
# @example Criar uma questão dissertativa
#   questao = Questao.new(
#     enunciado: "Descreva sua experiência com a disciplina",
#     tipo: "dissertativa",
#     ordem: 1,
#     versao: 1,
#     status: "ativo"
#   )
class Questao < ApplicationRecord
  belongs_to :modelo

  has_many :questao_opcoes, dependent: :destroy
  has_many :respostas, dependent: :restrict_with_error
  
  accepts_nested_attributes_for :questao_opcoes,
    allow_destroy: true,
    reject_if: proc { |attributes| attributes['texto'].blank? }
  
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
  
  # Verifica se a questão é do tipo múltipla escolha.
  #
  # @return [Boolean] true se o tipo for 'multipla_escolha', false caso contrário
  def multipla_escolha?
    tipo == 'multipla_escolha'
  end
  
  # Verifica se a questão é do tipo dissertativa.
  #
  # @return [Boolean] true se o tipo for 'dissertativa', false caso contrário
  def dissertativa?
    tipo == 'dissertativa'
  end
  
  # Verifica se a questão está ativa.
  #
  # @return [Boolean] true se o status for 'ativo', false caso contrário
  def ativa?
    status == 'ativo'
  end
  
  # Verifica se a questão está inativa.
  #
  # @return [Boolean] true se o status for 'inativo', false caso contrário
  def inativa?
    status == 'inativo'
  end
  
  # Alias para manter compatibilidade (enunciado = texto).
  # Útil se alguma view usar "texto" em vez de "enunciado".
  #
  # @return [String] o enunciado da questão
  def texto
    enunciado
  end
  
  # Define o enunciado através do alias texto.
  #
  # @param value [String] novo valor para o enunciado
  # @return [void]
  def texto=(value)
    self.enunciado = value
  end
  
  # Retorna o tipo da questão de forma humanizada.
  #
  # @return [String] tipo formatado:
  #   - 'Dissertativa' para questões dissertativas
  #   - 'Múltipla Escolha' para questões de múltipla escolha
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
  
  # Retorna o número de opções associadas à questão.
  #
  # @return [Integer] número de opções (0 se for dissertativa)
  def numero_opcoes
    questao_opcoes.count
  end
  
  # Cria uma cópia da questão com nova versão.
  # Duplica todas as opções associadas mantendo o agrupamento.
  #
  # @return [Questao] nova questão duplicada (não salva no banco)
  # @note O objeto retornado não está salvo, é necessário chamar save após a duplicação
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
  
  # Define o agrupamento inicial após a criação da questão.
  # Este método é chamado automaticamente pelo callback after_create
  # quando o agrupamento não foi definido previamente.
  #
  # @return [void]
  # @note Efeito colateral: atualiza o campo agrupamento no banco de dados
  def set_agrupamento_inicial
    update_column(:agrupamento, id)
  end

end
