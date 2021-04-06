# encoding: utf-8
Rails.application.routes.draw do
  namespace :dashboard do
    get '/', to: "main#index", as: "dashboard_main_index"
    get '/test500', to: "main#test500", as: "dashboard_main_500"
  end
end
