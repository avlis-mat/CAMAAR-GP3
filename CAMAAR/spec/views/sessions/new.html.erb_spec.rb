require 'rails_helper'

RSpec.describe "sessions/new.html.erb", type: :view do
  it "renderiza o formulário de login com sucesso" do
    render
    expect(rendered).to be_present
  end
end
