FactoryBot.define do
  factory :modelo do
    nome { 'Modelo Exemplo' }
    descricao { "Descrição do modelo" }
    association :usuario, factory: [:usuario, :professor]
    versao { 1 }
    status { "ativo" }

    after(:create) do |modelo|
      modelo.update(agrupamento: modelo.id) if modelo.agrupamento.nil?
    end

    trait :inativo do
      status { 'inativo' }
    end

    trait :com_questoes do
      after(:create) do |modelo|
        create_list(:questao, 3, modelo: modelo)
      end
    end
    
    after(:create) do |modelo, evaluator|
      create_list(:questao, evaluator.num_questoes, modelo: modelo)
    end

  end
end
