Rails.application.routes.draw do
  scope module: 'retrieved_banking_operations' do
    resources :retrieved_banking_operations, only: %W(index), controller: 'main' do
      post 'force_processing', on: :collection
      post 'unlock_operations', on: :collection
    end
  end
end