Rails.application.routes.draw do
  namespace :profiles do
    get '/:id', to:'main#show', as: 'show'
		put '/', to: 'main#update', as: 'update'
  end
end