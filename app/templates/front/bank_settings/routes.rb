Rails.application.routes.draw do
  namespace :bank_settings do
    get '/', to: 'main#index', as: 'index'
		get 'new', to: 'main#new', as: 'new'
		post '/', to: 'main#create', as: 'create'
		get '/:id/edit', to: 'main#edit', as: 'edit'
		put '/', to: 'main#update', as: 'update'
		post '/should_be_disabled', to:'main#mark_as_to_be_disabled', as: 'mark_as_to_be_disabled'
  end
end