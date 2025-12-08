# language: pt

Funcionalidade: Criar Formulário de Avaliação
  Como Administrador do sistema
  Eu quero criar formulários de avaliação baseados em Modelos existentes
  Para que eu possa avaliar o desempenho das turmas no semestre atual

  Contexto:
    Dado que estou logado como administrador com email "admin@unb.br"
    E existe um Modelo chamado "Avaliação Semestral" com 5 questões
    E existem as seguintes turmas cadastradas:
      | codigo      | nome                    | semestre |
      | CIC0097 | BANCOS DE DADOS    | 2021.2   |
      | CIC0105 | ENGENHARIA DE SOFTWARE     | 2021.2   |
      | CIC0202 | PROGRAMAÇÃO CONCORRENTE | 2021.2   |

  # ========================================
  # CENÁRIOS FELIZES
  # ========================================

  Cenário: Criar formulário para uma turma com sucesso
    Dado que estou na página de gerenciamento
    Quando eu clico no botão "Enviar Formulários"
    E eu seleciono o Modelo "Avaliação Semestral"
    E eu seleciono a turma "CIC0097"
    E ela tem o semestre "2021.2"
    E eu clico no botão "Enviar"
    Então eu devo ver a mensagem "Formulário de avaliação enviado com sucesso"
    E o formulário deve estar disponível para a turma "CIC0097"
    E o formulário deve conter as 5 questões do Modelo

  Cenário: Criar formulário para múltiplas turmas
    Dado que estou na página de criar formulário
    Quando eu seleciono o Modelo "Avaliação Semestral"
    E eu seleciono as turmas:
      | turma                      |
      | CIC0097 - TA - 2021.2       |
      | CIC0105 - TA - 2021.2        |
      | CIC0202 - TA - 2021.2     |
    E eu defino o período de "07/12/2025" até "31/07/2026"
    E eu clico em "Enviar Formulário"
    Então eu devo ver "3 formulários enviados com sucesso"
    E cada turma deve ter seu próprio formulário
    E os formulários devem aceitar respostas anônimas


  # ========================================
  # CENÁRIOS TRISTES
  # ========================================

  Cenário: Tentar criar formulário sem selecionar Modelo
    Dado que estou na página de gerenciamento
    Quando clico no botão "Enviar Formulários"
    E eu seleciono a turma "CIC0105"
    E ela tem o semestre "2021.2"
    E eu clico em "Enviar"
    Então eu devo ver a mensagem de erro "Modelo é obrigatório"
    E nenhum formulário deve ser criado
    E eu devo permanecer na página de gerenciamento

    Cenário: Tentar criar formulário sem selecionar turmas
    Dado que estou na página de criar formulário
    Quando eu seleciono o Modelo "Avaliação Semestral"
    E eu defino o período de "01/03/2025" até "15/03/2025"
    E eu clico em "Criar Formulário"
    Então eu devo ver a mensagem de erro "Selecione pelo menos uma turma"
    E nenhum formulário deve ser criado

    Cenário: Tentar criar formulário sem definir período
    Dado que estou criando um novo formulário
    Quando eu seleciono o Modelo "Avaliação Semestral"
    E eu seleciono a turma "Física 1 - Turma B"
    E eu deixo as datas em branco
    E eu clico em "Criar Formulário"
    Então eu devo ver a mensagem de erro "Período de disponibilidade é obrigatório"
    E nenhum formulário deve ser criado