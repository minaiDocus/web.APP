# encoding: utf-8
Rails.application.routes.draw do
  namespace :admin do
    resources :bank_utilities, module: 'bank_utilities', controller: 'main' do
      get  'get_operations', on: :collection
      get  'get_bank_accounts_bridge', on: :collection
      get  'get_transaction_bridge', on: :collection            

      post  'get_retriever', on: :collection
      post  'get_bank_accounts', on: :collection      
      post 'switch', on: :collection
      post 'user_reset_password', on: :collection
      post 'resume_me', on: :collection
    end
  end
end
