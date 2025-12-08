Rails.application.routes.draw do
  get "home/index"
  resources :token_senhas
  resources :respostas
  resources :formularios
  resources :questao_opcoes
  resources :questoes
  resources :modelos
  resources :usuario_materias
  resources :materias
  resources :usuarios
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  root 'home#index'
  
  # Autenticação
  get    'login',  to: 'sessions#new'
  post   'login',  to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  get  'definir_senha/:token', to: 'usuarios#definir_senha', as: :definir_senha
  post 'definir_senha/:token', to: 'usuarios#salvar_senha'
  
  get  'redefinir_senha', to: 'usuarios#redefinir_senha'
  post 'redefinir_senha', to: 'usuarios#enviar_redefinicao'
  
  # Resources
  resources :usuarios, only: [:index, :new, :create, :show]
  
  resources :modelos do
    resources :questoes, only: [:new, :create, :edit, :update, :destroy]
  end
  
  resources :formularios do
    get  'responder', to: 'respostas#new'
    post 'responder', to: 'respostas#create'
    get  'resultados', to: 'formularios#resultados'
  end
  
  resources :materias, only: [:index, :show]
  
  # Admin
  namespace :admin do
    post 'importar_sigaa', to: 'importacao#create'
    get  'importar_sigaa', to: 'importacao#new'
  end
  
  # Relatórios
  namespace :relatorios do
    get 'formulario/:id/csv', to: 'csv#show', as: :formulario_csv
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
