# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'ibiza' do
    resources :organizations, only: [] do
      resource :ibiza, controller: 'main', only: %w(create edit update)
      resources :ibiza_users, only: :index, controller: 'users'
    end
  end
end