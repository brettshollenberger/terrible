TerribleTracker::Application.routes.draw do
  devise_for :users

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resources :workspaces do
        resources :projects
      end

      resources :projects, only: [:index, :show]
    end
  end
end
