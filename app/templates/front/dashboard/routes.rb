# encoding: utf-8
Rails.application.routes.draw do
  namespace :dashboard do
    get '/', to: "main#index", as: "dashboard_main_index"
    get '/my_favorite_customers/', to: 'main#my_favorite_customers', as: 'dashboard_my_favorite_customers'
    post '/add_customer_to_favorite/', to: 'main#add_customer_to_favorite', as: 'dashboard_add_customer_to_favorite'
  end
end
