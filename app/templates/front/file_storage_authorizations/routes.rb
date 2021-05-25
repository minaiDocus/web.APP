# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'file_storage_authorizations' do
    resource :file_storage_authorizations, only: %w(edit update), controller: 'main'
  end
end