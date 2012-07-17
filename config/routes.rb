Whiteboard::Application.routes.draw do

  resources :standups, shallow: true do
    resources :items, only: [ :new, :create ]
    resources :items do
      collection do
        get 'presentation'
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

  match '/auth/:provider/callback', to: 'sessions#create'
  match '/logout', to: 'sessions#destroy'

  root :to => 'standups#index'
end
