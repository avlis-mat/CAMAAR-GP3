require 'rails_helper'

RSpec.describe HomeHelper, type: :helper do
  describe "módulo" do
    it "está disponível como helper" do
      expect(helper).to respond_to(:root_path)
    end
  end
end
