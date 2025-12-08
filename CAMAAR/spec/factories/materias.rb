FactoryBot.define do
  factory :materia do
    sequence(:codigo) { |n| "MAT#{format('%04d', n + 1000)}" }
    sequence(:codigo_turma) { |n| "T#{('A'.ord + (n % 3)).chr}" }
    nome { "Disciplina #{Faker::Educator.subject}" }
    departamento { 'EST' }
    semestre { '2025.1' }
    professor { Faker::Name.name }
    horario { '35M34' }
  end
end
