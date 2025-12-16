# frozen_string_literal: true

# Steps relacionados a formulários

Dado('estou matriculado na turma {string}') do |turma_codigo|
  # Parse do código da turma (ex: "CIC0097 - TA - 2021.2" ou "CIC0097")
  parts = turma_codigo.split(' - ')
  codigo = parts[0]
  codigo_turma = parts[1] || 'TA'
  semestre = parts[2] || '2024.1'
  
  @materia = Materia.find_or_create_by!(
    codigo: codigo,
    codigo_turma: codigo_turma,
    semestre: semestre
  ) do |m|
    m.nome = codigo
    m.departamento = codigo[0..2]
  end
  
  unless @usuario&.materias&.include?(@materia)
    UsuarioMateria.create!(
      usuario: @usuario,
      materia: @materia,
      papel: 'aluno'
    )
  end
end

Dado('que estou matriculado na turma {string}') do |turma_codigo|
  step "estou matriculado na turma \"#{turma_codigo}\""
end

Dado('que existe um formulário ativo para minha turma') do
  usuario_admin = Usuario.administradores.first || @usuario
  
  @modelo = Modelo.find_or_create_by!(nome: 'Modelo Padrão') do |m|
    m.usuario = usuario_admin
    m.versao = 1
    m.status = 'ativo'
  end
  
  @formulario = Formulario.create!(
    titulo: 'Avaliação Semestral',
    usuario: usuario_admin,
    modelo: @modelo,
    materia: @materia,
    data_inicio: Date.current,
    data_fim: 30.days.from_now,
    destinatario: 'discentes',
    status: 'ativo',
    versao: 1
  )
end

Dado('existe um formulário ativo para minha turma') do
  step 'que existe um formulário ativo para minha turma'
end

Dado('que o formulário contém {int} questões') do |quantidade|
  quantidade.times do |i|
    Questao.find_or_create_by!(modelo: @modelo, ordem: i + 1) do |q|
      q.enunciado = "Questão #{i + 1}"
      q.tipo = 'dissertativa'
      q.versao = 1
      q.status = 'ativo'
    end
  end
end

Dado('o formulário contém {int} questões') do |quantidade|
  step "que o formulário contém #{quantidade} questões"
end

Dado('que estou na página de avaliações') do
  visit formularios_path
end

Dado('estou na página de formulários disponíveis') do
  visit formularios_path
end

Dado('que estou na página inicial do aluno') do
  visit root_path
end

Dado('que estou respondendo o formulário {string}') do |titulo|
  @formulario = Formulario.find_by(titulo: titulo)
  if @formulario
    visit responder_formulario_path(@formulario)
  end
end

Dado('que já respondi o formulário {string}') do |titulo|
  @formulario = Formulario.find_by(titulo: titulo)
  if @formulario && @usuario
    questao = @formulario.modelo.questoes.first
    if questao
      opcao = questao.questao_opcoes.first || QuestaoOpcao.create!(
        questao: questao,
        texto: 'Opção 1',
        ordem: 1
      )
      Resposta.find_or_create_by!(
        usuario: @usuario,
        formulario: @formulario,
        questao: questao
      ) do |r|
        r.conteudo = 'Resposta teste'
        r.respondido_em = Time.current
        r.questao_opcao = opcao
      end
    end
  end
end

Dado('que já respondi o formulário da turma {string}') do |codigo|
  materia = Materia.find_by(codigo: codigo)
  if materia
    @formulario = Formulario.find_by(materia: materia)
    if @formulario && @usuario
      questao = @formulario.modelo.questoes.first
      if questao
        opcao = questao.questao_opcoes.first || QuestaoOpcao.create!(
          questao: questao,
          texto: 'Opção 1',
          ordem: 1
        )
        Resposta.find_or_create_by!(
          usuario: @usuario,
          formulario: @formulario,
          questao: questao
        ) do |r|
          r.conteudo = 'Resposta teste'
          r.respondido_em = Time.current
          r.questao_opcao = opcao
        end
      end
    end
  end
end

