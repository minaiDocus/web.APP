# encoding: utf-8
Rails.application.routes.draw do
  namespace :dashboard do
    get '/', to: "main#index", as: "main_index"
    get '/my_favorite_customers/', to: 'main#my_favorite_customers', as: 'my_favorite_customers'
    post '/add_customer_to_favorite/', to: 'main#add_customer_to_favorite', as: 'add_customer_to_favorite'
    post '/choose_default_summary/', to: 'main#choose_default_summary', as: 'choose_default_summary'
    get '/last_scans', to: 'main#last_scans', as: 'last_scans'
    get '/last_uploads', to: 'main#last_uploads', as: 'last_uploads'
    get '/last_dematbox_scans', to: 'main#last_dematbox_scans', as: 'ast_dematbox_scans'
    get '/last_retrieved', to: 'main#last_retrieved', as: 'last_retrieved'
  end
end
