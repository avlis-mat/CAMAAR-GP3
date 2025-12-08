FactoryBot.define do
  factory :token_senha do
    association :usuario
    token { nil }
    tipo { "ativacao" }
    expiracao { nil }
    usado { false }

    trait :redefinicao do
      tipo { "redefinicao" }
    end
  end
end
