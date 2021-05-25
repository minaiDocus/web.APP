# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'file_sending_kits' do
    resource :file_sending_kit, only: %w(edit update), controller: 'main' do
	    get  'mails',           on: :member
	    get  'select',          on: :member
	    get  'folders',         on: :member
	    post 'generate',        on: :member
	    get  'customer_labels', on: :member
	    get  'workshop_labels', on: :member
	  end
  end
end