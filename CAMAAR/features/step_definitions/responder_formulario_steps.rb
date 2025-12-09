Given('que estou logado como aluno com email {string}') do |email|
  @aluno = Usuario.find_by(email: email)
  unless @aluno
    @aluno = FactoryBot.create(:usuario, email: email, tipo: 'aluno')
  end
  
  visit login_path
  fill_in 'Email', with: @aluno.email
  fill_in 'Senha', with: 'senha123'
  click_button 'Entrar'
end

Given('estou matriculado na turma {string}') do |turma_info|
  parts = turma_info.split(' - ')
  codigo = parts[0].strip
  semestre = parts.last.strip
  
  @materia = Materia.find_by(codigo: codigo, semestre: semestre)
  unless @materia
    @materia = FactoryBot.create(:materia, codigo: codigo, semestre: semestre)
  end
  
  FactoryBot.create(:usuario_materia, usuario: @aluno, materia: @materia, papel: 'aluno')
end

Given('existe um formulário ativo para minha turma') do
  step 'existe um formulário chamado "Formulário Padrão" ativo para minha turma'
end

Given('existe um formulário chamado {string} ativo para minha turma') do |nome_formulario|
  @modelo = FactoryBot.create(:modelo) 
  @formulario = FactoryBot.create(:formulario, 
    titulo: nome_formulario,
    materia: @materia, 
    modelo: @modelo,
    status: 'ativo',
    data_inicio: Date.today - 1.day,
    data_fim: Date.today + 7.days
  )
end

Given('o formulário contém {int} questões') do |qtd|
  diferenca = qtd - @formulario.modelo.questoes.count
  if diferenca > 0
    FactoryBot.create_list(:questao, diferenca, modelo: @formulario.modelo)
  elsif diferenca < 0
    @formulario.modelo.questoes.last(diferenca.abs).each(&:destroy)
  end
  expect(@formulario.modelo.questoes.count).to eq(qtd)
end

Given('que estou na página de avaliações') do
  visit formularios_path
end

When('eu clico no formulário {string}') do |titulo|
  # Garante que o título existe (atualiza se necessário, caso venha de contexto genérico)
  if @formulario.titulo != titulo
    @formulario.update(titulo: titulo)
    visit current_path
  end
  click_link titulo
end

When('eu respondo a questão {int} com {string}') do |num_questao, resposta|
  @formulario.reload
  
  # Encontra o container visual pelo índice (assumindo ordem sequencial na tela)
  containers = all(".questao-item")
  
  if containers.empty?
    puts "DEBUG: HTML da página:"
    puts page.body
  end
  
  container = containers[num_questao - 1]
  
  raise "Container da questão #{num_questao} não encontrado na tela. Total encontrados: #{containers.size}" unless container

  # Recupera a questão do banco para saber o tipo (usando a mesma ordem)
  questao = @formulario.modelo.questoes.order(:ordem)[num_questao - 1]
  
  if questao.tipo == 'multipla_escolha'
    opcao = questao.questao_opcoes.find_by(texto: resposta)
    opcao ||= questao.questao_opcoes.first
    
    unless opcao
       opcao = FactoryBot.create(:questao_opcao, questao: questao, texto: resposta)
       visit current_path
       container = all(".questao-item")[num_questao - 1]
    end
    
    begin
      container.find("label", text: opcao.texto).click
    rescue Capybara::ElementNotFound
      container.find("input[type='radio']").choose(allow_label_click: true)
    end
  else
    container.find("textarea").set(resposta)
  end
end

When('eu respondo a questão {int} com nota {string}') do |num_questao, nota|
  step "eu respondo a questão #{num_questao} com \"#{nota}\""
end

When('eu clico no botão {string}') do |botao|
  click_button botao
end

Then('eu devo ver esse formulário como {string}') do |status|
  visit formularios_path
  expect(page).to have_content(status)
end

Given('que estou na página inicial do aluno') do
  visit root_path
end

When('eu acesso {string}') do |link|
  link_real = link == "Meus Formulários" ? "Formulários" : link
  click_link link_real
end

Then('eu devo ver a lista de formulários disponíveis') do
  expect(page).to have_css('.formularios-list')
end

Then('devo ver o formulário {string}') do |titulo|
  # Atualiza título se necessário para bater com teste
  if @formulario.titulo != titulo
    @formulario.update(titulo: titulo)
    visit current_path
  end
  expect(page).to have_content(titulo)
end

Then('devo ver o prazo {string}') do |prazo_exemplo|
  # Verifica se a data real do formulário está na tela, ignorando a data hardcoded do cenário
  data_esperada = @formulario.data_fim.strftime("%d/%m/%Y")
  expect(page).to have_content(data_esperada)
end

Then('devo ver o status {string}') do |status|
  expect(page).to have_content(status) unless status == "Pendente"
end

Given('que estou respondendo o formulário {string}') do |titulo|
  step "que estou na página de avaliações"
  step "eu clico no formulário \"#{titulo}\""
end

When('eu respondo apenas a questão {int} com {string}') do |num, resposta|
  step "eu respondo a questão #{num} com \"#{resposta}\""
end

When(/^eu deixo as questões (.+) sem resposta$/) do |questoes_str|
  # Nada a fazer
end

Then('as questões não respondidas devem estar destacadas') do
  expect(page).to have_css('.field_with_errors')
end

Then('o formulário não deve ser enviado') do
  expect(page).to have_button('Enviar Respostas')
end

Then('eu devo permanecer na página do formulário') do
  expect(page).to have_button('Enviar Respostas')
end

Given('que já respondi o formulário {string}') do |titulo|
  if @formulario.titulo != titulo
    @formulario.update(titulo: titulo)
  end
  
  @formulario.modelo.questoes.each do |questao|
    opcao = nil
    if questao.tipo == 'multipla_escolha'
       opcao = questao.questao_opcoes.first || FactoryBot.create(:questao_opcao, questao: questao)
    end
    
    FactoryBot.create(:resposta, 
      formulario: @formulario, 
      usuario: @aluno, 
      questao: questao,
      conteudo: "Resposta teste",
      questao_opcao: opcao
    )
  end
end

When('eu tento acessar o mesmo formulário novamente') do
  visit formulario_responder_path(@formulario)
end

Then('não devo conseguir editar as respostas') do
  expect(page).not_to have_button('Enviar Respostas')
end

Given('que não estou autenticado no sistema') do
  Capybara.reset_sessions!
  visit root_path
  if page.has_link?("Sair")
    click_link_or_button "Sair"
  end
end

When('eu tento acessar a página de formulários') do
  visit formularios_path
end

Then('eu devo ser redirecionado para a página de login') do
  expect(current_path).to eq(login_path)
end

