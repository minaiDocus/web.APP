# encoding: utf-8
Rails.application.routes.draw do
  namespace 'reporting' do
    get '/invoices/periods/(:id)', to: 'invoices#period', as: 'invoices_periods'
    post '/invoices', to: 'invoices#index', as: 'invoices_index'
    get '/invoices.xls', to: 'invoices#index', as: 'invoices_index_xls'

    get '/(:organization_id)', to: 'statistics#index', as: 'statistics_index'

    post '/injected_documents', to: 'statistics#injected_documents', as: 'report_injected_documents'
    post '/pre_assignment_accounts', to: 'statistics#pre_assignment_accounts', as: 'report_pre_assignment_accounts'
    post '/retrievers_report', to: 'statistics#retrievers_report', as: 'retrievers_report'
  end

  scope module: 'reporting' do
    namespace :report do
      resources :expenses, module: 'reporting', controller: 'expenses'
      resources :preseizures, module: 'reporting', controller: 'preseizures'
    end
  end
end