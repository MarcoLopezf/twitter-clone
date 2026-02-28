Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login",    to: "auth#login"
      get  "auth/me",       to: "auth#me"

      resources :tweets, only: %i[create destroy], controller: "tweets" do
        collection do
          get :timeline
        end
        member do
          post   :like,   controller: "likes"
          delete :unlike, controller: "likes"
        end
      end

      get   "users/:username/tweets", to: "tweets#user_tweets"
      get   "users/search",          to: "users#search"
      patch "users/me",          to: "users#update"
      get   "users/:username",   to: "users#show", constraints: { username: /[^\/]+/ }, format: false

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