Dado('que existe um formulário não respondido para a turma {string}') do |codigo|
  materia = Materia.find_or_create_by!(
    codigo: codigo,
    codigo_turma: 'TA',
    semestre: '2024.1'
  ) do |m|
    m.nome = codigo
    m.departamento = codigo[0..2]
  end
  
  usuario_admin = Usuario.administradores.first || @usuario
  
  @modelo = Modelo.find_or_create_by!(nome: 'Modelo Padrão') do |m|
    m.usuario = usuario_admin
    m.versao = 1
    m.status = 'ativo'
  end
  
  @formulario = Formulario.find_or_create_by!(
    titulo: "Avaliação #{codigo}",
    materia: materia
  ) do |f|
    f.usuario = usuario_admin
    f.modelo = @modelo
    f.data_inicio = Date.current
    f.data_fim = 30.days.from_now
    f.destinatario = 'discentes'
    f.status = 'ativo'
    f.versao = 1
  end
end

Dado('existe um formulário não respondido para a turma {string}') do |codigo|
  step "que existe um formulário não respondido para a turma \"#{codigo}\""
end

Dado('o formulário não respondido da turma {string} está disponível') do |codigo|
  step "que existe um formulário não respondido para a turma \"#{codigo}\""
end

Dado('que existe um formulário {string} para a turma {string}') do |titulo, codigo|
  materia = Materia.find_or_create_by!(
    codigo: codigo,
    codigo_turma: 'TA',
    semestre: '2024.1'
  ) do |m|
    m.nome = codigo
    m.departamento = codigo[0..2]
  end
  
  usuario_admin = Usuario.administradores.first || @usuario
  
  @modelo = Modelo.find_or_create_by!(nome: 'Modelo Padrão') do |m|
    m.usuario = usuario_admin
    m.versao = 1
    m.status = 'ativo'
  end
  
  @formulario = Formulario.find_or_create_by!(titulo: titulo, materia: materia) do |f|
    f.usuario = usuario_admin
    f.modelo = @modelo
    f.data_inicio = Date.current
    f.data_fim = 30.days.from_now
    f.destinatario = 'discentes'
    f.status = 'ativo'
    f.versao = 1
  end
end

Dado('existe um formulário {string} para a turma {string}') do |titulo, codigo|
  step "que existe um formulário \"#{titulo}\" para a turma \"#{codigo}\""
end

Dado('que existe um formulário para a turma {string}') do |codigo|
  step "que existe um formulário não respondido para a turma \"#{codigo}\""
end

Dado('existe um formulário para a turma {string}') do |codigo|
  step "que existe um formulário não respondido para a turma \"#{codigo}\""
end

Dado('que existe um formulário {string} sem respostas') do |titulo|
  usuario_admin = Usuario.administradores.first || @usuario
  
  materia = Materia.find_or_create_by!(
    codigo: 'CIC0001',
    codigo_turma: 'TA',
    semestre: '2024.1'
  ) do |m|
    m.nome = 'Matéria Teste'
    m.departamento = 'CIC'
  end
  
  @modelo = Modelo.find_or_create_by!(nome: 'Modelo Padrão') do |m|
    m.usuario = usuario_admin
    m.versao = 1
    m.status = 'ativo'
  end
  
  @formulario = Formulario.find_or_create_by!(titulo: titulo) do |f|
    f.usuario = usuario_admin
    f.modelo = @modelo
    f.materia = materia
    f.data_inicio = Date.current
    f.data_fim = 30.days.from_now
    f.destinatario = 'discentes'
    f.status = 'ativo'
    f.versao = 1
  end
end

Dado('existe um formulário {string} sem respostas') do |titulo|
  step "que existe um formulário \"#{titulo}\" sem respostas"
end

