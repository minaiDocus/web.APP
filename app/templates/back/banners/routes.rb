# encoding: utf-8
Rails.application.routes.draw do
  namespace :admin do
    resources :banners, module: 'banners', controller: 'main' do
      patch 'upload_file', to: 'main#upload_file', on: :collection
      patch 'configure_image_properties', to: 'main#configure_image_properties', on: :collection
      get 'fetch_banner', to: 'main#fetch_banner', on: :collection
      delete 'destroy', to: 'main#destroy'

    end
  end
end
