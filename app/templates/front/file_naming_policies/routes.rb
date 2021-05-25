# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'file_naming_policies' do
    resource :file_naming_policy, only: %w(edit update), controller: 'main' do
	    patch 'preview', on: :member
	  end
  end
end