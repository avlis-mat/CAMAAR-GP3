FactoryBot.define do
  factory :resposta do
    formulario { nil }
    usuario { nil }
    questao { nil }
    questao_opcao { nil }
    conteudo { "MyText" }
    respondido_em { "2025-12-08 02:01:47" }
  end
end
