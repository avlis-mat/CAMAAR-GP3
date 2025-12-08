FactoryBot.define do
  factory :usuario do
    sequence(:matricula) { |n| format('%09d', 100_000_000 + n) }
    nome { Faker::Name.name }
    sequence(:email) { |n| "usuario#{n}@unb.br" }
    password { 'senha123' }
    password_confirmation { 'senha123' }
    tipo { 'aluno' }
    departamento { 'CIC' }
    status { 'ativo' }

    trait :administrador do
      tipo { 'administrador' }
    end

    trait :professor do
      tipo { 'professor' }
    end

    trait :inativo do
      status { 'inativo' }
    end

    trait :pendente do
      status { 'pendente' }
    end
  end
end
