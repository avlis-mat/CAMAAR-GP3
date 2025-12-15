# Modelo que representa uma opção de resposta para questões de múltipla escolha.
#
# Uma opção pertence a uma questão e pode ser selecionada pelos usuários
# ao responder formulários. Suporta controle de versões através do campo agrupamento.
#
# @example Criar uma opção de resposta
#   opcao = QuestaoOpcao.new(
#     questao: questao,
#     texto: "Opção A",
#     ordem: 1,
#     versao: 1,
#     status: "ativo"
#   )
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
  
  # Define o agrupamento inicial após a criação da opção.
  # Este método é chamado automaticamente pelo callback after_create
  # quando o agrupamento não foi definido previamente.
  #
  # @return [void]
  # @note Efeito colateral: atualiza o campo agrupamento no banco de dados
  def set_agrupamento_inicial
    update_column(:agrupamento, id)
  end
end
