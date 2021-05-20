# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'organizations' do
    resources :organizations, except: :destroy, controller: 'main' do
      patch :suspend,               on: :member
      patch :activate,              on: :member
      patch :unsuspend,             on: :member
      patch :deactivate,            on: :member
      get   :edit_options,          on: :collection
      get   :edit_software_users,   on: :member
      get   :close_confirm,         on: :member
      post  :prepare_payment,       on: :member
      post  :confirm_payment,       on: :member
      post  :revoke_payment,        on: :member
      patch :update_options,        on: :collection
      patch :update_software_users, on: :member

      resources :addresses, controller: 'addresses'

      resource :period_options, only: %w(edit update), controller: 'period_options' do
        post :propagate,                  on: :member
        get  :select_propagation_options, on: :member
      end

      resource :csv_descriptor, only: %w(edit update), controller: 'csv_descriptors'

      resource :organization_subscription, only: %w(edit update), controller: 'subscriptions' do
        get   'select_options',    on: :collection
        patch 'propagate_options', on: :collection
      end

      resource :file_naming_policy, only: %w(edit update), controller: 'file_naming_policies' do
        patch 'preview', on: :member
      end

      resources :account_number_rules, controller: 'account_number_rules' do
        patch   'import',                    on: :collection
        get     'import_form',               on: :collection
        get     'import_model',              on: :collection
        post    'export_or_destroy',         on: :collection
        post    'update_skip_accounting_plan_accounts',         on: :collection
      end

      # resources :my_unisoft do 
          
      # end

      resource :knowings, only: %w(new create edit update), controller: 'knowings'

      resource :ftps, only: %w(edit update destroy), module: 'organization', controller: 'ftps' do
        post :fetch_now, on: :collection
      end
      resource :sftps, only: %w(edit update destroy), module: 'organization', controller: 'sftps' do
        post :fetch_now, on: :collection
      end

      resources :reminder_emails, except: :index, controller: 'reminder_emails' do
        post 'deliver', on: :member
      end

      resource :file_sending_kit, only: %w(edit update), controller: 'file_sending_kits' do
        get  'mails',           on: :member
        get  'select',          on: :member
        get  'folders',         on: :member
        post 'generate',        on: :member
        get  'customer_labels', on: :member
        get  'workshop_labels', on: :member
      end

      resources :groups, controller: 'groups'

      resources :collaborators, controller: 'collaborators' do
        member do
          post   :add_to_organization
          delete :remove_from_organization
        end
      end

      resource :rights, path: 'collaborators/rights',  only: %w(edit update) , module: 'rights', controller: 'main'
      resource :file_storage_authorizations, path: 'collaborators/file_storage_authorizations', only: %w(edit update), module: 'file_storage_authorizations', controller: 'main'

      resources :paper_set_orders, controller: 'paper_set_orders' do
        get  'select_for_orders', on: :collection
        post 'order_multiple',   on: :collection
        post 'create_multiple', on: :collection
      end

      resources :journals, except: 'show', module: 'customers', controller: 'journals'
      resource :ibiza, only: %w(create edit update), controller: 'ibiza'

      resources :ibiza_users,  only: :index, controller: 'ibiza_users'
      # resources :exact_online_users,  only: :index
      resources :mcf_users, only: :index, controller: 'mcf_users'

      resources :pack_reports, only: :index, controller: 'pack_reports' do
        post 'deliver',            on: :member
        get  'select_to_download', on: :member
        post 'download',           on: :member
      end

      resources :preseizures, only: %w(index update), controller: 'preseizures' do
        post 'deliver', on: :member
      end

      resources :preseizure_accounts, controller: 'preseizure_accounts'

      resources :account_sharings, only: %w(index new create destroy), module: :organization, controller: 'account_sharings' do
        post :accept, on: :member
      end

      resources :guest_collaborators, controller: 'guest_collaborators' do
        get 'search', on: :collection
      end

      resource :mcf_settings, only: %w(edit update destroy), controller: 'mcf_settings' do
        post :authorize
        get  :callback
      end

      resource :invoices, only: %w(index show), controller: 'invoices' do
        get 'download(/:id)', action: 'download', as: :download
        post 'insert', action: 'insert'
        delete 'remove', action: 'remove'
        get 'synchronize', action: 'synchronize'
      end
		end
  end
end