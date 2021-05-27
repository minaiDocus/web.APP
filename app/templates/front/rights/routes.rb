# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'rights' do
    resources :organizations, only: [] do
      resources :collaborators, only: [] do
      	resource :rights, only: %w(edit update), controller: 'main'
      end
    end
  end
end