Rails.application.routes.draw do
  namespace :accounting_plans do
		get 'new', to: 'main#new', as: 'new'
		post '/', to: 'main#create', as: 'create'
		delete '/', to: 'main#destroy', as: 'delete'

		patch '/import', to: 'main#import', as: 'import'
		post '/auto_update', to:'main#auto_update', as: 'auto_update'
		post '/ibiza_synchronize', to:'main#ibiza_synchronize', as: 'ibiza_synchronize'
		patch '/import_fec', to:'main#import_fec', as: 'import_fec'
		get '/import_model', to:'main#import_model', as: 'import_model'
		get '/import_fec_processing', to:'main#import_fec_processing', as: 'import_fec_processing'
		post '/destroy_providers', to:'main#destroy_providers', as: 'destroy_providers'
		post '/destroy_customers', to:'main#destroy_customers', as: 'destroy_customers'
  end
end