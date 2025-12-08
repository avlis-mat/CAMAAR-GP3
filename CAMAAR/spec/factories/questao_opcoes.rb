FactoryBot.define do
  factory :questao_opcao do
    association :questao
    sequence(:texto) { |n| "Opção #{n}" }
    is_correta { false }
    sequence(:ordem) { |n| n + 1 }
    versao { 1 }
    agrupamento { nil }
    status { "ativo" }

    trait :correta do
      is_correta { true }
    end

    trait :inativa do
      status { 'inativo' }
    end
  end
end
