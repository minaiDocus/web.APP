Rails.application.routes.draw do
  scope module: 'retrieved_documents' do
    resources :retrieved_documents, controller: 'main' do
      get   'piece',    on: :member
      get   'select',   on: :collection
      patch 'validate', on: :collection
    end
  end
end