# frozen_string_literal: true

# Configuração do Capybara para testes Cucumber

require 'capybara/rails'
require 'capybara/cucumber'
require 'selenium-webdriver'

# Configurar driver padrão
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless

# Configurações do Capybara
Capybara.default_max_wait_time = 5
Capybara.server_port = 3001

# Configurar Selenium para Chrome headless
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1920,1080')
  
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Helper para limpar sessão entre testes
Before do
  # Limpar sessão do Capybara
  Capybara.reset_sessions!
end

