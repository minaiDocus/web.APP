Rails.application.routes.draw do
  namespace :organization do
		resource :ftps, only: %w(edit update destroy), controller: 'ftps' do
			post :fetch_now, on: :collection
		end

		resource :sftps, only: %w(edit update destroy), controller: 'sftps' do
			post :fetch_now, on: :collection
		end

		resources :account_sharings, only: %w(index new create destroy), controller: 'account_sharings' do
			post :accept, on: :member
		end

		resources :new_provider_requests, only: %w(index new create edit update), controller: 'new_provider_requests'

		resources :bank_accounts, only: %w(index edit update), controller: 'bank_accounts'

		resources :retrieved_banking_operations, only: :index, controller: 'retrieved_banking_operations' do
	    post 'force_processing', on: :collection
	    post 'unlock_operations', on: :collection
		end

		resources :retrieved_documents, only: %w(index show), controller: 'retrieved_documents' do
			get   'piece',    on: :member
			get   'select',   on: :collection
			patch 'validate', on: :collection
		end

		resource :dematbox, only: %w(create destroy), controller: 'dematbox'

		resources :ibizabox_documents, only: %w(index show), controller: 'ibizabox_documents' do
	    get   'piece',    on: :member
	    get   'select',   on: :collection
	    patch 'validate', on: :collection
		end

		resource :addresses, controller: 'addresses'
		resource :csv_descriptor, only: %w(edit update), controller: 'csv_descriptors'
		resource :period_options, only: %w(edit update), controller: 'period_options' do
      post :propagate,                  on: :member
      get  :select_propagation_options, on: :member
    end

		resource :organization_subscription, only: %w(edit update), controller: 'organization_subscriptions' do
      get   'select_options',    on: :collection
      patch 'propagate_options', on: :collection
    end
  end
end