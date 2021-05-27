# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'file_storage_authorizations' do
    resources :organizations, only: [] do
    	resources :collaborators, only: [] do
    		resource :file_storage_authorizations, only: %w(edit update), controller: 'main'
    	end

      resources :customers, only: [] do
		    resource :file_storage_authorizations, only: %w(edit update), controller: 'main'
      end
    end
  end
end