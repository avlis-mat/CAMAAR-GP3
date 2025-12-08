# language: pt

Funcionalidade: Cadastrar Usuários do Sistema
  Como Administrador do sistema
  Eu quero solicitar definição de senha para participantes importados do SIGAA
  Para que eles possam acessar o sistema CAMAAR

  Contexto:
    Dado que estou logado como administrador com email "admin@unb.br"
    E foram importados os seguintes usuários do SIGAA:
      | matricula | nome          | email               | tipo      |
      | 123456    | João Silva    | joao@aluno.unb.br   | aluno     |
      | 789012    | Maria Santos  | maria@aluno.unb.br  | aluno     |
      | 456789    | Prof. Carlos  | carlos@unb.br       | professor |

  # CENÁRIOS FELIZES

  Cenário: Enviar convite de cadastro para usuário importado
    Dado que o usuário "João Silva" foi importado mas não definiu senha
    Quando eu acesso a página de gerenciamento de usuários
    E eu seleciono o usuário "João Silva"
    E eu clico em "Enviar Convite de Cadastro"
    Então eu devo ver "Convite enviado com sucesso para joao@aluno.unb.br"
    E o usuário deve receber um email com link de definição de senha
    E o link deve expirar em 48 horas
     E o status do usuário deve mudar para "Convite Enviado"
    
   
  Cenário: Enviar convites em lote para múltiplos usuários
    Dado que existem 10 usuários importados sem senha definida
    Quando eu acesso "Gerenciar Usuários"
    E eu seleciono todos os 10 usuários pendentes
    E eu clico em "Enviar Convites em Lote"
    Então eu devo ver "10 convites enviados com sucesso"
    E cada usuário deve receber seu email individual
  
  Cenário: Reenviar convite para usuário que não ativou
    Dado que o usuário "Maria Santos" recebeu convite há 2 dias
    E ainda não definiu sua senha
    Quando eu acesso a lista de usuários pendentes
    E eu clico em "Reenviar Convite" para "Maria Santos"
    Então eu devo ver "Novo convite enviado"
    E o link anterior deve ser invalidado
    E um novo link deve ser enviado por email

  # CENÁRIOS TRISTES

  Cenário: Tentar enviar convite para usuário já ativo
    Dado que o usuário "Prof. Carlos" tem status "Ativo"
    Quando eu tento enviar convite para este usuário
    Então eu devo ver "Este usuário já possui cadastro ativo"
  
  Cenário: Tentar enviar convite para usuário já cadastrado
    Dado que o usuário "Prof. Carlos" já definiu sua senha
    E já está com conta ativa
    Quando eu tento enviar convite para este usuário
    Então eu devo ver "Este usuário já possui cadastro ativo"
    E nenhum email deve ser enviado
  
  Cenário: Erro ao enviar email de convite
    Dado que estou tentando enviar convite para "João Silva"
    E o servidor de email está indisponível
    Quando eu clico em "Enviar Convite"
    Então eu devo ver "Erro ao enviar convite"
    E devo ver "Tente novamente mais tarde"
    E o status do usuário deve permanecer como pendente