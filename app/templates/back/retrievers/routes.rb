# encoding: utf-8
Rails.application.routes.draw do
  namespace :admin do
    resources :retrievers, only: %w(index edit), module: 'retrievers', controller: 'main' do
      post 'fetcher', on: :collection
      get 'fetcher',  on: :collection
    end

    namespace :retrievers do
      get  '/services', to: 'services#index', as: 'services'
    end
  end
end
