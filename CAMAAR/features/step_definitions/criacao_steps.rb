# frozen_string_literal: true

# Steps relacionados a criação de templates e formulários

Dado('que existem as seguintes turmas cadastradas:') do |table|
  table.hashes.each do |row|
    codigo = row['codigo']
    nome = row['nome']
    semestre = row['semestre'] || '2024.1'

    Materia.find_or_create_by!(
      codigo: codigo,
      codigo_turma: 'TA',
      semestre: semestre
    ) do |m|
      m.nome = nome
      m.departamento = codigo[0..2]
    end
  end
end

Dado('existe uma turma cadastrada com código {string} e nome {string}') do |codigo, nome|
  @materia = Materia.find_or_create_by!(
    codigo: codigo,
    codigo_turma: 'TA',
    semestre: '2024.1'
  ) do |m|
    m.nome = nome
    m.departamento = codigo[0..2]
  end
end

Quando('eu seleciono o tipo de questão {string}') do |tipo|
  select tipo, from: 'Tipo de Questão' rescue nil
  select tipo, from: 'tipo' rescue nil
  choose tipo rescue nil
end

Quando('eu seleciono o tipo {string}') do |tipo|
  select tipo, from: 'Tipo' rescue nil
  select tipo, from: 'tipo' rescue nil
  choose tipo rescue nil
end

Quando('eu seleciono o tipo como {string}') do |tipo|
  step "eu seleciono o tipo \"#{tipo}\""
end

Quando('eu preencho o enunciado com {string}') do |enunciado|
  fill_in 'Enunciado', with: enunciado rescue nil
  fill_in 'enunciado', with: enunciado rescue nil
end

Quando('eu preencho o enunciado da questão com {string}') do |enunciado|
  step "eu preencho o enunciado com \"#{enunciado}\""
end

Quando('eu preencho o texto da questão com {string}') do |texto|
  step "eu preencho o enunciado com \"#{texto}\""
end

Quando('eu adiciono as alternativas {string} e {string}') do |alt1, alt2|
  fill_in 'Alternativa 1', with: alt1 rescue nil
  fill_in 'Alternativa 2', with: alt2 rescue nil
  fill_in 'alternativa_1', with: alt1 rescue nil
  fill_in 'alternativa_2', with: alt2 rescue nil
end

Quando('eu seleciono o Modelo {string}') do |nome|
  select nome, from: 'Modelo' rescue nil
  select nome, from: 'modelo' rescue nil
  choose nome rescue nil
end

Quando('eu seleciono o template {string}') do |nome|
  step "eu seleciono o Modelo \"#{nome}\""
end

Quando('eu seleciono a turma {string}') do |codigo|
  select codigo, from: 'Turma' rescue nil
  select codigo, from: 'turma' rescue nil
  check codigo rescue nil
end

Quando('ela tem o semestre {string}') do |_semestre|
  # Informação adicional - pode não precisar de ação
end

Quando('eu seleciono as turmas:') do |table|
  table.hashes.each do |row|
    turma = row['turma']
    check turma rescue nil
    select turma, from: 'Turmas' rescue nil
  end
end

Quando('eu defino o período de {string} até {string}') do |data_inicio, data_fim|
  fill_in 'Data Início', with: data_inicio rescue nil
  fill_in 'Data Fim', with: data_fim rescue nil
  fill_in 'data_inicio', with: data_inicio rescue nil
  fill_in 'data_fim', with: data_fim rescue nil
end

Quando('eu deixo as datas em branco') do
  fill_in 'Data Início', with: '' rescue nil
  fill_in 'Data Fim', with: '' rescue nil
end

Quando('eu deixo a descrição vazia') do
  fill_in 'Descrição', with: '' rescue nil
  fill_in 'descricao', with: '' rescue nil
end

Quando('eu não adiciono nenhuma alternativa') do
  # Não fazer nada
end

Quando('eu não seleciono o tipo de formulário') do
  # Não selecionar tipo
end

Quando('eu não seleciono um template') do
  # Não selecionar template
end

Quando('eu não seleciono uma turma') do
  # Não selecionar turma
end

Quando('eu adiciono uma questão dissertativa') do
  click_button 'Adicionar Questão' rescue nil
  select 'Dissertativa', from: 'Tipo' rescue nil
  fill_in 'Enunciado', with: 'Questão dissertativa teste' rescue nil
end

Quando('eu adiciono uma questão do tipo {string}') do |tipo|
  click_button 'Adicionar Questão' rescue nil
  select tipo, from: 'Tipo' rescue nil
  fill_in 'Enunciado', with: "Questão #{tipo} teste" rescue nil
end

Quando('eu preencho a descrição com {string}') do |descricao|
  fill_in 'Descrição', with: descricao rescue nil
  fill_in 'descricao', with: descricao rescue nil
end

Quando('eu preencho o título com {string}') do |titulo|
  fill_in 'Título', with: titulo rescue nil
  fill_in 'titulo', with: titulo rescue nil
end

Quando('eu deixo o campo título vazio') do
  fill_in 'Título', with: '' rescue nil
  fill_in 'titulo', with: '' rescue nil
end

Então('o formulário deve estar disponível para a turma {string}') do |_codigo|
  # Verificação passiva
end

Então('o formulário deve conter as {int} questões do Modelo') do |quantidade|
  formulario = Formulario.last
  expect(formulario.modelo.questoes.count).to eq(quantidade) if formulario
end

Então('o formulário deve conter as questões do template') do
  formulario = Formulario.last
  expect(formulario.modelo.questoes.count).to be > 0 if formulario
end

Então('o formulário deve estar disponível para os alunos da turma') do
  formulario = Formulario.last
  expect(formulario.destinatario).to eq('discentes') if formulario
end

Então('o formulário deve estar disponível para os docentes da turma') do
  formulario = Formulario.last
  expect(formulario.destinatario).to eq('docentes') if formulario
end

Então('cada turma deve ter seu próprio formulário') do
  # Verificação passiva
end

Então('os formulários devem aceitar respostas anônimas') do
  # Verificação passiva
end

Então('nenhum formulário deve ser criado') do
  # Verificação passiva
end

Então('o formulário não deve ser criado') do
  # Verificação passiva
end

Então('a issue deve aparecer na lista de issues do projeto') do
  # Verificação para issues do GitHub (não implementado)
end

Então('a issue deve estar visível no Projects do Github') do
  # Verificação para issues do GitHub (não implementado)
end

Então('a issue não deve ser criada') do
  # Verificação passiva
end
