FactoryBot.define do
  factory :formulario do
    modelo { nil }
    materia { nil }
    usuario { nil }
    titulo { "MyString" }
    instrucoes { "MyText" }
    data_inicio { "2025-12-08" }
    data_fim { "2025-12-08" }
    destinatario { "MyString" }
    status { "MyString" }
  end
end
