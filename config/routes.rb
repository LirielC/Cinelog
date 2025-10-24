# require 'sidekiq/web'  # Descomente quando tiver Redis rodando

Rails.application.routes.draw do
  root 'filmes#index'

  # Sidekiq Web UI (apenas para admins) - Descomente quando tiver Redis
  # authenticate :usuario, ->(u) { u.admin? } do
  #   mount Sidekiq::Web => '/sidekiq'
  # end

  devise_for :usuarios, 
    path: '', 
    path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'registrar' },
    controllers: { registrations: 'usuarios/registrations' }

  resources :filmes do
    resources :comentarios, only: [:create, :destroy]
    collection do
      get :buscar
      get :verificar_duplicata
      get :demo_button
    end
  end

  resources :categorias
  resources :importacoes, only: [:new, :create, :show]

  post '/tmdb_lookup', to: 'servicos#tmdb_lookup'
end
