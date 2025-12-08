FactoryBot.define do
  factory :resposta do
    association :formulario
    association :usuario
    association :questao, strategy: :build
    questao_opcao { nil }
    conteudo { "Resposta dissertativa" }
    respondido_em { nil }

    trait :multipla_escolha do
      association :questao, factory: [:questao, :multipla_escolha]
      after(:build) do |resposta|
        resposta.questao_opcao ||= resposta.questao.questao_opcoes.first
        resposta.conteudo = nil
      end
    end
  end
end
