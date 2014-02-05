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

    [:events, :helps, :interestings, :new_faces].each do |item|
      resources item, controller: :items do
        collection do
          get 'presentation'
        end
      end
    end

    resources :posts do
      member do
        put 'send_email'
        put 'post_to_blog'
        put 'archive'
      end

      collection do
        get 'archived'
      end

    end
  end

  post '/auth/:provider/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

  root to: 'standups#index'
end
