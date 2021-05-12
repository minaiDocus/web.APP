# encoding: utf-8
Rails.application.routes.draw do
  namespace :admin do
    namespace :subscriptions do
      get '/', to: 'main#index', as: 'index'
      post '/accounts/(:type)', to: 'main#accounts', as: 'accounts'
    end
  end
end
