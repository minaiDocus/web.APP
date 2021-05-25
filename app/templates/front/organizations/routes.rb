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

      resource :file_naming_policy, only: %w(edit update), module: 'file_naming_policies', controller: 'main' do
        patch 'preview', on: :member
      end

      resources :account_number_rules, module: 'account_number_rules', controller: 'main' do
        patch   'import',                    on: :collection
        get     'import_form',               on: :collection
        get     'import_model',              on: :collection
        post    'export_or_destroy',         on: :collection
        post    'update_skip_accounting_plan_accounts',         on: :collection
      end

      resources :my_unisoft do 
        
      end

      resource :knowings, only: %w(new create edit update), module: 'knowings', controller: 'main'

      resource :ftps, only: %w(edit update destroy), controller: 'ftps' do
        post :fetch_now, on: :collection
      end

      resource :sftps, only: %w(edit update destroy), controller: 'sftps' do
        post :fetch_now, on: :collection
      end

      resources :reminder_emails, except: :index, module: 'reminder_emails', controller: 'main' do
        post 'deliver', on: :member
      end

      resource :file_sending_kit, only: %w(edit update), module: 'file_sending_kits', controller: 'main' do
        get  'mails',           on: :member
        get  'select',          on: :member
        get  'folders',         on: :member
        post 'generate',        on: :member
        get  'customer_labels', on: :member
        get  'workshop_labels', on: :member
      end

      resource :csv_descriptor, only: %w(edit update), controller: 'csv_descriptors'

      resources :collaborators, module: 'collaborators', controller: 'main' do
        member do
          post   :add_to_organization
          delete :remove_from_organization
        end

        resource :rights, only: %w(edit update), module: 'rights', controller: 'main'
        resource :file_storage_authorizations, only: %w(edit update), module: 'file_storage_authorizations', controller: 'main'
      end

      resources :paper_set_orders, module: 'paper_set_orders', controller: 'main' do
        get  'select_for_orders', on: :collection
        post 'order_multiple',   on: :collection
        post 'create_multiple', on: :collection
      end

      resources :journals, except: 'show', module: 'journals', controller: 'main'

      resource :organization_subscription, only: %w(edit update), controller: 'subscriptions' do
        get   'select_options',    on: :collection
        patch 'propagate_options', on: :collection
      end

      resource :ibiza, module: 'ibiza', controller: 'main', only: %w(create edit update)

      resources :ibiza_users, only: :index, module: 'ibiza', controller: 'users'
      resources :exact_online_users, only: :index, module: 'exact_online',controller: 'main'
      resources :mcf_users, only: :index, module: 'my_company_files', controller: 'users'
      #resources :pre_assignments,                   only: :index
      # resources :pre_assignment_delivery_errors,    only: :index

      # resources :pre_assignment_ignored,            only: :index do
      #   post :update_ignored_pieces, on: :collection
      # end
      # resources :pre_assignment_blocked_duplicates, only: :index do
      #   post :update_multiple, on: :collection
      # end

      resources :pack_reports, only: :index, module: 'pack_reports', controller: 'main' do
        post 'deliver',            on: :member
        get  'select_to_download', on: :member
        post 'download',           on: :member
      end

      resources :preseizures, only: %w(index update), module: 'preseizures', controller: 'main' do
        post 'deliver', on: :member
      end

      resources :preseizure_accounts, module: 'preseizures', controller: 'accounts'

      resources :account_sharings, only: %w(index new create destroy), controller: 'account_sharings' do
        post :accept, on: :member
      end
      resources :guest_collaborators, module: 'collaborators', controller: 'guest' do
        get 'search', on: :collection
      end

      resource :mcf_settings, only: %w(edit update destroy), module: 'my_company_files', controller: 'settings' do
        post :authorize
        get  :callback
      end
    end
  end
end