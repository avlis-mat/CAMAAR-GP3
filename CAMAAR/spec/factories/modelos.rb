FactoryBot.define do
  factory :modelo do
    nome { "MyString" }
    descricao { "MyText" }
    usuario { nil }
    versao { 1 }
    agrupamento { 1 }
    status { "MyString" }
  end
end
