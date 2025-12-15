require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  describe "módulo" do
    it "está disponível como helper" do
      expect(helper).to respond_to(:login_path)
    end
  end
end