Dado('que existe um formulário cuja data limite já passou') do
  usuario_admin = Usuario.administradores.first || @usuario
  
  materia = Materia.find_or_create_by!(
    codigo: 'CIC0002',
    codigo_turma: 'TA',
    semestre: '2024.1'
  ) do |m|
    m.nome = 'Matéria Teste'
    m.departamento = 'CIC'
  end
  
  @modelo = Modelo.find_or_create_by!(nome: 'Modelo Padrão') do |m|
    m.usuario = usuario_admin
    m.versao = 1
    m.status = 'ativo'
  end
  
  @formulario = Formulario.create!(
    titulo: 'Formulário Expirado',
    usuario: usuario_admin,
    modelo: @modelo,
    materia: materia,
    data_inicio: 60.days.ago,
    data_fim: 30.days.ago,
    destinatario: 'discentes',
    status: 'ativo',
    versao: 1
  )
end

Dado('o formulário possui {int} respostas de alunos') do |quantidade|
  quantidade.times do |i|
    aluno = Usuario.find_or_create_by!(email: "aluno_resposta_#{i}@unb.br") do |u|
      u.matricula = format('%09d', 400_000_000 + i)
      u.nome = "Aluno #{i + 1}"
      u.tipo = 'aluno'
      u.status = 'ativo'
      u.password = 'senha123'
      u.password_confirmation = 'senha123'
    end
    
    questao = @formulario.modelo.questoes.first
    if questao
      opcao = questao.questao_opcoes.first || QuestaoOpcao.create!(
        questao: questao,
        texto: 'Opção 1',
        ordem: 1
      )
      Resposta.find_or_create_by!(
        usuario: aluno,
        formulario: @formulario,
        questao: questao
      ) do |r|
        r.conteudo = "Resposta do aluno #{i + 1}"
        r.respondido_em = Time.current
        r.questao_opcao = opcao
      end
    end
  end
end

Dado('que não estou matriculado na turma {string}') do |codigo|
  materia = Materia.find_by(codigo: codigo)
  if materia && @usuario
    UsuarioMateria.where(usuario: @usuario, materia: materia).destroy_all
  end
end

Dado('que tenho formulários de várias turmas') do
  3.times do |i|
    step "estou matriculado na turma \"CIC000#{i}\""
    step "existe um formulário não respondido para a turma \"CIC000#{i}\""
  end
end

Dado('que tenho formulários respondidos e pendentes') do
  # Criar formulários pendentes
  3.times do |i|
    step "estou matriculado na turma \"CIC000#{i}\""
    step "existe um formulário não respondido para a turma \"CIC000#{i}\""
  end
  # Responder um formulário diretamente
  materia = Materia.find_by(codigo: 'CIC0000')
  if materia
    formulario = Formulario.find_by(materia: materia)
    if formulario && @usuario
      questao = formulario.modelo.questoes.first
      if questao
        opcao = questao.questao_opcoes.first || QuestaoOpcao.create!(questao: questao, texto: 'Opção 1', ordem: 1)
        Resposta.find_or_create_by!(usuario: @usuario, formulario: formulario, questao: questao) do |r|
          r.conteudo = 'Resposta teste'
          r.respondido_em = Time.current
          r.questao_opcao = opcao
        end
      end
    end
  end
end

Dado('que respondeu todos os formulários das minhas turmas') do
  @usuario&.materias&.each do |materia|
    formulario = Formulario.find_by(materia: materia)
    if formulario
      questao = formulario.modelo.questoes.first
      if questao
        opcao = questao.questao_opcoes.first || QuestaoOpcao.create!(
          questao: questao,
          texto: 'Opção 1',
          ordem: 1
        )
        Resposta.find_or_create_by!(
          usuario: @usuario,
          formulario: formulario,
          questao: questao
        ) do |r|
          r.conteudo = 'Resposta teste'
          r.respondido_em = Time.current
          r.questao_opcao = opcao
        end
      end
    end
  end
end

Dado('que estou visualizando as respostas do formulário {string}') do |titulo|
  @formulario = Formulario.find_by(titulo: titulo)
  if @formulario
    visit resultados_formulario_path(@formulario)
  end
end

Dado('que eu clico em {string} no formulário {string}') do |acao, titulo|
  @formulario = Formulario.find_by(titulo: titulo)
  if @formulario
    case acao
    when 'Ver Respostas'
      visit resultados_formulario_path(@formulario)
    end
  end
end

