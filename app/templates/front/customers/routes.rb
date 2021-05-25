# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'customers' do
    resources :organizations, only: [] do
      resources :customers, controller: 'main' do
        collection do
          get   'info'
          get   'form_with_first_step'
          get   'search'
        end
        member do
          get   'new_customer_step_two'
          get   'book_type_creator(/:journal_id)', action: 'book_type_creator'
          get   'refresh_book_type'
          get   'edit_ibiza'
          patch 'update_ibiza'
          get   'edit_exact_online'
          patch 'update_exact_online'
          get   'edit_my_unisoft'
          patch 'update_my_unisoft'
          patch 'close_account'
          patch 'reopen_account'
          get   'edit_compta_options'
          get   'edit_period_options'
          patch 'update_compta_options'
          patch 'update_period_options'
          get   'edit_knowings_options'
          get   'account_close_confirm'
          get   'account_reopen_confirm'
          patch 'update_knowings_options'
          get   'edit_mcf'
          get   'show_mcf_errors'
          get   'upload_email_infos'
          post  'retake_mcf_errors'
          patch 'update_mcf'
          get   'edit_software'
          patch 'update_software'
          get   'edit_softwares_selection'
          patch 'update_softwares_selection'
          get 'my_unisoft_societies'
          post 'associate_society'
        end

        resource :setup, only: [],  module: 'setups', controller: 'main' do
          member do
            get 'next'
            get 'resume'
            get 'previous'
            get 'complete_later'
          end
        end

        resources :addresses, controller: 'addresses'

        resource :accounting_plan, except: %w(new create destroy), module: 'accounting_plans', controller: 'main' do
          member do
            patch  :import
            post   :auto_update
            post   :ibiza_synchronize
            patch  :import_fec
            get    :import_model
            get    :import_fec_processing
            delete :destroy_providers
            delete :destroy_customers
          end

          resources :vat_accounts, module: 'vat_accounts', controller: 'main' do
            get   'edit_multiple',   on: :collection
            patch 'update_multiple', on: :collection
          end
        end

        resources :exercises, module: 'exercises', controller: 'main'

        resources :journals, except: %w(index show), module: 'journals', controller: 'main' do
          post    'copy',              on: :collection
          get     'select',            on: :collection
          get     'edit_analytics',    on: :collection
          post    'update_analytics',  on: :collection
          post    'sync_analytics',    on: :collection
        end

        resources :ibizabox_folders, only: %w(update), module: 'ibizabox_folders', controller: 'main' do
          patch 'refresh', on: :collection
        end

        resources :list_journals, only: %w(index), module: 'journals', controller: 'list'

        resource :csv_descriptor, module: 'csv_descriptors', controller: 'main' do
          patch 'activate',   on: :member
          patch 'deactivate', on: :member
        end


        resource :use_csv_descriptor, only: %w(edit update), module: 'csv_descriptors', controller: 'use'
        resource :file_storage_authorizations, only: %w(edit update), module: 'file_storage_authorizations', controller: 'main'
        resource :subscription, module: 'subscriptions', controller: 'main'


        with_options module: 'organizations' do |r|
          r.resources :new_provider_requests, only: %w(index new create edit update), controller: 'new_provider_requests'
          r.resources :bank_accounts, only: %w(index edit update), controller: 'bank_accounts'
          r.resources :retrieved_banking_operations, only: :index, controller: 'retrieved_banking_operations' do
            post 'force_processing', on: :collection
            post 'unlock_operations', on: :collection
          end

          r.resources :retrieved_documents, only: %w(index show), controller: 'retrieved_documents' do
            get   'piece',    on: :member
            get   'select',   on: :collection
            patch 'validate', on: :collection
          end
          r.resource :dematbox, only: %w(create destroy), controller: 'dematbox'

          r.resources :ibizabox_documents, only: %w(index show), controller: 'ibizabox_documents' do
            get   'piece',    on: :member
            get   'select',   on: :collection
            patch 'validate', on: :collection
          end

        end


        resources :orders, except: %w(index show), module: 'orders', controller: 'main'
      end
    end
  end
end
