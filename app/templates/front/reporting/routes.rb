# encoding: utf-8
Rails.application.routes.draw do
  namespace 'reporting' do
    get '/(:organization_id)', to: 'main#show', as: 'index'

    post '/injected_documents', to: 'main#injected_documents', as: 'report_injected_documents'
    post '/pre_assignment_accounts', to: 'main#pre_assignment_accounts', as: 'report_pre_assignment_accounts'
    post '/retrievers_report', to: 'main#retrievers_report', as: 'retrievers_report'
  end

  scope module: 'reporting' do
    namespace :report do
      resources :expenses, module: 'reporting', controller: 'expenses'
      resources :preseizures, module: 'reporting', controller: 'preseizures'
    end
  end
end