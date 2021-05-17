Rails.application.routes.draw do
  namespace :collaborators do
    get '/', to: 'main#index', as: 'index'
		get 'new', to: 'main#new', as: 'new'
		post '/', to: 'main#create', as: 'create'
		get '/:id/edit', to: 'main#edit', as: 'edit'
		put '/', to: 'main#update', as: 'update'
		delete '/', to: 'main#destroy', as: 'delete'
		post "/:id/add_to_organization" => "main#add_to_organization", :as => "add_to_organization"
		delete "/:id/remove_from_organization" => "main#remove_from_organization", :as => "remove_from_organization"
  end
end