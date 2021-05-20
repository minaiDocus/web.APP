Rails.application.routes.draw do
  scope module: 'emailed_documents' do
    resources :emailed_documents, controller: 'main' do
      post 'regenerate_code', on: :collection
    end
  end
end