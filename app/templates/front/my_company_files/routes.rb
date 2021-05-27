# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'my_company_files' do
  	resources :organizations, only: [] do
		  resources :mcf_users, only: :index, controller: 'users'
		  resource :mcf_settings, only: %w(edit update destroy), controller: 'settings' do
	      post :authorize
	      get  :callback
	    end
	  end
  end
end