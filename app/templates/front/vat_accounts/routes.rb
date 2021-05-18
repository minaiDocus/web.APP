Rails.application.routes.draw do
  namespace :vat_accounts do
		get '/', to: 'main#index', as: 'index'
		get '/edit_multiple', to: 'main#edit_multiple', as: 'edit_multiple'
		patch '/update_multiple', to: 'main#update_multiple', as: 'update_multiple'
  end
end