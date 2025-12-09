class UsuariosController < ApplicationController
  before_action :require_login
  before_action :require_admin, only: [:index, :new, :create]

  def index
    @usuarios = Usuario.order(:nome).page(params[:page]).per(20)
    
    if params[:busca].present?
      termo = "%#{params[:busca]}%"
      @usuarios = @usuarios.where('nome ILIKE ? OR matricula ILIKE ? OR email ILIKE ?', termo, termo, termo)
    end
  end

  def new
    @usuario = Usuario.new
  end

  def create
    @usuario = Usuario.new(usuario_params)
    @usuario.status = 'pendente'
    # Senha temporária aleatória, pois o usuário definirá a própria senha depois
    senha_temp = SecureRandom.hex(8)
    @usuario.password = senha_temp
    @usuario.password_confirmation = senha_temp

    if @usuario.save
      # Aqui enviaria o email de convite
      # UserMailer.convite(@usuario).deliver_later
      
      redirect_to usuarios_path, notice: 'Usuário cadastrado com sucesso! Um convite foi enviado por e-mail.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def usuario_params
    params.require(:usuario).permit(:nome, :email, :matricula, :tipo, :departamento)
  end
end
