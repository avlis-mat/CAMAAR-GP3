FactoryBot.define do
  factory :usuario_materia do
    association :usuario
    association :materia
    papel { "aluno" }

    trait :professor do
      papel { "professor" }
    end
  end
end
