# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'documents' do
    post 'documents/deliver_preseizures', to: 'main#deliver_preseizures', as: 'documents_deliver_preseizures'

    get 'documents/tags', to: 'main#get_tags', as: 'documents_tags'
    post 'documents/tags/update', to: 'main#update_tags', as: 'documents_update_tags'

    post 'documents/export_options', to: 'main#export_options', as: 'documents_export_options'
    get 'documents/export_preseizures/:q', to: 'main#export_preseizures', as: 'documents_export_preseizures'
    get 'documents/download_archive/:id', to: 'main#download_archive', as: 'documents_download_archive'
    get 'documents/download_bundle/:id', to: 'main#download_bundle', as: 'documents_download_bundle'

    get 'documents', to: 'pieces#index', as: 'documents'
    get 'documents/:id', to: 'pieces#show', as: 'documents_details'

    get 'operations', to: 'operations#index', as: 'operations'
    get 'operations/:id', to: 'operations#show', as: 'operations_details'

    post 'preseizures/update', to: 'preseizures#update', as: 'preseizures_update'
    get 'preseizures/:id', to: 'preseizures#show', as: 'preseizures_details'
  end
  
  namespace :documents do
    resource :compta_analytics, controller: 'compta_analytics' do
      post 'update_multiple', on: :collection
    end

    resource :upload, controller: 'uploads'

    resource :uploader, controller: 'uploader' do
      get 'periods/:upload_user',  to: 'uploader#periods',  on: :collection
      get 'journals/:upload_user', to: 'uploader#journals', on: :collection
    end
  end
end