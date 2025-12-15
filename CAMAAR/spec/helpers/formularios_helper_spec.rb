require 'rails_helper'

RSpec.describe FormulariosHelper, type: :helper do
  describe "módulo" do
    it "está disponível como helper" do
      expect(helper).to respond_to(:formularios_path)
    end
  end
end
