# encoding: utf-8
Rails.application.routes.draw do
  namespace :dashboard do
    get '/', to: "main#index", as: "dashboard_main_index"
  end
end
