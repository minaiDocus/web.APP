# encoding: utf-8
Rails.application.routes.draw do
  namespace :account_number_rules do
    get '/', to: "main#index", as: "main_index"
    patch   'import', to: 'main#import', as: 'import'
	get     'import_form', to: 'main#import_form', as: 'import_form'
	get     'import_model', to: 'main#import_model', as: 'import_model'
	post    'export_or_destroy', to: 'main#export_or_destroy', as: 'export_or_destroy'
	post    'update_skip_accounting_plan_accounts', to: 'main#update_skip_accounting_plan_accounts', as: 'update_skip_accounting_plan_accounts'
  end
end