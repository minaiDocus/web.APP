# encoding: utf-8
Rails.application.routes.draw do
  namespace :admin do
    resources :tickets, module: 'tickets', controller: 'main'
  end
end
