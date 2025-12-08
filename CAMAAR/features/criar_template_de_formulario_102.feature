# language: pt

Funcionalidade: Criar Modelo de Formulário
  Como Administrador do sistema
  Eu quero criar Modelos de formulários com questões personalizadas
  Para que eu possa gerar formulários de avaliação reutilizáveis para avaliar o desempenho das turmas

  Contexto:
    Dado que estou logado como administrador com email "admin@unb.br"
    E estou na página de gerenciamento de Modelos

  # ========================================
  # CENÁRIOS FELIZES
  # ========================================

  Cenário: Criar Modelo com questão dissertativa
    Quando eu clico no botão "Novo Modelo"
    E eu preencho o campo "Nome do Modelo" com "Avaliação de Desempenho Docente"
    E eu preencho o campo "Descrição" com "Modelo para avaliar professores"
    E eu clico em "Adicionar Questão"
    E eu seleciono o tipo de questão "Dissertativa"
    E eu preencho o enunciado com "Como você avalia o método de ensino do professor?"
    E eu clico no botão "Salvar Modelo"
    Então eu devo ver a mensagem "Modelo criado com sucesso"
    E eu devo ver "Avaliação de Desempenho Docente" na lista de Modelos
    E o Modelo deve conter 1 questão

  Cenário: Criar Modelo de formulário com sucesso
    Quando eu clico no botão "Novo Modelo"
    E eu preencho o campo "Nome do Modelo" com "Avaliação de Desempenho Docente 2025"
    E eu clico em "Adicionar Questão"
    E eu seleciono o tipo de questão "Dissertativa"
    E eu preencho o enunciado da questão com "Como você avalia a didática do professor?"
    E eu clico no botão "Criar"
    Então eu devo ver a mensagem "Modelo criado com sucesso"
    E eu devo ver "Avaliação de Desempenho Docente 2025" na lista de Modelos
    E o Modelo deve aparecer como disponível para uso

  Cenário: Criar Modelo e adicionar questão posteriormente
    Dado que existe um Modelo chamado "Modelo Básico" com 1 questão
    Quando eu acesso a página de edição do Modelo "Modelo Básico"
    E eu clico em "Adicionar Questão"
    E eu seleciono o tipo "Múltipla Escolha"
    E eu preencho o enunciado com "O conteúdo foi relevante?"
    E eu adiciono as alternativas "Sim" e "Não"
    E eu clico em "Salvar"
    Então eu devo ver a mensagem "Questão adicionada com sucesso"
    E o Modelo deve conter 2 questões

 # ========================================
  # CENÁRIOS TRISTES
  # ========================================

  Cenário: Tentar criar Modelo sem nome
    Quando eu clico no botão "Novo Modelo"
    E eu deixo o campo "Nome do Modelo" vazio
    E eu preencho o campo "Descrição" com "Modelo sem nome"
    E eu adiciono uma questão dissertativa
    E eu clico no botão "Criar"
    Então eu devo ver a mensagem de erro "Nome do Modelo é obrigatório"
    E nenhum Modelo deve ser criado
  
  Cenário: Tentar criar Modelo sem nenhuma questão
    Quando eu clico no botão "Novo Modelo"
    E eu preencho o campo "Nome do Modelo" com "Modelo Vazio"
    E eu clico no botão "Salvar Modelo"
    Então eu devo ver a mensagem de erro "Modelo deve conter pelo menos 1 questão"
    E nenhum Modelo deve ser criado
    
  Cenário: Tentar adicionar questão de múltipla escolha sem alternativas
    Quando eu clico no botão "Novo Modelo"
    E eu preencho o campo "Nome do Modelo" com "Modelo Teste"
    E eu adiciono uma questão do tipo "Múltipla Escolha"
    E eu preencho o enunciado com "Pergunta sem alternativas?"
    E eu não adiciono nenhuma alternativa
    E eu clico no botão "Salvar Modelo"
    Então eu devo ver a mensagem de erro "Questão de múltipla escolha deve ter pelo menos 2 alternativas"
  
  Cenário: Tentar criar template sem estar autenticado
    Dado que não estou autenticado no sistema
    Quando eu tento acessar a página de criar template
    Então eu devo ser redirecionado para a página de login
    E eu devo ver a mensagem "Você precisa fazer login para continuar"