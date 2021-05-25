# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'journals' do
	  resources :journals, except: 'show', controller: 'main'
	  resources :list_journals, only: %w(index), controller: 'list'
  end
end