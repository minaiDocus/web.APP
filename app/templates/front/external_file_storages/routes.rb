Rails.application.routes.draw do
  scope module: 'external_file_storages' do
    post 'dropbox/webhook', to: 'dropbox#webhook', action: 'webhook'
    get  'dropbox/webhook', to: 'dropbox#verify', action: 'verify'

    resource :dropbox, controller: 'dropbox' do
      get 'authorize_url', on: :member
      get 'callback',      on: :member
    end

    resource :google_drive, controller: 'google_drive' do
      post 'authorize_url', on: :member
      get  'callback',      on: :member
    end

    resource :box do
      get 'authorize_url', on: :member
      get 'callback',      on: :member
    end

    resource :external_file_storage, controller: 'main' do
      post :use,                  on: :member
      post :update_path_settings, on: :member
    end
  end
end