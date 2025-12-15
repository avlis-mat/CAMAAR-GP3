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
  
  def valido?
    !usado && expiracao > Time.current
  end
  
  def expirado?
    expiracao <= Time.current
  end
  
  def usar!
    update!(usado: true, usado_em: Time.current)
  end
  
  def tempo_restante
    return 0 if expirado?
    ((expiracao - Time.current) / 1.hour).round
  end
  
  private
  
  def gerar_token
    return if token.present?
    # Gerar token seguro e único
    loop do
      self.token = SecureRandom.urlsafe_base64(32, false)
      break unless TokenSenha.exists?(token: token)
    end
  end
  
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
