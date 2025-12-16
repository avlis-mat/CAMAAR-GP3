# Controller responsável pelo gerenciamento de usuários do sistema.
# Permite criar, editar, visualizar usuários e gerenciar convites de cadastro.
class UsuariosController < ApplicationController
  before_action :require_login, except: [:definir_senha, :salvar_senha, :redefinir_senha, :enviar_redefinicao, :resetar_senha, :salvar_nova_senha]
  before_action :require_admin, only: [:index, :new, :create, :edit, :update, :enviar_convite, :enviar_convites_lote]
  before_action :set_usuario, only: [:show, :edit, :update, :enviar_convite]
  
  # Lista todos os usuários do sistema com paginação e filtros.
  # Apenas administradores podem acessar esta ação.
  #
  # @return [void]
  # @note Define variáveis de instância:
  #   - @usuarios: lista paginada de usuários (20 por página)
  #   - @usuarios_pendentes: contador de usuários pendentes
  #   - @usuarios_ativos: contador de usuários ativos
  # @note Filtros disponíveis via params:
  #   - status: filtra por status (pendente, ativo, inativo)
  #   - tipo: filtra por tipo (administrador, aluno, professor)
  #   - busca: busca por nome, email ou matrícula
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
  
  # Exibe os detalhes de um usuário específico.
  #
  # @return [void]
  # @note Define variáveis de instância:
  #   - @usuario: usuário a ser exibido (definido por set_usuario)
  #   - @turmas: matérias associadas ao usuário
  #   - @formularios_respondidos: contador de formulários respondidos pelo usuário
  def show
    @turmas = @usuario.materias.order(:codigo)
    @formularios_respondidos = @usuario.respostas.select(:formulario_id).distinct.count
  end
  
  # Exibe formulário para criação de novo usuário.
  # Apenas administradores podem acessar esta ação.
  #
  # @return [void]
  # @note Define variável de instância:
  #   - @usuario: novo objeto Usuario
  def new
    @usuario = Usuario.new
  end
  
  # Cria um novo usuário e envia convite de cadastro por email.
  # Apenas administradores podem acessar esta ação.
  #
  # @return [void]
  # @note Efeito colateral:
  #   - Cria novo registro de usuário no banco de dados
  #   - Define senha temporária aleatória
  #   - Envia email de convite para cadastro
  #   - Redireciona para usuarios_path em caso de sucesso
  #   - Renderiza :new em caso de erro
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
  
  # Envia convite de cadastro para um usuário específico.
  # Apenas administradores podem acessar esta ação.
  #
  # @return [void]
  # @note Efeito colateral:
  #   - Invalida tokens de ativação anteriores do usuário
  #   - Cria novo token de ativação
  #   - Envia email de convite
  #   - Atualiza status do usuário para 'pendente'
  #   - Redireciona para usuarios_path
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
  
  # Envia convites de cadastro para múltiplos usuários em lote.
  # Apenas administradores podem acessar esta ação.
  #
  # @param usuario_ids [Array<Integer>] array de IDs dos usuários selecionados
  # @return [void]
  # @note Efeito colateral:
  #   - Envia convites para todos os usuários pendentes selecionados
  #   - Redireciona para usuarios_path com mensagem de sucesso
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
  
  # Exibe formulário para definição de senha inicial usando token de ativação.
  # Não requer autenticação.
  #
  # @param token [String] token de ativação recebido por email
  # @return [void]
  # @note Efeito colateral:
  #   - Redireciona para login_path se token inválido ou expirado
  #   - Define variáveis de instância:
  #     - @token: token de ativação encontrado
  #     - @usuario: usuário associado ao token
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
  
  # Processa a definição de senha inicial do usuário.
  # Não requer autenticação.
  #
  # @param token [String] token de ativação recebido por email
  # @param senha [String] nova senha do usuário
  # @param confirmacao_senha [String] confirmação da senha
  # @return [void]
  # @note Efeito colateral:
  #   - Valida senha (mínimo 6 caracteres, deve coincidir com confirmação)
  #   - Atualiza senha e status do usuário para 'ativo'
  #   - Marca token como usado
  #   - Redireciona para login_path em caso de sucesso
  #   - Renderiza :definir_senha em caso de erro
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
  
  # Exibe formulário para solicitar redefinição de senha.
  # Não requer autenticação.
  #
  # @return [void]
  def redefinir_senha
    # Página para solicitar redefinição
  end
  
  # Processa solicitação de redefinição de senha e envia email com token.
  # Não requer autenticação.
  #
  # @param identificacao [String] email ou matrícula do usuário
  # @return [void]
  # @note Efeito colateral:
  #   - Busca usuário por email ou matrícula
  #   - Cria token de redefinição
  #   - Envia email com link de redefinição
  #   - Redireciona para login_path em caso de sucesso
  #   - Renderiza :redefinir_senha em caso de erro
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
  
  # Exibe formulário para redefinir senha usando token de redefinição.
  # Não requer autenticação.
  #
  # @param token [String] token de redefinição recebido por email
  # @return [void]
  # @note Efeito colateral:
  #   - Redireciona para redefinir_senha_path se token inválido ou expirado
  #   - Define variáveis de instância:
  #     - @token: token de redefinição encontrado
  #     - @usuario: usuário associado ao token
  def resetar_senha
    @token = TokenSenha.find_by(token: params[:token], tipo: 'redefinicao')
    
    unless @token&.valido?
      redirect_to redefinir_senha_path, alert: "Link inválido ou expirado. Solicite uma nova redefinição de senha"
      return
    end
    
    @usuario = @token.usuario
  end
  
  # Processa a redefinição de senha do usuário.
  # Não requer autenticação.
  #
  # @param token [String] token de redefinição recebido por email
  # @param senha [String] nova senha do usuário
  # @param confirmacao_senha [String] confirmação da senha
  # @return [void]
  # @note Efeito colateral:
  #   - Valida senha (mínimo 6 caracteres, deve coincidir com confirmação)
  #   - Atualiza senha do usuário
  #   - Marca token como usado
  #   - Redireciona para login_path em caso de sucesso
  #   - Renderiza :resetar_senha em caso de erro
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

  # Exibe formulário para edição de um usuário existente.
  # Apenas administradores podem acessar esta ação.
  #
  # @return [void]
  # @note Define variável de instância:
  #   - @usuario: usuário a ser editado (definido por set_usuario)
  def edit
    # @usuario já setado pelo before_action
    end

    # Atualiza os dados de um usuário existente.
    # Apenas administradores podem acessar esta ação.
    #
    # @return [void]
    # @note Efeito colateral:
    #   - Atualiza registro do usuário no banco de dados
    #   - Redireciona para @usuario em caso de sucesso
    #   - Renderiza :edit em caso de erro
    def update
        if @usuario.update(usuario_params)
            redirect_to @usuario, notice: "Usuário atualizado com sucesso"
        else
            render :edit, status: :unprocessable_entity
        end
    end
  
    # Ativa um usuário, alterando seu status para 'ativo'.
    #
    # @return [void]
    # @note Efeito colateral:
    #   - Atualiza status do usuário para 'ativo' no banco de dados
    #   - Redireciona para usuarios_path
    def ativar
    @usuario = Usuario.find(params[:id])
    if @usuario.update(status: 'ativo')
      redirect_to usuarios_path, notice: 'Usuário ativado com sucesso'
    else
      redirect_to usuarios_path, alert: 'Erro ao ativar usuário'
    end
  end

  # Desativa um usuário, alterando seu status para 'inativo'.
  #
  # @return [void]
  # @note Efeito colateral:
  #   - Atualiza status do usuário para 'inativo' no banco de dados
  #   - Redireciona para usuarios_path
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
  
  # Envia convite de cadastro para um usuário específico.
  # Cria token de ativação e envia email.
  #
  # @param usuario [Usuario] usuário para o qual enviar o convite
  # @return [Boolean] true se o convite foi enviado com sucesso, false caso contrário
  # @note Efeito colateral:
  #   - Cria novo token de ativação para o usuário
  #   - Envia email de convite via UsuarioMailer
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