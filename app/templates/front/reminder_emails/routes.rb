# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'reminder_emails' do
    resources :reminder_emails, except: :index, controller: 'main' do
	    post 'deliver', on: :member
	  end
  end
end