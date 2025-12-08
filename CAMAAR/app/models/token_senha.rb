class TokenSenha < ApplicationRecord
  belongs_to :usuario

  validates :token, presence: true, uniqueness: true
  validates :tipo, presence: true,
            inclusion: { in: %w[ativacao redefinicao] }
  validates :expiracao, presence: true
  
  before_create :gerar_token
  before_create :set_expiracao
  
  scope :validos, -> { 
    where(usado: false).where('expiracao > ?', Time.current) 
  }
  scope :do_tipo, ->(tipo) { where(tipo: tipo) }
  
  def valido?
    !usado && expiracao > Time.current
  end
  
  def usar!
    update!(usado: true)
  end
  
  private
  
  def gerar_token
    self.token = SecureRandom.urlsafe_base64(32)
  end
  
  def set_expiracao
    self.expiracao = 48.hours.from_now
  end

end
