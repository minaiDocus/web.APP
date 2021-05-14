Rails.application.routes.draw do
  namespace :account_sharings do
    get 'new', to: 'main#new', as: 'new'
		post '/', to: 'main#create', as: 'create'
		delete '/', to: 'main#destroy/:id', as: 'delete'
		get 'new_request', to: 'main#new_request', as: 'new_request'
	  post 'create_request', to: 'main#create_request', as: 'create_request'
  end
end