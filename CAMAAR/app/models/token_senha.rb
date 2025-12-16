# Modelo que representa um token de segurança para ativação ou redefinição de senha.
#
# Tokens são gerados automaticamente e possuem tempo de expiração.
# Tokens de ativação expiram em 48 horas, tokens de redefinição em 24 horas.
#
# @example Criar token de ativação
#   token = TokenSenha.new(
#     usuario: usuario,
#     tipo: "ativacao"
#   )
class TokenSenha < ApplicationRecord
  belongs_to :usuario

  validates :token, presence: true, uniqueness: true
  validates :tipo, presence: true,
            inclusion: { in: %w[ativacao redefinicao] }
  validates :expiracao, presence: true
  
  before_validation :gerar_token, on: :create
  before_validation :set_expiracao, on: :create
  
  scope :validos, -> { 
    where(usado: false).where('expiracao > ?', Time.current) 
  }
  scope :do_tipo, ->(tipo) { where(tipo: tipo) }
  scope :expirados, -> { where('expiracao <= ?', Time.current) }
  
  # Verifica se o token é válido (não usado e não expirado).
  #
  # @return [Boolean] true se o token não foi usado e não expirou, false caso contrário
  def valido?
    !usado && expiracao > Time.current
  end
  
  # Verifica se o token expirou.
  #
  # @return [Boolean] true se a expiração é anterior ou igual à data atual, false caso contrário
  def expirado?
    expiracao <= Time.current
  end
  
  # Marca o token como usado e registra a data/hora de uso.
  #
  # @return [void]
  # @raise [ActiveRecord::RecordInvalid] se não conseguir atualizar o registro
  # @note Efeito colateral: atualiza os campos usado e usado_em no banco de dados
  def usar!
    update!(usado: true, usado_em: Time.current)
  end
  
  # Retorna o tempo restante até a expiração do token em horas.
  #
  # @return [Integer] número de horas restantes (0 se já expirado)
  def tempo_restante
    return 0 if expirado?
    ((expiracao - Time.current) / 1.hour).round
  end
  
  private
  
  # Gera um token seguro e único antes da validação.
  # Este método é chamado automaticamente pelo callback before_validation.
  #
  # @return [void]
  # @note Efeito colateral: define o campo token com um valor aleatório único
  def gerar_token
    return if token.present?
    # Gerar token seguro e único
    loop do
      self.token = SecureRandom.urlsafe_base64(32, false)
      break unless TokenSenha.exists?(token: token)
    end
  end
  
  # Define a data de expiração baseada no tipo de token.
  # Este método é chamado automaticamente pelo callback before_validation.
  #
  # @return [void]
  # @note Efeito colateral: define o campo expiracao:
  #   - 48 horas a partir de agora para tokens de ativação
  #   - 24 horas a partir de agora para tokens de redefinição
  def set_expiracao
    return if expiracao.present?
    # Ativação: 48 horas
    # Redefinição: 24 horas
    self.expiracao = case tipo
    when 'ativacao'
      48.hours.from_now
    when 'redefinicao'
      24.hours.from_now
    else
      24.hours.from_now
    end
  end
end
