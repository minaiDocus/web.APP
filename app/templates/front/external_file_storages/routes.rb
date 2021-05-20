Rails.application.routes.draw do
  scope module: 'external_file_storages' do
    resource :external_file_storage, controller: 'main' do
      post :use,                  on: :member
      post :update_path_settings, on: :member
    end
  end
end