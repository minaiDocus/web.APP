Rails.application.routes.draw do
  scope module: 'retriever_parameters' do
    get '/retriever/parameters', to: 'main#index', as: 'retriever_parameters'

    get '/retriever/banks_selection', to: 'banks_selection#index', as: 'retriever_banks_selection'
    get '/retriever/documents_selection', to: 'documents_selection#index', as: 'retriever_documents_selection'
    get '/retriever/banks_params', to: 'banks_params#index', as: 'retriever_banks_params'
  end
end