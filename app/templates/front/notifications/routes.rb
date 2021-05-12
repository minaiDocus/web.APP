# encoding: utf-8
Rails.application.routes.draw do
  namespace :notifications do
    get '/', to: "main#index", as: "main_index"
    get '/latest', to: 'main#latest', as: 'latest'
    get '/link_through', to: 'main#link_through', as: 'link_through'
    post '/unread_all_notifications', to: 'main#unread_all_notifications', as: 'unread_all_notifications'
  end
end