require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ModelosHelper. For example:
#
# describe ModelosHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ModelosHelper, type: :helper do
  describe "módulo" do
    it "está disponível como helper" do
      expect(helper).to respond_to(:modelos_path)
    end
  end
end
