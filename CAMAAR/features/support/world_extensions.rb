# frozen_string_literal: true

# Extensões do World para testes Cucumber

module CucumberWorld
  # Helper para gerar matrícula válida
  def gerar_matricula_valida
    format('%09d', rand(100_000_000..999_999_999))
  end

  # Helper para limpar dados entre testes
  def clean_database
    DatabaseCleaner.clean
  end

  # Helper para criar usuário de teste
  def create_test_user(email:, tipo: 'aluno', status: 'ativo')
    Usuario.find_or_create_by!(email: email) do |u|
      u.matricula = gerar_matricula_valida
      u.nome = 'Usuário Teste'
      u.tipo = tipo
      u.status = status
      u.password = 'senha123'
      u.password_confirmation = 'senha123'
    end
  end

  # Helper para fazer login
  def login_as(usuario)
    visit login_path
    fill_in 'Email ou Matrícula', with: usuario.email
    fill_in 'Senha', with: usuario.password || 'senha123'
    click_button 'Entrar'
  end
end

World(CucumberWorld)
