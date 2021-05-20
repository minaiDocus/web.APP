# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'reporting' do
    resource :reporting, controller: 'main'

    namespace :report do
      resources :expenses, module: 'reporting', controller: 'expenses'
      resources :preseizures, module: 'reporting', controller: 'preseizures'
    end
  end
end