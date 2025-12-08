FactoryBot.define do
  factory :questao do
    modelo { nil }
    enunciado { "MyText" }
    tipo { "MyString" }
    ordem { 1 }
    versao { 1 }
    agrupamento { 1 }
    status { "MyString" }
  end
end
