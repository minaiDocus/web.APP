Rails.application.routes.draw do
  namespace :addresses do
    get '/', to: 'main#index', as: 'index'
		get '/:id', to:'main#show', as: 'show'
		get 'new', to: 'main#new', as: 'new'
		post '/', to: 'main#create', as: 'create'
		get '/:id/edit', to: 'main#edit', as: 'edit'
		put '/', to: 'main#update', as: 'update'
		delete '/', to: 'main#destroy', as: 'delete'
  end
end