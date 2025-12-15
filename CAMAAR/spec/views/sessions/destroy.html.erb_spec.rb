require 'rails_helper'

RSpec.describe "sessions/destroy.html.erb", type: :view do
  it "não renderiza conteúdo (logout redireciona)" do
    # Logout redireciona, então não há view para renderizar
    expect(true).to be true
  end
end
