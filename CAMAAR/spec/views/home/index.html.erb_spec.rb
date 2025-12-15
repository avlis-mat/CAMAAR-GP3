require 'rails_helper'

RSpec.describe "home/index.html.erb", type: :view do
  it "renderiza a página inicial com sucesso" do
    render
    expect(rendered).to be_present
  end
end
