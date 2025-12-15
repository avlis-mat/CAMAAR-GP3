# app/controllers/usuarios_controller.rb
class UsuariosController < ApplicationController
  before_action :require_login, except: [:definir_senha, :salvar_senha, :redefinir_senha, :enviar_redefinicao, :resetar_senha, :salvar_nova_senha]
  before_action :require_admin, only: [:index, :new, :create, :edit, :update, :enviar_convite, :enviar_convites_lote]
  before_action :set_usuario, only: [:show, :edit, :update, :enviar_convite]
  
  # GET /usuarios
  def index
    @usuarios = Usuario.order(created_at: :desc).page(params[:page]).per(20)
    
    # Filtros
    if params[:status].present?
      @usuarios = @usuarios.where(status: params[:status])
    end
    
    if params[:tipo].present?
      @usuarios = @usuarios.where(tipo: params[:tipo])
    end
    
    if params[:busca].present?
      @usuarios = @usuarios.where(
        'nome ILIKE ? OR email ILIKE ? OR matricula ILIKE ?',
        "%#{params[:busca]}%", "%#{params[:busca]}%", "%#{params[:busca]}%"
      )
    end
    
    # Contadores para dashboard
    @usuarios_pendentes = Usuario.where(status: 'pendente').count
    @usuarios_ativos = Usuario.where(status: 'ativo').count
  end
  
  # GET /usuarios/:id
  def show
    @turmas = @usuario.materias.order(:codigo)
    @formularios_respondidos = @usuario.respostas.select(:formulario_id).distinct.count
  end
  
  # GET /usuarios/new
  def new
    @usuario = Usuario.new
  end
  
  # POST /usuarios
  def create
    @usuario = Usuario.new(usuario_params)
    @usuario.status = 'pendente'
    @usuario.password = SecureRandom.hex(16) # Senha temporária
    
    if @usuario.save
      # Enviar convite
      if enviar_convite_para_usuario(@usuario)
        redirect_to usuarios_path, notice: "Usuário criado e convite enviado para #{@usuario.email}"
      else
        redirect_to usuarios_path, alert: "Usuário criado mas houve erro ao enviar o convite"
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  # POST /usuarios/:id/enviar_convite
  def enviar_convite
    if @usuario.status == 'ativo'
      redirect_to usuarios_path, alert: "Este usuário já possui cadastro ativo"
      return
    end
    
    # Invalidar tokens anteriores
    @usuario.token_senhas.where(tipo: 'ativacao', usado: false).update_all(usado: true)
    
    if enviar_convite_para_usuario(@usuario)
      @usuario.update(status: 'pendente')
      redirect_to usuarios_path, notice: "Convite enviado com sucesso para #{@usuario.email}"
    else
      redirect_to usuarios_path, alert: "Erro ao enviar convite. Tente novamente mais tarde"
    end
  end
  
  # POST /usuarios/enviar_convites_lote
  def enviar_convites_lote
    usuario_ids = params[:usuario_ids] || []
    
    if usuario_ids.empty?
      redirect_to usuarios_path, alert: "Nenhum usuário selecionado"
      return
    end
    
    usuarios = Usuario.where(id: usuario_ids, status: 'pendente')
    enviados = 0
    
    usuarios.each do |usuario|
      if enviar_convite_para_usuario(usuario)
        enviados += 1
      end
    end
    
    redirect_to usuarios_path, notice: "#{enviados} convites enviados com sucesso"
  end
  
  # GET /definir_senha/:token
  def definir_senha
    @token = TokenSenha.find_by(token: params[:token], tipo: 'ativacao')

    Rails.logger.info "Debug definir_senha: token_param=#{params[:token]}, token_found=#{@token.inspect}, valido=#{@token&.valido?}, usado=#{@token&.usado}, expiracao=#{@token&.expiracao}, current_time=#{Time.current}"
    
    unless @token&.valido?
      redirect_to login_path, alert: "Link inválido ou expirado. Solicite um novo convite de cadastro"
      return
    end
    
    @usuario = @token.usuario
    
    # Verificar se já possui senha
    if @usuario.status == 'ativo'
      redirect_to login_path, alert: "Este usuário já possui senha cadastrada. Faça login ou use a opção de redefinição de senha"
    end
  end
  
  # POST /definir_senha/:token
  def salvar_senha
    @token = TokenSenha.find_by(token: params[:token], tipo: 'ativacao')
    
    unless @token&.valido?
      redirect_to login_path, alert: "Link inválido ou expirado. Solicite um novo convite de cadastro"
      return
    end
    
    @usuario = @token.usuario
    
    # Validar senhas
    if params[:senha].blank? || params[:confirmacao_senha].blank?
      flash.now[:alert] = "Todos os campos são obrigatórios"
      render :definir_senha, status: :unprocessable_entity
      return
    end
    
    if params[:senha].length < 6
      flash.now[:alert] = "A senha deve ter no mínimo 6 caracteres"
      render :definir_senha, status: :unprocessable_entity
      return
    end
    
    if params[:senha] != params[:confirmacao_senha]
      flash.now[:alert] = "As senhas não coincidem"
      render :definir_senha, status: :unprocessable_entity
      return
    end
    
    # Atualizar senha e status
    if @usuario.update(password: params[:senha], status: 'ativo')
      @token.usar!
      redirect_to login_path, notice: "Senha definida com sucesso. Você já pode fazer login"
    else
      flash.now[:alert] = "Erro ao definir senha"
      render :definir_senha, status: :unprocessable_entity
    end
  end
  
  # GET /redefinir_senha
  def redefinir_senha
    # Página para solicitar redefinição
  end
  
  # POST /redefinir_senha
  def enviar_redefinicao
    identificacao = params[:identificacao] # email ou matrícula
    
    if identificacao.blank?
      flash.now[:alert] = "Informe seu email ou matrícula"
      render :redefinir_senha, status: :unprocessable_entity
      return
    end
    
    # Buscar usuário por email ou matrícula
    usuario = Usuario.find_by(email: identificacao) || Usuario.find_by(matricula: identificacao)
    
    unless usuario
      flash.now[:alert] = "Email ou matrícula não encontrada no sistema"
      render :redefinir_senha, status: :unprocessable_entity
      return
    end
    
    # Criar token de redefinição
    token = usuario.token_senhas.create!(tipo: 'redefinicao')
    
    # Enviar email
    begin
      UsuarioMailer.redefinir_senha(usuario, token).deliver_later
      redirect_to login_path, notice: "Instruções para redefinir sua senha foram enviadas para seu e-mail"
    rescue => e
      Rails.logger.error "Erro ao enviar email: #{e.message}"
      flash.now[:alert] = "Erro ao enviar email. Tente novamente mais tarde"
      render :redefinir_senha, status: :unprocessable_entity
    end
  end
  
  # GET /resetar_senha/:token
  def resetar_senha
    @token = TokenSenha.find_by(token: params[:token], tipo: 'redefinicao')
    
    unless @token&.valido?
      redirect_to redefinir_senha_path, alert: "Link inválido ou expirado. Solicite uma nova redefinição de senha"
      return
    end
    
    @usuario = @token.usuario
  end
  
  # POST /resetar_senha/:token
  def salvar_nova_senha
    @token = TokenSenha.find_by(token: params[:token], tipo: 'redefinicao')
    
    unless @token&.valido?
      redirect_to redefinir_senha_path, alert: "Link inválido ou expirado. Solicite uma nova redefinição de senha"
      return
    end
    
    @usuario = @token.usuario
    
    # Validar senhas
    if params[:senha].blank? || params[:confirmacao_senha].blank?
      flash.now[:alert] = "Todos os campos são obrigatórios"
      render :resetar_senha, status: :unprocessable_entity
      return
    end
    
    if params[:senha].length < 6
      flash.now[:alert] = "A senha deve ter no mínimo 6 caracteres"
      render :resetar_senha, status: :unprocessable_entity
      return
    end
    
    if params[:senha] != params[:confirmacao_senha]
      flash.now[:alert] = "As senhas não coincidem"
      render :resetar_senha, status: :unprocessable_entity
      return
    end
    
    # Atualizar senha
    if @usuario.update(password: params[:senha])
      @token.usar!
      redirect_to login_path, notice: "Senha redefinida com sucesso"
    else
      flash.now[:alert] = "Erro ao redefinir senha"
      render :resetar_senha, status: :unprocessable_entity
    end
  end

  # GET /usuarios/:id/edit
    def edit
    # @usuario já setado pelo before_action
    end

    # PATCH/PUT /usuarios/:id
    def update
        if @usuario.update(usuario_params)
            redirect_to @usuario, notice: "Usuário atualizado com sucesso"
        else
            render :edit, status: :unprocessable_entity
        end
    end
  
    def ativar
    @usuario = Usuario.find(params[:id])
    if @usuario.update(status: 'ativo')
      redirect_to usuarios_path, notice: 'Usuário ativado com sucesso'
    else
      redirect_to usuarios_path, alert: 'Erro ao ativar usuário'
    end
  end

  def desativar
    @usuario = Usuario.find(params[:id])
    if @usuario.update(status: 'inativo')
      redirect_to usuarios_path, notice: 'Usuário desativado com sucesso'
    else
      redirect_to usuarios_path, alert: 'Erro ao desativar usuário'
    end
  end
    
  
  private
  
  def set_usuario
    @usuario = Usuario.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to usuarios_path, alert: "Usuário não encontrado"
  end
  
  def usuario_params
    params.require(:usuario).permit(:nome, :email, :matricula, :tipo, :departamento)
  end
  
  def enviar_convite_para_usuario(usuario)
    # Criar token de ativação
    token = usuario.token_senhas.create!(tipo: 'ativacao')
    
    # Enviar email
    UsuarioMailer.convite_cadastro(usuario, token).deliver_now
    
    true
  rescue => e
    Rails.logger.error "Erro ao enviar convite: #{e.message}"
    false
  end
end