FactoryBot.define do
  factory :usuario do
    sequence(:matricula) { |n| format('%09d', 100_000_000 + n) }
    sequence(:nome) { |n| "Usuário #{n}" }
    sequence(:email) { |n| "usuario#{n}@example.com" }
    password { 'SenhaSegura123!' }
    password_confirmation { 'SenhaSegura123!' }
    tipo { 'aluno' }
    departamento { 'ENG' }
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
  end
end
