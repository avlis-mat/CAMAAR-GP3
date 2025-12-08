FactoryBot.define do
  factory :usuario do
    matricula { "MyString" }
    nome { "MyString" }
    email { "MyString" }
    password_digest { "MyString" }
    tipo { "MyString" }
    departamento { "MyString" }
    status { "MyString" }
  end
end
