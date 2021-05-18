Rails.application.routes.draw do
  namespace :csv_descriptors do
		get '/:id/edit', to: 'main#edit', as: 'edit'
		put '/', to: 'main#update', as: 'update'
		patch '/activate', to: 'main#activate', as: 'activate'
		patch '/deactivate', to: 'main#deactivate', as: 'deactivate'
  end
end