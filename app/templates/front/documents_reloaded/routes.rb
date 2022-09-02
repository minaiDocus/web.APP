# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'documents_reloaded' do
    get 'documents_reloaded', to: 'pieces#index', as: 'documents_reloaded'
    get 'documents_reloaded/:id', to: 'pieces#show', as: 'show_piece_detail'
    post 'documents_reloaded/delete', to: 'pieces#delete', as: 'delete_documents_reloaded'
    post 'documents_reloaded/restore', to: 'pieces#restore', as: 'restore_document_reloaded'
    delete 'documents_reloaded/delete_temp_document', to: 'pieces#delete_temp_document', as: 'delete_temp_document'
    get 'preseizures_reloaded/infos', to: 'preseizures#index', as: 'preseizures_reloaded_infos'
    post 'documents_reloaded/deliver_preseizures', to: 'abase#deliver_preseizures', as: 'documents_reloaded_deliver_preseizures'
  end

  namespace :documents_reloaded do
    resource :upload, controller: 'uploads'

    resource :uploader, controller: 'uploader' do
      get 'periods/:upload_user',  to: 'uploader#periods',  on: :collection
      get 'journals/:upload_user', to: 'uploader#journals', on: :collection
    end
  end
end