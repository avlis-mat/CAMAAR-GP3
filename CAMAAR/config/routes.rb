Rails.application.routes.draw do
  # ==========================================
  # HEALTH CHECK
  # ==========================================
  get "up" => "rails/health#show", as: :rails_health_check

  # ==========================================
  # ROOT
  # ==========================================
  root 'home#index'
  
  # ==========================================
  # AUTENTICAÇÃO
  # ==========================================
  get    'login',  to: 'sessions#new',     as: :login
  post   'login',  to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy', as: :logout
  
  # ==========================================
  # DEFINIÇÃO E REDEFINIÇÃO DE SENHA
  # ==========================================
  
  # Definir senha pela primeira vez (convite de ativação)
  get  'definir_senha/:token', to: 'usuarios#definir_senha',  as: :definir_senha
  post 'definir_senha/:token', to: 'usuarios#salvar_senha'
  
  # Redefinir senha (esqueci minha senha)
  get  'redefinir_senha',      to: 'usuarios#redefinir_senha', as: :redefinir_senha
  post 'redefinir_senha',      to: 'usuarios#enviar_redefinicao'
  
  # Resetar senha via token
  get  'resetar_senha/:token', to: 'usuarios#resetar_senha',   as: :resetar_senha
  post 'resetar_senha/:token', to: 'usuarios#salvar_nova_senha'
  
  # ==========================================
  # IMPORTAÇÃO DE DADOS DO SIGAA
  # ==========================================
  
  scope :importacao, as: :importacao do
    get  '/',                to: 'importacao#new',            as: :root
    post '/',                to: 'importacao#create',         as: :create
    get  '/relatorio/:id',   to: 'importacao#relatorio',      as: :relatorio
    get  '/atualizar',       to: 'importacao#atualizar',      as: :atualizar
    post '/atualizar_sigaa', to: 'importacao#atualizar_sigaa', as: :atualizar_sigaa
  end
  
  # ==========================================
  # USUÁRIOS
  # ==========================================
  
  resources :usuarios, only: [:index, :new, :create, :show, :edit, :update] do
    member do
      post :enviar_convite  # Enviar convite individual
    end
    
    collection do
      post :enviar_convites_lote  # Enviar convites em lote
    end
  end
  
  # ==========================================
  # MODELOS (TEMPLATES)
  # ==========================================
  
  resources :modelos do
    resources :questoes, only: [:new, :create, :edit, :update, :destroy]
  end
  
  # ==========================================
  # FORMULÁRIOS
  # ==========================================
  
  resources :formularios do
    member do
      patch :ativar       # Ativar formulário
      patch :desativar    # Desativar formulário
      patch :encerrar     # Encerrar formulário
      post  :duplicar     # Duplicar formulário
      get   :responder,   to: 'respostas#new'    # Página para responder (aluno)
      get   :resultados,  to: 'respostas#index'  # Ver respostas (admin)
    end
    
    resources :respostas, only: [:create]
  end
  
  # ==========================================
  # MATÉRIAS (TURMAS)
  # ==========================================
  
  resources :materias, only: [:index, :show]
  
  # ==========================================
  # RELATÓRIOS
  # ==========================================
  
  namespace :relatorios do
    get 'formulario/:id/csv', to: 'csv#show', as: :formulario_csv
  end
  
  # ==========================================
  # ADMINISTRAÇÃO
  # ==========================================
  
  namespace :admin do
    get '/', to: 'admin#index', as: :root
    
    resources :usuarios, only: [:index]
    
    # Redirecionar rotas antigas de importação para o novo local
    get  'importar_sigaa', to: redirect('/importacao')
    post 'importar_sigaa', to: redirect('/importacao', status: 307)
    
    # Relatórios
    get 'relatorios', to: 'relatorios#index'
  end
  
  # ==========================================
  # RECURSOS AUXILIARES (sem rotas públicas)
  # ==========================================
  
  # Esses resources não têm rotas próprias, são acessados via nested routes
  resources :token_senhas,     only: []
  resources :usuario_materias, only: []
  resources :questao_opcoes,   only: []
  resources :questoes,         only: []  # Acessado via /modelos/:id/questoes
  resources :respostas,        only: []  # Acessado via /formularios/:id/respostas
  
  # ==========================================
  # PWA (opcional - comentado)
  # ==========================================
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
