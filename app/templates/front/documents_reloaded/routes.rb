# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'documents_reloaded' do
    get 'documents_reloaded', to: 'pieces#index', as: 'documents_reloaded'
  end
  
  namespace :documents_reloaded do
    resource :upload, controller: 'uploads'

    resource :uploader, controller: 'uploader' do
      get 'periods/:upload_user',  to: 'uploader#periods',  on: :collection
      get 'journals/:upload_user', to: 'uploader#journals', on: :collection
    end
  end
end