Rails.application.routes.draw do
  scope module: 'google_drives' do
    resource :google_drive, controller: 'main' do
      get 'authorize_url', on: :member
      get 'callback',      on: :member
    end
  end
end