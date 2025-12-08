FactoryBot.define do
  factory :questao do
    association :modelo
    sequence(:enunciado) { |n| "Enunciado da questão #{n}" }
    tipo { "dissertativa" }
    sequence(:ordem) { |n| n + 1 }
    versao { 1 }
    agrupamento { nil }
    status { "ativo" }

    trait :multipla_escolha do
      tipo { 'multipla_escolha' }

      after(:create) do |questao|
        create_list(:questao_opcao, 2, questao: questao)
      end
    end

    trait :inativo do
      status { 'inativo' }
    end
  end
end
