Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login",    to: "auth#login"
      get  "auth/me",       to: "auth#me"

      resources :tweets, only: %i[create destroy] do
        collection do
          get :timeline
        end
      end

      resources :users, only: [], controller: "follows" do
        member do
          post   :follow
          delete :unfollow
          get    :followers
          get    :following
        end
      end
    end
  end
end
