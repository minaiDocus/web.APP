Rails.application.routes.draw do
  scope module: 'dropboxes' do
    resource :dropbox, controller: 'main' do
      get 'authorize_url', on: :member
      get 'callback',      on: :member
    end
  end
end