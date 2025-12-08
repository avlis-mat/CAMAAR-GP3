FactoryBot.define do
  factory :token_senha do
    usuario { nil }
    token { "MyString" }
    tipo { "MyString" }
    expiracao { "2025-12-08 02:06:23" }
    usado { false }
  end
end
