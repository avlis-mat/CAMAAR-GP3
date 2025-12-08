FactoryBot.define do
  factory :materia do
    sequence(:codigo) { |n| "MAT#{format('%04d', n + 1000)}" }
    sequence(:codigo_turma) { |n| "T#{('A'.ord + (n % 3)).chr}" }
    sequence(:nome) { |n| "Matéria #{n}" }
    departamento { 'ENE' }
    semestre { '2025.1' }
    professor { 'Prof. Teste' }
    horario { 'Ter/Qui 10:00' }
  end
end
