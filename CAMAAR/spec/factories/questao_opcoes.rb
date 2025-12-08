FactoryBot.define do
  factory :questao_opcao do
    questao { nil }
    texto { "MyText" }
    is_correta { false }
    ordem { 1 }
    versao { 1 }
    agrupamento { 1 }
    status { "MyString" }
  end
end