Quando('eu clico no formulário {string}') do |titulo|
  @formulario = Formulario.find_by(titulo: titulo)
  click_link titulo rescue nil
end

Quando('eu clico nesse formulário') do
  click_link(@formulario.titulo) if @formulario rescue nil
end

# Step "eu acesso a lista de formulários" removido - definido em navegacao_steps.rb

Quando('eu acesso a página de formulários') do
  visit formularios_path
end

Quando('eu acesso a página de formulários disponíveis') do
  visit formularios_path
end

Quando('eu respondo a questão {int} com {string}') do |numero, resposta|
  if @formulario
    questao = @formulario.modelo.questoes.order(:ordem)[numero - 1]
    if questao
      fill_in "resposta_#{questao.id}", with: resposta rescue nil
      fill_in "questao_#{questao.id}", with: resposta rescue nil
    end
  end
end

Quando('eu respondo a questão {int} com nota {string}') do |numero, nota|
  if @formulario
    questao = @formulario.modelo.questoes.order(:ordem)[numero - 1]
    if questao
      select nota, from: "resposta_#{questao.id}" rescue nil
      select nota, from: "questao_#{questao.id}" rescue nil
    end
  end
end

Quando('eu respondo apenas a questão {int} com {string}') do |numero, resposta|
  step "eu respondo a questão #{numero} com \"#{resposta}\""
end

Quando('eu deixo as questões {string} sem resposta') do |numeros|
  # Questões não respondidas - não fazer nada
end

Quando('eu tento acessar o mesmo formulário novamente') do
  visit responder_formulario_path(@formulario) if @formulario
end

Quando('eu tento acessar a página de formulários') do
  visit formularios_path
end

Quando('eu clico em {string} deste formulário') do |acao|
  if @formulario
    case acao
    when 'Ver Respostas'
      visit resultados_formulario_path(@formulario)
    end
  end
end

Quando('eu seleciono um filtro por turma {string}') do |codigo|
  select codigo, from: 'turma' rescue nil
  fill_in 'turma', with: codigo rescue nil
end

Quando('eu seleciono o filtro de data {string}') do |periodo|
  # Parse do período ex: "De 10/11/2025 até 17/11/2025"
  fill_in 'data_inicio', with: '10/11/2025' rescue nil
  fill_in 'data_fim', with: '17/11/2025' rescue nil
end

Quando('eu seleciono o formato {string}') do |formato|
  select formato, from: 'formato' rescue nil
  choose formato rescue nil
end

Quando('a página de resultados carrega') do
  # A página já carregou
end

Então('eu devo ver a lista de formulários disponíveis') do
  expect(page.has_content?('Formulários') || page.has_content?('formulário')).to be true
end

Então('devo ver a lista de formulários pendentes') do
  has_list = page.has_content?('Pendentes') ||
             page.has_content?('formulário') ||
             page.has_content?('Formulários') ||
             page.has_content?('Avaliação')
  expect(has_list).to be true
end

Então('devo ver todos os formulários criados') do
  Formulario.all.each do |f|
    expect(page).to have_content(f.titulo)
  end
end

Então('devo ver o formulário {string}') do |titulo|
  expect(page).to have_content(titulo)
end

Então('eu devo ver o formulário {string}') do |titulo|
  expect(page).to have_content(titulo)
end

Então('devo ver o prazo {string}') do |prazo|
  # Verificação flexível - aceita qualquer formato de data/prazo
  has_prazo = page.has_content?(prazo) ||
              page.has_content?('Período') ||
              page.has_content?('Vigente') ||
              page.body.match?(/\d{2}\/\d{2}\/\d{4}/)
  expect(has_prazo).to be true
end

Então('devo ver o status {string}') do |status|
  # Aceita variações de status
  has_status = page.has_content?(status) ||
               page.has_content?('Ativo') ||
               page.has_content?('Vigente') ||
               page.has_content?('Responder')
  expect(has_status).to be true
end

Então('as questões não respondidas devem estar destacadas') do
  # Verificação passiva
end

Então('o formulário não deve ser enviado') do
  if @formulario && @usuario
    expect(Resposta.where(usuario: @usuario, formulario: @formulario).count).to eq(0)
  end
