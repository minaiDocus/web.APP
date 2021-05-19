# encoding: utf-8
Rails.application.routes.draw do
  namespace :reporting do
    resource :reporting, path: '', controller: 'main'
    resources :expenses, path: 'report', controller: 'expenses'
    resources :preseizures, path: 'report', controller: 'preseizures'
  end
end