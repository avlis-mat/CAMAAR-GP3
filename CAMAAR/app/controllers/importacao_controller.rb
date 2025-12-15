# Controller responsável pela importação de dados do SIGAA.
# Permite importar turmas e membros de turmas através de arquivos JSON.
# Apenas administradores podem acessar este controller.
class ImportacaoController < ApplicationController
  before_action :require_login
  before_action :require_admin
  
  # GET /importacao/new
  def new
    # Página com formulário para upload do JSON
  end
  
  # POST /importacao/create
  def create
    unless params[:arquivo].present?
      flash[:alert] = "Selecione um arquivo para importar"
      render :new, status: :unprocessable_entity
      return
    end
    
    arquivo = params[:arquivo]
    tipo = params[:tipo] # 'classes' ou 'class_members' ou 'completo'
    
    begin
      # Ler e parsear JSON
      conteudo = arquivo.read
      dados = JSON.parse(conteudo)
      
      # Processar baseado no tipo
      resultado = case tipo
      when 'classes'
        importar_classes(dados)
      when 'class_members'
        importar_class_members(dados)
      when 'completo'
        # Primeiro importar classes, depois membros
        resultado_classes = importar_classes(dados['classes'] || dados)
        return resultado_classes unless resultado_classes[:sucesso]
        
        importar_class_members(dados['class_members'] || dados)
      else
        { sucesso: false, erro: "Tipo de importação inválido" }
      end
      
      if resultado[:sucesso]
        # Armazenar relatório na sessão para exibir na página de relatório
        session[:ultimo_relatorio] = resultado.except(:relatorio_id)

        flash[:notice] = resultado[:mensagem]
        redirect_to importacao_relatorio_path(resultado[:relatorio_id])
      else
        flash[:alert] = resultado[:erro]
        render :new, status: :unprocessable_entity
      end
      
    rescue JSON::ParserError
      flash[:alert] = "Arquivo JSON inválido. Verifique a sintaxe do arquivo"
      render :new, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "Erro na importação: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      flash[:alert] = "Erro ao processar arquivo: #{e.message}"
      render :new, status: :unprocessable_entity
    end
  end
  
  # GET /importacao/atualizar
  def atualizar
    # Página de confirmação para atualizar do SIGAA
  end
  
  # POST /importacao/atualizar_sigaa
  def atualizar_sigaa
    unless params[:confirmar] == 'true'
      redirect_to importacao_atualizar_path, alert: "Atualização cancelada"
      return
    end
    
    begin
      # TODO: Implementar integração real com SIGAA
      # Por enquanto, simular atualização
      resultado = simular_atualizacao_sigaa
      
      if resultado[:sucesso]
        flash[:notice] = resultado[:mensagem]
        redirect_to root_path
      else
        flash[:alert] = resultado[:erro]
        redirect_to importacao_atualizar_path
      end
      
    rescue => e
      flash[:alert] = "Erro: não foi possível conectar ao SIGAA. Tente novamente mais tarde"
      redirect_to importacao_atualizar_path
    end
  end
  
  # GET /importacao/relatorio/:id
  def relatorio
    @relatorio = session[:ultimo_relatorio]
    
    unless @relatorio
      redirect_to importacao_root_path, alert: "Relatório não encontrado. Faça uma nova importação."
    end
  end
  
  private
  
  def importar_classes(dados)
    turmas_importadas = 0
    turmas_atualizadas = 0
    erros = []
    
    ActiveRecord::Base.transaction do
      dados.each_with_index do |class_data, index|
        # Validar campos obrigatórios
        unless class_data['code'].present?
          erros << "Turma #{index + 1}: campo 'code' obrigatório faltando"
          next
        end
        
        # Extrair dados
        codigo = class_data['code']
        nome = class_data['name']
        codigo_turma = class_data.dig('class', 'classCode') || 'TA'
        semestre = class_data.dig('class', 'semester')
        horario = class_data.dig('class', 'time')
        
        # Extrair departamento do código (primeiros 3 caracteres)
        departamento = codigo[0..2] if codigo.length >= 3
        
        # Validar campos obrigatórios
        unless nome.present? && semestre.present?
          erros << "Turma #{index + 1}: campos obrigatórios faltando (name ou semester)"
          next
        end
        
        # Buscar ou criar turma
        turma = Materia.find_by(
          codigo: codigo,
          codigo_turma: codigo_turma,
          semestre: semestre
        )
        
        if turma
          # Atualizar existente
          turma.update!(
            nome: nome,
            departamento: departamento
          )
          turmas_atualizadas += 1
        else
          # Criar nova
          Materia.create!(
            codigo: codigo,
            codigo_turma: codigo_turma,
            nome: nome,
            departamento: departamento,
            semestre: semestre
          )
          turmas_importadas += 1
        end
        
        Rails.logger.info "Turma processada: #{codigo}-#{codigo_turma}-#{semestre}"
      end
      
      raise ActiveRecord::Rollback if erros.any?
    end
    
    if erros.any?
      {
        sucesso: false,
        erro: "Erro: campos obrigatórios faltando. " + erros.join('; ')
      }
    else
      relatorio = criar_relatorio('classes', turmas_importadas, turmas_atualizadas)
      {
        sucesso: true,
        mensagem: "#{turmas_importadas} turmas importadas com sucesso. #{turmas_atualizadas} atualizadas.",
        relatorio_id: relatorio[:id]
      }
    end
  end
  
  def importar_class_members(dados)
    usuarios_importados = 0
    usuarios_atualizados = 0
    convites_enviados = 0
    erros = []
    
    ActiveRecord::Base.transaction do
      dados.each_with_index do |class_member, index|
        # Extrair informações da turma
        codigo = class_member['code']
        codigo_turma = class_member['classCode']
        semestre = class_member['semester']
        
        # Buscar turma
        turma = Materia.find_by(
          codigo: codigo,
          codigo_turma: codigo_turma,
          semestre: semestre
        )
        
        unless turma
          Rails.logger.warn "Turma não encontrada: #{codigo}-#{codigo_turma}-#{semestre}. Criando..."
          # Criar turma se não existir
          departamento = codigo[0..2] if codigo.length >= 3
          turma = Materia.create!(
            codigo: codigo,
            codigo_turma: codigo_turma,
            nome: "Turma #{codigo}",
            departamento: departamento,
            semestre: semestre
          )
        end
        
        # Importar docente
        if class_member['docente'].present?
          docente_data = class_member['docente']
          resultado_docente = processar_usuario(docente_data, 'professor', turma)
          
          if resultado_docente[:criado]
            usuarios_importados += 1
            convites_enviados += 1 if resultado_docente[:convite_enviado]
          elsif resultado_docente[:atualizado]
            usuarios_atualizados += 1
          end
        end
        
        # Importar dicentes
        if class_member['dicente'].present?
          class_member['dicente'].each do |dicente_data|
            resultado_dicente = processar_usuario(dicente_data, 'aluno', turma)
            
            if resultado_dicente[:criado]
              usuarios_importados += 1
              convites_enviados += 1 if resultado_dicente[:convite_enviado]
            elsif resultado_dicente[:atualizado]
              usuarios_atualizados += 1
            end
          end
        end
        
        Rails.logger.info "Membros processados para turma: #{codigo}-#{codigo_turma}-#{semestre}"
      end
      
      raise ActiveRecord::Rollback if erros.any?
    end
    
    if erros.any?
      {
        sucesso: false,
        erro: erros.join('; ')
      }
    else
      relatorio = criar_relatorio('class_members', usuarios_importados, usuarios_atualizados, convites_enviados)
      {
        sucesso: true,
        mensagem: "#{usuarios_importados} usuários importados. #{usuarios_atualizados} atualizados. #{convites_enviados} convites enviados.",
        relatorio_id: relatorio[:id]
      }
    end
  end
  
  def processar_usuario(usuario_data, tipo, turma)
    # Extrair dados
    matricula = usuario_data['matricula']
    nome = usuario_data['nome']
    email = usuario_data['email']
    curso = usuario_data['curso']
    
    # Extrair departamento do curso (última parte após /)
    departamento = curso&.split('/')&.last || turma.departamento
    
    # Validar campos obrigatórios
    unless matricula.present? && nome.present? && email.present?
      Rails.logger.warn "Usuário com dados incompletos: #{nome}"
      return { criado: false, atualizado: false, convite_enviado: false }
    end
    
    # Validar formato da matrícula (deve ter 9 dígitos)
    # CPF de docentes tem 11, então vamos aceitar 9 ou 11
    unless matricula.match?(/\A\d{9,11}\z/)
      Rails.logger.warn "Matrícula inválida: #{matricula} - #{nome}"
      return { criado: false, atualizado: false, convite_enviado: false }
    end
    
    # Buscar ou criar usuário
    usuario = Usuario.find_by(matricula: matricula)
    criado = false
    atualizado = false
    convite_enviado = false
    
    if usuario
      # Atualizar existente
      usuario.update!(
        nome: nome,
        email: email,
        tipo: tipo,
        departamento: departamento
      )
      atualizado = true
    else
      # Criar novo
      usuario = Usuario.create!(
        matricula: matricula,
        nome: nome,
        email: email,
        tipo: tipo,
        departamento: departamento,
        status: 'pendente',
        password: SecureRandom.hex(16) # Senha temporária
      )
      criado = true
      
      # Enviar convite
      convite_enviado = enviar_convite_para_usuario(usuario)
    end
    
    # Associar à turma
    papel = tipo == 'professor' ? 'professor' : 'aluno'
    UsuarioMateria.find_or_create_by(
      usuario: usuario,
      materia: turma
    ) do |um|
      um.papel = papel
    end
    
    { criado: criado, atualizado: atualizado, convite_enviado: convite_enviado }
  rescue => e
    Rails.logger.error "Erro ao processar usuário #{nome}: #{e.message}"
    { criado: false, atualizado: false, convite_enviado: false }
  end
  
  def enviar_convite_para_usuario(usuario)
    # Criar token de ativação
    token = usuario.token_senhas.create!(tipo: 'ativacao')
    
    # Enviar email
    UsuarioMailer.convite_cadastro(usuario, token).deliver_later
    
    true
  rescue => e
    Rails.logger.error "Erro ao enviar convite para #{usuario.email}: #{e.message}"
    false
  end
  
  def criar_relatorio(tipo, novos, atualizados, convites = 0)
    relatorio = {
      id: SecureRandom.uuid,
      tipo: tipo,
      data: Time.current,
      novos: novos,
      atualizados: atualizados,
      convites_enviados: convites,
      total: novos + atualizados
    }
    
    session[:ultimo_relatorio] = relatorio
    relatorio
  end
  
  def simular_atualizacao_sigaa
    # TODO: Substituir por integração real com SIGAA
    # Por enquanto, retornar sucesso simulado
    
    if rand > 0.5 # Simular disponibilidade do SIGAA
      {
        sucesso: true,
        mensagem: "Base de dados atualizada com sucesso. 15 registros atualizados, 3 novos registros adicionados."
      }
    else
      {
        sucesso: false,
        erro: "SIGAA indisponível"
      }
    end
  end
end
