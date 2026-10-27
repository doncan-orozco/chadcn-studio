Rails.application.routes.draw do
  # Health status for load balancers and uptime monitors: 200 when the app boots with no exceptions.
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  resources :themes do
    resource :publication, only: %i[create destroy], module: :themes
    resources :generations, only: :create, module: :themes
  end

  resources :derivations, only: :create, module: :themes

  # The public URL `chadcn:theme:import` consumes: /t/<slug>.css (shadcn theme.css) and /t/<slug>.json.
  get "t/:slug", to: "themes/exports#show", as: :theme_export, constraints: { format: /css|json/ }

  get "previews/:page", to: "previews#show", as: :preview
  get "gallery", to: "gallery#show"
end
