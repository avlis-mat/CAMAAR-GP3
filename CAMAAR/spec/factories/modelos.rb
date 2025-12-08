FactoryBot.define do
  factory :modelo do
    sequence(:nome) { |n| "Modelo #{n}" }
    descricao { "Descrição do modelo" }
    association :usuario, factory: [:usuario, :professor]
    versao { 1 }
    agrupamento { nil }
    status { "ativo" }

    trait :inativo do
      status { 'inativo' }
    end
  end
end