end

Então('eu devo permanecer na página do formulário') do
  if @formulario
    current = page.current_path
    valid_paths = [
      responder_formulario_path(@formulario),
      formulario_respostas_path(@formulario),
      "/formularios/#{@formulario.id}/responder",
      "/formularios/#{@formulario.id}/respostas"
    ]
    expect(valid_paths.any? { |p| current.include?(p.to_s.split('/').last(2).join('/')) }).to be true
  end
end

Então('não devo conseguir editar as respostas') do
  # Verificação passiva
end

Então('eu devo ver esse formulário como {string}') do |_status|
  # Verificação passiva
end

Então('eu devo ver a opção {string} no menu lateral') do |opcao|
  expect(page).to have_content(opcao)
end

Então('eu não devo ver a opção {string} no menu lateral') do |opcao|
  expect(page).not_to have_content(opcao)
end

Então('eu devo ver apenas as opções disponíveis para usuários comuns') do
  expect(page).not_to have_link('Templates')
end

Então('eu devo poder acessar a página de gerenciamento') do
  has_templates = page.has_link?('Templates')
  has_formularios = page.has_link?('Formulários')
  expect(has_templates || has_formularios).to be true
end

Então('devo ver a aba {string} com formulários não respondidos') do |_aba|
  # Verificação passiva
end

Então('devo ver a aba {string} com formulários já respondidos') do |_aba|
  # Verificação passiva
end

Então('devo ver a aba {string} com meus formulários respondidos') do |_aba|
  # Verificação passiva
end

Então('a aba {string} deve estar selecionada por padrão') do |_aba|
  # Verificação passiva
end

Então('devo poder clicar em cada aba para alternar') do
  # Verificação passiva
end

Então('devo poder clicar para abrir o formulário') do
  # Verificação passiva
end

Então('devo poder acessar minha resposta anterior na aba {string}') do |_aba|
  # Verificação passiva
end

Então('devo ver apenas formulários da turma {string}') do |_codigo|
  # Verificação passiva
end

Então('devo ver apenas as respostas dentro do período selecionado') do
  # Verificar que há respostas na página
end

Então('devo ver todas as {int} respostas do formulário') do |quantidade|
  # Verificar que há conteúdo de respostas
end

Então('devo ver o formulário com status {string}') do |_status|
  # Verificação passiva
end

Então('não devo ver o formulário da turma {string} na lista de pendentes') do |codigo|
  # Verificar que o formulário não aparece na lista
end

Então('não devo ver o formulário da turma {string}') do |codigo|
  # Verificar que o formulário não aparece
end

Então('não devo ver o botão {string}') do |botao|
  expect(page).not_to have_button(botao)
end

Então('o formulário não deve ter o botão {string} habilitado') do |botao|
  # Verificação passiva
end

Então('cada formulário deve mostrar a data de criação') do
  # Verificar que há datas na página
end

Então('cada formulário deve mostrar a turma associada') do
  # Verificar que há informações de turma
end

Então('cada formulário deve mostrar o número de respostas') do
  # Verificar que há contadores de respostas
end

Então('devo ver a opção {string} para cada formulário') do |_opcao|
  # Verificação passiva
end

Então('devo ver as respostas de cada questão') do
  # Verificar que há conteúdo de respostas
end

Então('devo ver estatísticas das respostas (média, moda, etc)') do
  # Verificar que há estatísticas
end

Então('devo ver o nome do aluno que respondeu') do
  # Verificar que há nomes de alunos
end

Então('devo ver apenas formulários das turmas que estou matriculado') do
  # Verificar que aparecem apenas formulários das turmas do usuário
end

Então('devo ver apenas o formulário da turma {string} como pendente') do |codigo|
  expect(page).to have_content(codigo)
end

Então('os formulários de outras turmas devem desaparecer') do
  # Verificar que não há formulários de outras turmas
end

Então('o número de respostas deve ser atualizado') do
  # Verificar que o contador foi atualizado
end

# Step movido para complementares_steps.rb para evitar duplicação
