Whiteboard::Application.routes.draw do
  resources :items, only: :create
  resources :sessions, only: [:create, :destroy]

  resources :standups, shallow: true do
    resources :items, only: :new
    resources :items do
      collection do
        get 'presentation'
      end
    end

    resources :posts do
      member do
        put 'send_email'
        put 'archive'
      end

      collection do
        get 'archived'
      end

    end
  end

  match '/auth/saml/callback', to: 'sessions#create', via: [:get, :post]
  get '/login', to: 'sessions#new'
  get '/logout', to: 'sessions#destroy'

  root to: 'standups#last_or_index'
end
