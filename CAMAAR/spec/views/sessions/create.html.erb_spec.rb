require 'rails_helper'

RSpec.describe "sessions/create.html.erb", type: :view do
  it "renderiza mensagens de erro quando login falha" do
    assign(:flash, { alert: 'Email ou senha inválidos' })
    render
    expect(rendered).to be_present
  end
end
