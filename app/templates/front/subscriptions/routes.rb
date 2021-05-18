Rails.application.routes.draw do
  namespace :subscriptions do
		get '/:id/edit', to: 'main#edit', as: 'edit'
		put '/', to: 'main#update', as: 'update'
  end
end