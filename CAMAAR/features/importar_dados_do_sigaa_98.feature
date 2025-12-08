# language: pt

Funcionalidade: Importar Dados do SIGAA
  Como Administrador do sistema
  Eu quero importar dados de turmas, matérias e participantes do SIGAA
  Para que eu possa alimentar a base de dados do sistema

  Contexto:
    Dado que estou logado como administrador com email "admin@unb.br"
    E estou na página de gerenciamento

     # CENÁRIOS FELIZES

  Cenário: Importar turmas com sucesso
    Quando eu seleciono clico no botão "Importar dados"
    E eu seleciono o arquivo JSON "turmas.json"
    E o arquivo contém 1 turma válidas
    E nenhuma turma já existe na base de dados
    E eu clico em "Importar"
    Então eu devo ver a mensagem "1 turmas importadas com sucesso"
    E a turma deve estar cadastrada no sistema
    E devo ver o relatório de importação


  Cenário: Importar participantes com sucesso
    Dado que existem turmas cadastradas no sistema
    Quando eu seleciono o arquivo JSON "participantes.json"
    E o arquivo contém 50 participantes válidos
    E nenhum participante já existe na base
    E eu clico em "Importar Participantes"
    Então eu devo ver "50 participantes importados com sucesso"
    E os participantes devem estar vinculados às suas turmas
  
  # CENÁRIOS TRISTES

  Cenário: Tentar importar arquivo JSON inválido
    Quando eu seleciono um arquivo "dados_invalidos.json"
    E o arquivo não possui formato JSON válido
    E eu clico em "Importar"
    Então eu devo ver a mensagem de erro "Arquivo JSON inválido"
    E devo ver "Verifique a sintaxe do arquivo"
    E nenhum dado deve ser importado
  
  Cenário: Tentar importar arquivo com campos obrigatórios faltando
    Quando eu seleciono o arquivo "turmas_incompletas.json"
    E o arquivo contém turmas sem campo "codigo" obrigatório
    E eu clico em "Importar Turmas"
    Então eu devo ver "Erro: campos obrigatórios faltando"
    E devo ver quais turmas estão com problemas
    E nenhuma turma deve ser importada
  
  Cenário: Tentar importar sem selecionar arquivo
    Quando eu não seleciono nenhum arquivo
    E eu clico em "Importar"
    Então eu devo ver a mensagem de erro "Selecione um arquivo para importar"
    E o botão de importação deve estar desabilitado

