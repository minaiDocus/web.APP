# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'customers' do
    resources :organizations, only: [] do
      resources :customers, controller: 'main' do
        collection do
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
          get   'edit_setting_options'
          patch 'update_setting_options'
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
    end
  end
end
