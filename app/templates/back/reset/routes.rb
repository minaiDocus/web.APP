# encoding: utf-8
Rails.application.routes.draw do
  namespace :admin do
    resources :reset, only: %w(index), module: 'reset', controller: 'main' do
      get  'grouping', on: :collection
      get  'lad', on: :collection
    end
  end
end
