# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'ibizabox_folders' do
  	resources :organizations, only: [] do
      resources :customers, only: [] do
      	resources :ibizabox_folders, only: %w(update), controller: 'main' do
			    patch 'refresh', on: :collection
			  end
      end
    end
  end
end