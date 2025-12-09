class Resposta < ApplicationRecord
  belongs_to :formulario
  belongs_to :usuario
  belongs_to :questao
  belongs_to :questao_opcao, optional: true

  validates :usuario_id, uniqueness: { 
    scope: [:formulario_id, :questao_id],
    message: "já respondeu esta questão"
  }
  validate :conteudo_ou_opcao_presente
  validate :opcao_pertence_a_questao, if: :questao_opcao_id?
  
  before_create :set_respondido_em
  
  scope :do_formulario, ->(form_id) { where(formulario_id: form_id) }
  
  private
  
  def conteudo_ou_opcao_presente
    if questao.tipo == 'dissertativa' && conteudo.blank?
      errors.add(:conteudo, "não pode ficar em branco")
    elsif questao.tipo == 'multipla_escolha' && questao_opcao_id.blank?
      errors.add(:questao_opcao_id, "deve selecionar uma opção")
    end
  end
  
  def opcao_pertence_a_questao
    unless questao_opcao.questao_id == questao_id
      errors.add(:questao_opcao_id, "não pertence à questão")
    end
  end
  
  def set_respondido_em
    self.respondido_em = Time.current
  end
end
