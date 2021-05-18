Rails.application.routes.draw do
  namespace :use_csv_descriptors do
		get '/:id/edit', to: 'main#edit', as: 'edit'
		put '/', to: 'main#update', as: 'update'
  end
end