require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the UsuarioMateriasHelper. For example:
#
# describe UsuarioMateriasHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe UsuarioMateriasHelper, type: :helper do
  describe "módulo" do
    it "está disponível como helper" do
      expect(helper).to be_a(ActionView::Base)
    end
  end
end
