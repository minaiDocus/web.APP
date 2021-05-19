# encoding: utf-8
Rails.application.routes.draw do
  namespace :customers do
    resources :customers, path: '', controller: 'main' do
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
      end

    resource :setup, only: [], controller: 'setups' do
      member do
        get 'next'
        get 'resume'
        get 'previous'
        get 'complete_later'
      end
    end

    resources :addresses, controller: 'addresses'

    resource :accounting_plan, except: %w(new create destroy), controller: 'accounting_plans' do
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

      resources :vat_accounts, controller: 'vat_accounts' do
        get   'edit_multiple',   on: :collection
        patch 'update_multiple', on: :collection
      end
    end

    resources :exercises, controller: 'exercises'

    resources :journals, except: %w(index show), controller: 'journals' do
      post    'copy',              on: :collection
      get     'select',            on: :collection
      get     'edit_analytics',    on: :collection
      post    'update_analytics',  on: :collection
      post    'sync_analytics',    on: :collection
    end

    resources :ibizabox_folders, only: %w(update), controller: 'ibizabox_folders' do
      patch 'refresh', on: :collection
    end

    resources :list_journals, only: %w(index), controller: 'list_journals'


    resources :orders, except: %w(index show), controller: 'orders'

    resource :csv_descriptor, controller: 'csv_descriptors' do
      patch 'activate',   on: :member
      patch 'deactivate', on: :member
    end

    resource :use_csv_descriptor, only: %w(edit update), controller: 'use_csv_descriptors'
    resource :file_storage_authorizations, only: %w(edit update), controller: 'file_storage_authorizations'
    resource :subscription, controller: 'subscriptions'
  end
end
