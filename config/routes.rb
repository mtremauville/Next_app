Rails.application.routes.draw do
  get "pages/home"
  devise_for :users, controllers: { registrations: "users/registrations" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  post "guest_login", to: "guest_sessions#create", as: :guest_login
  resources :entries, except: :show do
    member { patch :watch }
  end
  resources :entries, except: :show
  resources :playlists
  get "dashboard", to: "dashboard#show"
  get "tmdb/search", to: "tmdb_searches#index", as: :tmdb_search
  get "catalog", to: "catalog#index", as: :catalog
  resources :movies, only: :show, constraints: { id: /\d+/ }
  resources :series, only: :show, constraints: { id: /\d+/ }

  scope "catalog/:media_type/:tmdb_id", constraints: { media_type: /movie|tv/, tmdb_id: /\d+/ } do
    post "playlist", to: "catalog_entries#create", as: :catalog_entry_playlist
    delete "playlist", to: "catalog_entries#destroy", as: :catalog_entry_playlist_removal
  end
  scope "series/:tmdb_id", constraints: { tmdb_id: /\d+/ } do
    patch "seasons/:season/episodes/:episode", to: "series_progresses#episode",
          as: :series_episode_progress, constraints: { season: /\d+/, episode: /\d+/ }
    patch "seasons/:season/episodes/:episode/position", to: "series_progresses#position",
          as: :series_episode_position, constraints: { season: /\d+/, episode: /\d+/ }
    delete "seasons/:season/episodes/:episode/position", to: "series_progresses#clear_position",
          as: :series_episode_position_removal, constraints: { season: /\d+/, episode: /\d+/ }
    patch "seasons/:season", to: "series_progresses#season",
          as: :series_season_progress, constraints: { season: /\d+/ }
  end

  scope "movies/:tmdb_id", constraints: { tmdb_id: /\d+/ } do
    patch "position", to: "movie_positions#update", as: :movie_position
    delete "position", to: "movie_positions#destroy", as: :movie_position_removal
  end
  get "conditions-generales", to: "legal#terms", as: :terms
  get "confidentialite", to: "legal#privacy", as: :privacy
  patch "locale", to: "locales#update", as: :change_locale
  root "pages#home"
end
