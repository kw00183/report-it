Rails.application.routes.draw do
  resources :reports do
    member do
      delete 'delete_image/:image_id', to: 'reports#delete_image', as: 'delete_image'
      put 'follow', as: 'follow'
      put 'confirm', as: 'confirm'
    end
  end

  devise_for :users, :path_prefix => 'account', :controllers => {
    registrations: 'registrations'
  }
  authenticate :user, -> (user) { user.is_admin? } do
    resources :users
    resources :themes, except: [:create, :new, :destroy]
    resources :feedbacks, except: [:destroy]
    resources :settings, except: [:create, :new, :destroy] do
      member do
        delete 'delete_image/:image_id', to: 'settings#delete_image', as: 'delete_image'
      end
    end
    resources :subcategories, except: [:destroy]
    resources :categories, except: [:destroy]
    get 'kpi-dashboard', to: 'kpi_dashboard#index'
    get 'deactivated-reports', to: 'deactivated_reports#index'
    get 'flagged-reports', to: 'flagged_reports#index'
    get 'deactivated-feedbacks', to: 'deactivated_feedbacks#index'
    get 'flagged-feedbacks', to: 'flagged_feedbacks#index'
    get 'reports-by-user', to: 'reports_by_user#index'
    get 'official', to: 'home#index'

    resources :comments, except: [:index]
  end

  authenticate :user, -> (user) { user.is_resident? } do
    resources :feedbacks, except: [:index, :edit, :update, :destroy]
    get 'followed-reports', to: 'followed_reports#index'
    get 'resident', to: 'resident#index'
  end

  authenticate :user, -> (user) { user.is_official? } do
    get 'official', to: 'home#index'
    get 'reports-by-user', to: 'reports_by_user#index'
    get '/users/new', to: redirect('/users')

    resources :feedbacks, except: [:destroy]
    resources :users, only: [:index, :show]
    resources :comments, except: [:index]
  end

  root to: 'home#index'

  get '/submit_comment', to: "comments#submit_comment"

  post '/reports/:id/edit' => 'reports#edit'

  get '/official-search', to: "official#index"

  get '*path', to: redirect('/'), constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
