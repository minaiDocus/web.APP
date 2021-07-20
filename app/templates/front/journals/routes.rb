# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'journals' do
  	resources :organizations, only: [] do
		  resources :journals, except: 'show', controller: 'main'

		  resources :customers, only: [] do
		  	resources :journals, except: %w(index show), controller: 'main' do
          post    'copy',              on: :collection
          get     'select',            on: :collection
          get     'edit_analytics',    on: :collection
          post    'update_analytics',  on: :collection
          post    'sync_analytics',    on: :collection
        end

			  resources :list_journals, only: %w(index), controller: 'list'
			end
		end
  end
end