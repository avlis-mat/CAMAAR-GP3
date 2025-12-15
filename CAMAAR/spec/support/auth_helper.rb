module AuthHelper
  def sign_in(usuario)
    post login_path, params: { email: usuario.email, password: usuario.password || 'senha123' }
  end

  def sign_in_direct(usuario)
    # Para request specs, precisamos simular a sessão de forma diferente
    # Usando allow_any_instance_of para mockar o método current_usuario
    allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(usuario)
    allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:administrador?).and_return(usuario.administrador?)
    allow_any_instance_of(ApplicationController).to receive(:aluno?).and_return(usuario.aluno?)
    allow_any_instance_of(ApplicationController).to receive(:professor?).and_return(usuario.professor?)
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end

