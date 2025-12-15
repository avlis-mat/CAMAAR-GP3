# Modelo que representa uma resposta de um usuário a uma questão de um formulário.
#
# Uma resposta pode ser do tipo dissertativa (com conteúdo textual) ou
# múltipla escolha (com opção selecionada). Cada usuário só pode responder
# uma vez cada questão de um formulário.
#
# @example Criar uma resposta dissertativa
#   resposta = Resposta.new(
#     formulario: formulario,
#     usuario: usuario,
#     questao: questao,
#     conteudo: "Minha resposta textual"
#   )
class Resposta < ApplicationRecord
  belongs_to :formulario
  belongs_to :usuario
  belongs_to :questao
  belongs_to :questao_opcao, optional: true # Apenas para múltipla escolha

  validates :usuario_id, uniqueness: { 
    scope: [:formulario_id, :questao_id],
    message: "já respondeu esta questão"
  }
  validate :conteudo_ou_opcao_presente
  validate :opcao_pertence_a_questao, if: :questao_opcao_id?
  
  before_create :set_respondido_em
  
  scope :do_formulario, ->(form_id) { where(formulario_id: form_id) }
  
  private
  
  # Validação customizada: verifica se a resposta possui conteúdo ou opção.
  # Para questões dissertativas, o conteúdo é obrigatório.
  # Para questões de múltipla escolha, a opção é obrigatória.
  #
  # @return [void]
  # @note Efeito colateral: adiciona erro de validação se a condição não for atendida
  def conteudo_ou_opcao_presente
    if questao.tipo == 'dissertativa' && conteudo.blank?
      errors.add(:conteudo, "não pode ficar em branco")
    elsif questao.tipo == 'multipla_escolha' && questao_opcao_id.blank?
      errors.add(:questao_opcao_id, "deve selecionar uma opção")
    end
  end
  
  # Validação customizada: verifica se a opção selecionada pertence à questão.
  #
  # @return [void]
  # @note Efeito colateral: adiciona erro de validação se a opção não pertencer à questão
  def opcao_pertence_a_questao
    unless questao_opcao.questao_id == questao_id
      errors.add(:questao_opcao_id, "não pertence à questão")
    end
  end
  
  # Define a data/hora de resposta antes de criar o registro.
  # Este método é chamado automaticamente pelo callback before_create.
  #
  # @return [void]
  # @note Efeito colateral: define o campo respondido_em com a data/hora atual
  def set_respondido_em
    self.respondido_em = Time.current
  end
end
