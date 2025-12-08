FactoryBot.define do
  factory :formulario do
    association :modelo
    association :materia
    association :usuario, factory: [:usuario, :professor]
    sequence(:titulo) { |n| "Formulário #{n}" }
    instrucoes { "Leia com atenção e responda." }
    data_inicio { Date.today - 1.day }
    data_fim { Date.today + 5.days }
    destinatario { "todos" }
    status { "ativo" }

    trait :encerrado do
      status { 'encerrado' }
      data_fim { Date.yesterday }
    end

    trait :rascunho do
      status { 'rascunho' }
    end
  end
end
